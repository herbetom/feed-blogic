/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

import { config } from './config.uc';
import { FIELDS, store_text, store_ready, store_load, store_write,
	 store_forget } from './store.uc';
import { wireless_init, wireless_refresh, wireless_stations } from './wireless.uc';
import { leases_read } from './leases.uc';
import { identity_init, identity_read, identity_apply } from './identity.uc';

let clients = {};
let stored_count = 0;
let capped = false;

function record_new(mac, now) {
	let record = {
		mac,
		first_seen: now,
		last_seen: now,
		known_since: now,
		online: false,
		since: 0,
		ip: '',
		hostname: '',
		ssid: '',
		ifname: '',
		band: 0,
		signal: 0,
		rx: 0,
		tx: 0,
		weights: {},
		stored: false,
		dirty: true,
		text: null,
	};

	for (let field in FIELDS)
		record[field] = '';

	return record;
}

function record_restore(mac, saved, now) {
	let record = record_new(mac, now);

	record.first_seen = saved.first_seen ?? now;
	record.weights = saved.weights ?? {};
	record.stored = true;
	record.dirty = false;
	record.text = saved.text;

	for (let field in FIELDS)
		record[field] = saved[field] ?? '';

	return record;
}

function client_touch(mac, now) {
	let record = clients[mac];

	if (record) {
		record.last_seen = now;

		return record;
	}

	record = record_new(mac, now);
	clients[mac] = record;

	return record;
}

function client_public(record, now) {
	return {
		mac: record.mac,
		name: record.name,
		hostname: record.hostname,
		vendor: record.vendor,
		model: record.model,
		class: record.class,
		ip: record.ip,
		online: record.online,
		band: record.band,
		signal: record.signal,
		uptime: record.since ? now - record.since : 0,
		ssid: record.ssid,
		ifname: record.ifname,
		rx: record.rx,
		tx: record.tx,
		first_seen: record.first_seen,
		last_seen: record.last_seen,
		stored: record.stored,
	};
}

/**
 * clients_init - reach the sources and read the store back
 * @conn: a ubus connection
 * @now: the wall clock second
 */
export function clients_init(conn, now) {
	wireless_init(conn);
	identity_init(conn);

	clients = {};
	stored_count = 0;
	capped = false;

	if (!store_ready(config.store))
		return;

	for (let mac, saved in store_load(config.store)) {
		clients[mac] = record_restore(mac, saved, now);
		stored_count++;
	}
};

export function clients_refresh_bss() {
	wireless_refresh();
};

/**
 * clients_poll - fold one round of the live sources into the records
 * @now: the wall clock second
 *
 * A client is a station on one of our BSSs or the holder of one of our leases.
 * The ufp table is never a source of clients: it holds every MAC the router has
 * heard of, the upstream router's neighbours included.
 *
 * Return: how many clients this round admitted for the first time.
 */
export function clients_poll(now) {
	const stations = wireless_stations();
	const leases = leases_read();
	let admitted = 0;

	for (let mac, record in clients)
		record.online = false;

	for (let mac, station in stations) {
		if (!clients[mac])
			admitted++;

		let record = client_touch(mac, now);

		record.online = true;
		record.ifname = station.ifname;
		record.ssid = station.ssid;
		record.band = station.band;
		record.signal = station.signal;
		record.rx = station.rx;
		record.tx = station.tx;

		if (!record.since)
			record.since = now;
	}

	for (let mac, lease in leases) {
		if (!clients[mac])
			admitted++;

		let record = client_touch(mac, now);

		record.ip = lease.ip;

		if (lease.hostname != '')
			record.hostname = lease.hostname;
	}

	for (let mac, record in clients)
		if (!record.online)
			record.since = 0;

	return admitted;
};

/**
 * clients_identity - fold the fingerprints into the records
 * @now: the wall clock second
 */
export function clients_identity(now) {
	const table = identity_read();

	if (!table)
		return;

	for (let mac, entry in table) {
		let record = clients[lc(mac)];

		if (!record)
			continue;

		if (identity_apply(record, entry, config.margin))
			record.dirty = true;
	}
};

/**
 * clients_sync - write the records that have earned a write
 * @now: the wall clock second
 *
 * A new client waits out the settle time, because a device fingerprints in
 * stages. After that only a changed field writes, and only when the text really
 * differs. Past max_clients a new client stays in memory rather than displacing
 * a record that is already kept.
 */
export function clients_sync(now) {
	for (let mac, record in clients) {
		if (!record.dirty)
			continue;

		if (!record.stored && now - record.known_since < config.settle)
			continue;

		if (!record.stored && stored_count >= config.max_clients) {
			if (!capped)
				warn(`uclientd: ${config.max_clients} records stored, keeping the rest in memory\n`);

			capped = true;
			continue;
		}

		const text = store_text(record);

		if (text == record.text) {
			record.dirty = false;
			continue;
		}

		if (!store_write(config.store, mac, text))
			continue;

		if (!record.stored)
			stored_count++;

		record.stored = true;
		record.text = text;
		record.dirty = false;
	}
};

/**
 * clients_list - every client this router knows
 *
 * Return: the records, online first and then by MAC. An offset indexes into
 * that order, so a walk across two pages neither drops nor repeats a device.
 */
export function clients_list() {
	const now = time();
	let online = [];
	let absent = [];

	for (let mac in sort(keys(clients))) {
		const record = clients[mac];

		push(record.online ? online : absent, client_public(record, now));
	}

	return [ ...online, ...absent ];
};

/**
 * clients_get - one client
 *
 * Return: the record, or null when the MAC is not known.
 */
export function clients_get(mac) {
	const record = clients[lc(mac ?? '')];

	return record ? client_public(record, time()) : null;
};

/**
 * clients_forget - drop one client and its stored record
 *
 * Return: true when the client was known.
 */
export function clients_forget(mac) {
	const key = lc(mac ?? '');
	let record = clients[key];

	if (!record)
		return false;

	if (record.stored && store_forget(config.store, key))
		stored_count--;

	delete clients[key];

	return true;
};
