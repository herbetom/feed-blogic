/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

import * as libuci from 'uci';

const SECTION = '@monitoring[0]';

export const config = {
	interfaces: [ 'wan' ],
	thermal: [],
};

function list_of(value) {
	if (value == null || value == '')
		return null;

	return type(value) == 'array' ? value : [ value ];
}

export function config_load() {
	let cursor = libuci.cursor();

	cursor.load('system');

	config.interfaces = list_of(cursor.get('system', SECTION, 'interface')) ??
			    [ 'wan' ];
	config.thermal = list_of(cursor.get('system', SECTION, 'thermal')) ?? [];
};
