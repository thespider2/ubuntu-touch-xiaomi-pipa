#!/bin/bash
# Download vendor.img and odm.img into the device overlay for /var/lib/lxc/android/.
set -euo pipefail

REPO="${ANDROID_PARTITIONS_REPO:-thespider2/droidian-images-xiaomi-pipa}"
BRANCH="${ANDROID_PARTITIONS_BRANCH:-trixie}"
BASE="https://github.com/${REPO}/raw/refs/heads/${BRANCH}/android-partitions"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${ROOT}/overlay/system/var/lib/lxc/android"
mkdir -p "$DEST"

fetch() {
	local name=$1
	local min_bytes=$2
	local url="${BASE}/${name}"
	local out="${DEST}/${name}"

	if [ -f "$out" ] && [ "$(stat -c%s "$out")" -ge "$min_bytes" ]; then
		echo "fetch-android-partitions: ${name} already present ($(stat -c%s "$out") bytes), skipping"
		return 0
	fi

	echo "fetch-android-partitions: downloading ${url}"
	wget -q --show-progress -O "${out}.partial" "$url"
	mv "${out}.partial" "$out"

	local size
	size="$(stat -c%s "$out")"
	if [ "$size" -lt "$min_bytes" ]; then
		echo "fetch-android-partitions: ${name} too small (${size} bytes, expected >= ${min_bytes})" >&2
		exit 1
	fi
	echo "fetch-android-partitions: ${name} OK (${size} bytes)"
}

# GitHub LFS redirects to media.githubusercontent.com; wget follows redirects.
fetch odm.img 1000000
fetch vendor.img 900000000

ls -lh "$DEST"/odm.img "$DEST"/vendor.img
