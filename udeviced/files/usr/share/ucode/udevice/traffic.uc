/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

import { readfile } from 'fs';
import { words } from './proc.uc';
import { WINDOWS, ladder_new, ladder_add, ladder_window } from './ring.uc';

const NETDEV = '/proc/net/dev';

const RX_BYTES = 0;
const TX_BYTES = 8;

let ubus;
let tracked = {};

function netdev_read() {
	let found = {};

	for (let line in split(readfile(NETDEV) ?? '', '\n')) {
		const parts = split(line, ':', 2);

		if (length(parts) < 2)
			continue;

		const field = words(parts[1]);

		if (length(field) <= TX_BYTES)
			continue;

		found[trim(parts[0])] = { rx: +field[RX_BYTES], tx: +field[TX_BYTES] };
	}

	return found;
}

/**
 * traffic_resolve - find the netdev behind each tracked interface
 *
 * Call at start up and on a network.interface event. A changed device drops the
 * baseline, so the next sample counts nothing it did not see.
 */
export function traffic_resolve() {
	for (let name, entry in tracked) {
		const status = ubus.call('network.interface.' + name, 'status');
		const device = status?.l3_device ?? status?.device;

		entry.up = status?.up ?? false;

		if (device == entry.device)
			continue;

		entry.device = device;
		entry.rx_last = null;
		entry.tx_last = null;
	}
};

/**
 * traffic_init - track the named interfaces
 * @conn: a ubus connection, for resolving the netdev
 * @names: uci interface names
 *
 * An interface that is already tracked keeps its history.
 */
export function traffic_init(conn, names) {
	let kept = {};

	ubus = conn;

	for (let name in names)
		kept[name] = tracked[name] ?? {
			name,
			device: null,
			up: false,
			rx_last: null,
			tx_last: null,
			rx: 0,
			tx: 0,
			rx_ring: ladder_new(WINDOWS),
			tx_ring: ladder_new(WINDOWS),
		};

	tracked = kept;

	traffic_resolve();
};

function counter_delta(entry, key, value) {
	const previous = entry[key];

	entry[key] = value;

	if (previous == null || value < previous)
		return 0;

	return value - previous;
}

/**
 * traffic_sample - count the bytes each tracked interface moved
 * @now: the wall clock second
 */
export function traffic_sample(now) {
	const netdev = netdev_read();

	for (let name, entry in tracked) {
		const counters = entry.device ? netdev[entry.device] : null;

		entry.rx = counters ? counter_delta(entry, 'rx_last', counters.rx) : 0;
		entry.tx = counters ? counter_delta(entry, 'tx_last', counters.tx) : 0;

		if (!counters) {
			entry.rx_last = null;
			entry.tx_last = null;
		}

		ladder_add(entry.rx_ring, now, entry.rx);
		ladder_add(entry.tx_ring, now, entry.tx);
	}
};

/**
 * traffic_status - the newest second of each tracked interface
 *
 * Return: up, the netdev name, and the bytes it moved, keyed by interface.
 */
export function traffic_status() {
	let out = {};

	for (let name, entry in tracked)
		out[name] = {
			up: entry.up,
			device: entry.device ?? '',
			rx: entry.rx,
			tx: entry.tx,
		};

	return out;
};

/**
 * traffic_history - one window of one interface
 * @name: the interface, or null for the first tracked one
 * @window: the window name
 *
 * Return: step, count, start and the rx and tx entries, or null when neither
 * the interface nor the window is known.
 */
export function traffic_history(name, window) {
	const entry = tracked[name] ?? tracked[keys(tracked)[0]];

	if (!entry)
		return null;

	const rx = ladder_window(entry.rx_ring, window);

	if (!rx)
		return null;

	return {
		interface: entry.name,
		step: rx.step,
		count: rx.count,
		start: rx.start,
		rx: rx.entries,
		tx: ladder_window(entry.tx_ring, window).entries,
	};
};
