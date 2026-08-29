/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

const BSS = regexp('^hostapd\\.');

const BAND_5 = 3000;
const BAND_6 = 5925;

let ubus;
let bss = {};

function band_of(frequency) {
	if (!frequency)
		return 0;
	if (frequency < BAND_5)
		return 2;

	return frequency >= BAND_6 ? 6 : 5;
}

/**
 * wireless_refresh - re-enumerate the BSS objects
 *
 * The SSID is read once per object and kept, because a BSS that changes it
 * brings a new object with it.
 */
export function wireless_refresh() {
	let found = {};

	for (let name in ubus.list() ?? []) {
		if (!match(name, BSS))
			continue;

		found[name] = bss[name] ?? {
			ifname: substr(name, length('hostapd.')),
			ssid: ubus.call(name, 'get_status')?.ssid ?? '',
		};
	}

	bss = found;
};

/**
 * wireless_init - find the BSS objects
 * @conn: a ubus connection
 */
export function wireless_init(conn) {
	ubus = conn;
	bss = {};

	wireless_refresh();
};

/**
 * wireless_stations - every station associated to one of our BSSs
 *
 * Return: interface, ssid, band, signal and byte counters keyed by MAC. hostapd
 * omits the counters and the signal for a station whose driver read failed, so
 * those arrive as zero.
 */
export function wireless_stations() {
	let found = {};

	for (let name, entry in bss) {
		const reply = ubus.call(name, 'get_clients');

		if (!reply)
			continue;

		const band = band_of(reply.freq);

		for (let mac, station in reply.clients ?? {}) {
			found[lc(mac)] = {
				ifname: entry.ifname,
				ssid: entry.ssid,
				band,
				signal: station.signal ?? 0,
				rx: station.bytes?.rx ?? 0,
				tx: station.bytes?.tx ?? 0,
			};
		}
	}

	return found;
};
