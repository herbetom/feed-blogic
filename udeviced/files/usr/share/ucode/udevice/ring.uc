/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

export const WINDOWS = [
	{ name: 'live',  step: 1,     count: 120 },
	{ name: 'hour',  step: 60,    count: 60 },
	{ name: 'day',   step: 3600,  count: 24 },
	{ name: 'month', step: 86400, count: 30 },
];

export const LIVE = [ WINDOWS[0] ];

export const SUM = 0;
export const LAST = 1;

function ring_new(window, mode) {
	return {
		name: window.name,
		step: window.step,
		count: window.count,
		mode,
		entries: [],
		bucket: null,
		total: 0,
		start: null,
	};
}

function ring_add(ring, now, value) {
	const bucket = int(now / ring.step);

	if (ring.bucket == null) {
		ring.bucket = bucket;
		ring.total = value;

		return null;
	}

	if (ring.bucket == bucket) {
		ring.total = ring.mode == LAST ? value : ring.total + value;

		return null;
	}

	const closed = { total: ring.total, start: ring.bucket * ring.step };

	push(ring.entries, closed.total);

	while (length(ring.entries) > ring.count)
		shift(ring.entries);

	ring.start = closed.start;
	ring.bucket = bucket;
	ring.total = value;

	return closed;
}

/**
 * ladder_new - build a ladder of rings
 * @windows: the steps to build, finest first
 * @mode: SUM to total the values in a bucket, LAST to keep only the newest
 *
 * Return: the ladder.
 */
export function ladder_new(windows, mode) {
	let rings = [];

	for (let window in windows)
		push(rings, ring_new(window, mode ?? SUM));

	return rings;
};

/**
 * ladder_add - account one sample
 * @ladder: the ladder to add to
 * @now: the wall clock second that picks the bucket
 * @value: bytes for a SUM ladder, a reading for a LAST one
 *
 * A bucket carries into the step above when it closes, stamped with the second
 * it began.
 */
export function ladder_add(ladder, now, value) {
	let carry = { total: value, start: now };

	for (let ring in ladder) {
		carry = ring_add(ring, carry.start, carry.total);

		if (carry == null)
			return;
	}
};

/**
 * ladder_window - read one step
 * @ladder: the ladder to read
 * @name: the window name
 *
 * Return: step, count, start and the closed entries newest last, or null for
 * an unknown name. The bucket still filling is not included, and start is when
 * the newest entry began.
 */
export function ladder_window(ladder, name) {
	for (let ring in ladder) {
		if (ring.name != name)
			continue;

		return {
			step: ring.step,
			count: ring.count,
			start: ring.start ?? 0,
			entries: ring.entries,
		};
	}

	return null;
};
