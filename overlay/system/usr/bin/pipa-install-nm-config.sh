#!/bin/sh
# Copy pipa NetworkManager drop-ins into /run before NM starts (rootfs /etc is ro).
set -eu
src=/usr/share/pipa/networkmanager/conf.d
dst=/run/NetworkManager/conf.d
mkdir -p "$dst"
for f in "$src"/*.conf; do
	[ -f "$f" ] || continue
	install -m644 "$f" "$dst/$(basename "$f")"
done
