/*
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Copyright (C) 2026 John Crispin <john@phrozen.org>
 */

'use strict';

import { readfile } from 'fs';

const DNSMASQ = '/tmp/dhcp.leases';
const ODHCPD = '/tmp/odhcpd.leases';

const MAC = regexp('^[0-9a-f][0-9a-f](:[0-9a-f][0-9a-f]){5}$');
const IPV4 = regexp('^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$');

const UNKNOWN = [ '*', '-' ];

function words(line) {
	return filter(split(line, ' '), (v) => v != '');
}

function hostname_of(name) {
	if (!name || index(UNKNOWN, name) >= 0)
		return '';

	if (substr(name, 0, 10) == 'broken\\x20')
		return '';

	return name;
}

function lease_add(found, mac, address, name) {
	const key = lc(mac ?? '');

	if (!match(key, MAC))
		return;

	if (!match(address ?? '', IPV4))
		return;

	found[key] = { ip: address, hostname: hostname_of(name) };
}

function dnsmasq_parse(found, data) {
	for (let line in split(data, '\n')) {
		const field = words(line);

		if (length(field) < 4)
			continue;

		lease_add(found, field[1], field[2], field[3]);
	}
}

function odhcpd_parse(found, data) {
	for (let line in split(data, '\n')) {
		const field = words(line);

		if (length(field) < 9)
			continue;

		if (field[0] != '#' || field[3] != 'ipv4')
			continue;

		lease_add(found, field[2], split(field[8], '/')[0], field[4]);
	}
}

/**
 * leases_read - the clients holding an IPv4 lease
 *
 * Reads both state files, so it does not matter which daemon serves DHCP. A
 * file that is not there yields nothing, and odhcpd is read second, so it wins
 * for a client that appears in both.
 *
 * Return: ip and hostname keyed by MAC, the MAC lower case and colon
 * separated. The hostname is an empty string when the server does not know one.
 */
export function leases_read() {
	let found = {};
	const dnsmasq = readfile(DNSMASQ);
	const odhcpd = readfile(ODHCPD);

	if (dnsmasq)
		dnsmasq_parse(found, dnsmasq);

	if (odhcpd)
		odhcpd_parse(found, odhcpd);

	return found;
};
