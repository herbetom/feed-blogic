/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

import { readfile } from 'fs';

/**
 * file_line - read the first line of a file
 *
 * Return: the line without its terminator, or null when the file will not read.
 */
export function file_line(path) {
	const body = readfile(path);

	return body != null ? split(body, '\n')[0] : null;
};

/**
 * file_value - read a file holding one value
 *
 * Return: the trimmed content, or null when the file will not read.
 */
export function file_value(path) {
	const body = readfile(path);

	return body != null ? trim(body) : null;
};

/**
 * words - split a line on runs of spaces
 *
 * Return: the fields, with the empty ones that padding leaves behind dropped.
 */
export function words(line) {
	return filter(split(trim(line ?? ''), ' '), (v) => v != '');
};
