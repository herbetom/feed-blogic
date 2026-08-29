/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

import { readfile, lsdir, open, rename, unlink, mkdir, access } from 'fs';

const SUFFIX = '.json';
const MAC = regexp('^[0-9a-f][0-9a-f](:[0-9a-f][0-9a-f]){5}$');

export const FIELDS = [ 'name', 'vendor', 'model', 'class' ];

function path_of(dir, mac) {
	return sprintf('%s/%s%s', dir, mac, SUFFIX);
}

/**
 * store_text - the file content for a record
 *
 * Return: the fields that outlive a reboot, with the weight behind each so the
 * hysteresis in identity.uc still holds after a restart.
 */
export function store_text(record) {
	let out = { mac: record.mac, first_seen: record.first_seen };
	let weights = {};
	let carried = false;

	for (let field in FIELDS) {
		if (!record[field])
			continue;

		out[field] = record[field];
		weights[field] = record.weights[field] ?? 0;
		carried = true;
	}

	if (carried)
		out.weights = weights;

	return sprintf('%.J\n', out);
};

/**
 * store_ready - make sure the store can be written
 *
 * Return: true when the directory is there and writable.
 */
export function store_ready(dir) {
	if (access(dir, 'w'))
		return true;

	if (mkdir(dir, 0755))
		return true;

	warn(`uclientd: cannot create ${dir}\n`);

	return false;
};

/**
 * store_load - read every record back
 *
 * Return: the records keyed by MAC, each carrying the text it was read from. A
 * file that will not parse is reported and left alone.
 */
export function store_load(dir) {
	let found = {};

	for (let name in lsdir(dir) ?? []) {
		const stem = length(name) - length(SUFFIX);

		if (stem < 1 || substr(name, stem) != SUFFIX)
			continue;

		const mac = substr(name, 0, stem);

		if (!match(mac, MAC)) {
			warn(`uclientd: ${name} is not a client record\n`);
			continue;
		}

		const text = readfile(path_of(dir, mac));
		let record;

		try {
			record = json(text);
		} catch (e) {
			warn(`uclientd: ${name} does not parse: ${e}\n`);
			continue;
		}

		if (type(record) != 'object')
			continue;

		record.mac = mac;
		record.text = text;
		found[mac] = record;
	}

	return found;
};

/**
 * store_write - replace one record
 *
 * Writes beside the target and renames over it, so a power cut leaves either
 * the old record or the new one.
 *
 * Return: true when the record is on disk.
 */
export function store_write(dir, mac, text) {
	const tmp = sprintf('%s/.%s.tmp', dir, mac);
	let file = open(tmp, 'w');

	if (!file) {
		warn(`uclientd: cannot write ${tmp}\n`);

		return false;
	}

	file.write(text);
	file.flush();
	file.close();

	if (rename(tmp, path_of(dir, mac)))
		return true;

	warn(`uclientd: cannot rename ${tmp}\n`);
	unlink(tmp);

	return false;
};

/**
 * store_forget - remove one record from disk
 *
 * Return: true when the file is gone.
 */
export function store_forget(dir, mac) {
	return !!unlink(path_of(dir, mac));
};
