/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

const SOURCE = {
	name: 'device_name',
	vendor: 'vendor',
	model: 'device',
	class: 'class',
};

let ubus;

/**
 * identity_init - reach ufp
 * @conn: a ubus connection
 */
export function identity_init(conn) {
	ubus = conn;
};

/**
 * identity_read - what ufp believes about every device it knows
 *
 * One bulk call. Every call makes ufpd run all of its plugins, so poll it
 * slowly. The table names every MAC ufpd has heard of, so apply it only to
 * clients that are ours.
 *
 * Return: the fingerprint and its weights keyed by MAC, or null.
 */
export function identity_read() {
	return ubus.call('fingerprint', 'fingerprint', { weight: true });
};

/**
 * identity_apply - fold one device's fingerprint into a record
 * @record: the client record to update
 * @entry: that device's entry from identity_read
 * @margin: how much heavier a contradicting answer must be to win
 *
 * An empty field takes what it is offered. A field that holds a value keeps it
 * until something outweighs it by the margin.
 *
 * Return: true when a stored field changed.
 */
export function identity_apply(record, entry, margin) {
	let changed = false;

	for (let field, key in SOURCE) {
		const value = entry[key];

		if (!value)
			continue;

		const weight = entry.weight?.[key] ?? 0;
		const held = record[field];

		if (held == value) {
			if (weight > (record.weights[field] ?? 0))
				record.weights[field] = weight;

			continue;
		}

		if (held != '' && weight < (record.weights[field] ?? 0) + margin)
			continue;

		record[field] = value;
		record.weights[field] = weight;
		changed = true;
	}

	return changed;
};
