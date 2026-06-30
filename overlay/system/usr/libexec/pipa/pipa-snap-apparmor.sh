#!/bin/sh
# pipa: AppArmor tweaks for snapd on kernel 4.19 (Halium).
# snap-confine uses change_profile -> snap-update-ns.* but legacy exec
# transitions need inherit (ix) on pipa until permstable/OOB kernel is flashed.

set -e

MARKER="# pipa: snap-update-ns inherit exec for 4.19 kernel"
CONF=/etc/apparmor.d/usr.lib.snapd.snap-confine.real
LOCAL=/etc/apparmor.d/local/usr.lib.snapd.snap-confine.real
CACHE=/var/cache/apparmor

patch_confine() {
	[ -f "$CONF" ] || return 0

	if ! grep -Fq "$MARKER" "$CONF" 2>/dev/null; then
		sed -i "s|snap-update-ns r,|snap-update-ns ix,  $MARKER|g" "$CONF"
		sed -i "s|snap-update-ns mr,|snap-update-ns ix,|g" "$CONF"
	fi

	for f in /var/lib/snapd/apparmor/profiles/snap-confine.snapd.*; do
		[ -f "$f" ] || continue
		sed -i "s|snap-update-ns r,|snap-update-ns ix,|g" "$f"
		sed -i "s|snap-update-ns mr,|snap-update-ns ix,|g" "$f"
	done
}

append_local() {
	mkdir -p "$(dirname "$LOCAL")"
	if ! grep -Fq "$MARKER" "$LOCAL" 2>/dev/null; then
		cat >>"$LOCAL" <<EOF

$MARKER
/tmp/.snap/ rw,
/run/snapd/ns/snap.*.fstab* rw,
@{PROC}/cmdline r,
@{sys}/fs/cgroup/** rw,
EOF
	fi
}

patch_confine
append_local

find "$CACHE" -name 'usr.lib.snapd.snap-confine.real' -delete 2>/dev/null || true
apparmor_parser -r --write-cache --cache-loc="$CACHE" "$CONF" 2>/dev/null || \
	apparmor_parser -r "$CONF" 2>/dev/null || true

for f in /var/lib/snapd/apparmor/profiles/snap-confine.snapd.*; do
	[ -f "$f" ] || continue
	apparmor_parser -r "$f" 2>/dev/null || true
done

exit 0
