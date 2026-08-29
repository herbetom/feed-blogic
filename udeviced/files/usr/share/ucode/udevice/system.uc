/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

import { readfile, statvfs } from 'fs';
import { file_line, file_value, words } from './proc.uc';
import { LIVE, LAST, ladder_new, ladder_add, ladder_window } from './ring.uc';

const FLASH_INTERVAL = 30;

const STAT_IDLE = 4;
const STAT_IOWAIT = 5;

let thermal = [];
let flash_due = 0;
let cpu_last = {};
let rings = {};

let live = { cpu: 0, mem: 0, flash: 0, temp: null, load: [ 0, 0, 0 ] };

function cpu_percent() {
	const field = words(file_line('/proc/stat'));

	if (length(field) <= STAT_IOWAIT)
		return 0;

	let total = 0;

	for (let i = 1; i < length(field); i++)
		total += +field[i];

	const idle = +field[STAT_IDLE] + +field[STAT_IOWAIT];

	if (cpu_last.total == null) {
		cpu_last.total = total;
		cpu_last.idle = idle;

		return 0;
	}

	const dt = total - cpu_last.total;
	const di = idle - cpu_last.idle;

	cpu_last.total = total;
	cpu_last.idle = idle;

	if (dt <= 0)
		return 0;

	return int((dt - di) * 100 / dt);
}

function mem_percent() {
	let total, available;

	for (let line in split(readfile('/proc/meminfo') ?? '', '\n')) {
		const field = words(line);

		if (field[0] == 'MemTotal:')
			total = +field[1];
		else if (field[0] == 'MemAvailable:')
			available = +field[1];
	}

	if (!total || available == null)
		return 0;

	return int((total - available) * 100 / total);
}

function load_read() {
	const field = words(file_line('/proc/loadavg'));

	if (length(field) < 3)
		return [ 0, 0, 0 ];

	return [ +field[0], +field[1], +field[2] ];
}

function flash_percent(now) {
	if (now < flash_due)
		return live.flash;

	flash_due = now + FLASH_INTERVAL;

	const root = statvfs('/');

	if (!root?.blocks)
		return live.flash;

	return int((root.blocks - root.bfree) * 100 / root.blocks);
}

function temp_read() {
	let hottest;

	for (let path in thermal) {
		const milli = file_value(path);

		if (milli == null)
			continue;

		const degrees = int(+milli / 1000);

		if (hottest == null || degrees > hottest)
			hottest = degrees;
	}

	return hottest;
}

/**
 * system_init - arm the readings
 * @paths: hwmon inputs in millidegrees, the hottest of which becomes temp
 */
export function system_init(paths) {
	thermal = paths ?? [];

	rings = {
		cpu: ladder_new(LIVE, LAST),
		mem: ladder_new(LIVE, LAST),
		temp: ladder_new(LIVE, LAST),
		load: ladder_new(LIVE, LAST),
	};
};

/**
 * system_sample - take one reading of each
 * @now: the wall clock second
 */
export function system_sample(now) {
	const temp = temp_read();

	live.cpu = cpu_percent();
	live.mem = mem_percent();
	live.flash = flash_percent(now);
	live.load = load_read();

	if (temp != null)
		live.temp = temp;

	ladder_add(rings.cpu, now, live.cpu);
	ladder_add(rings.mem, now, live.mem);
	ladder_add(rings.load, now, live.load[0]);

	if (length(thermal))
		ladder_add(rings.temp, now, live.temp ?? 0);
};

/**
 * system_status - the newest reading of each
 *
 * Return: cpu, mem and flash as percentages, load as three averages, and temp
 * in degrees when a sensor is configured.
 */
export function system_status() {
	let out = {
		cpu: live.cpu,
		mem: live.mem,
		flash: live.flash,
		load: live.load,
	};

	if (live.temp != null)
		out.temp = live.temp;

	return out;
};

/**
 * system_history - the readings kept for one window
 * @window: the window name
 *
 * Return: an array per reading, newest last, empty for a window these do not
 * keep.
 */
export function system_history(window) {
	let out = {};

	for (let name, ladder in rings) {
		const found = ladder_window(ladder, window);

		if (!found || !length(found.entries))
			continue;

		out[name] = found.entries;
	}

	return out;
};
