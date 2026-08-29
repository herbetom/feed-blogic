/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

import * as libuci from 'uci';

export const config = {
	store: '/etc/clients',
	settle: 600,
	margin: 2,
	poll: 5,
	identity: 60,
	max_clients: 512,
};

const NUMBERS = [ 'settle', 'margin', 'poll', 'identity', 'max_clients' ];

export function config_load() {
	let cursor = libuci.cursor();

	if (!cursor.load('clients'))
		return warn("uclientd: cannot load /etc/config/clients\n");

	const store = cursor.get('clients', 'main', 'store');

	if (store)
		config.store = store;

	for (let name in NUMBERS) {
		const value = cursor.get('clients', 'main', name);

		if (value != null && value != '')
			config[name] = +value;
	}
};
