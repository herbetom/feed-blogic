#!/usr/bin/env bash

set -euxo pipefail

# reorders OpenWrt SDK Artifact files to upload them to a download server collectively

function parse_package_string() {
	local input="$1"

	# Fail if input does not end with -packages
	if [[ "$input" != *-packages ]]; then
		>&2 echo "Error: input must end with '-packages'"
		exit 1
	fi

	# Remove trailing -packages
	base="${input%-packages}"

	# Regex match version and architecture
	if ! [[ "$base" =~ ^(openwrt-[0-9]+\.[0-9]+|v?[0-9]+\.[0-9]+\.[0-9]+|SNAPSHOT|main)-(.+)$ ]]; then
		>&2 echo "Could not parse input: $input"
		exit 1
	fi

	local version="${BASH_REMATCH[1]}"
	local arch="${BASH_REMATCH[2]}"

	[[ "$version" == "SNAPSHOT" ]] && version="snapshots"

	echo "combined/${version}/packages/${arch}/"
}


# loop over artifacts
for d in artifacts/*/ ; do
	# remove trailing slash
	s="${d%/}"
	# remove dir prefix
	s="${s#artifacts/}"
	# get new location
	p=$(parse_package_string "${s}")

	mkdir -p "${p}"
	mv -v "${d}"/* "${p}"
done
