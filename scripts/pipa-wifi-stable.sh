#!/bin/bash
# Apply pipa WiFi stability configs on a live device via /run (rootfs /etc is read-only).
set -eu
SUDO_PASS="${SUDO_PASS:-1234}"
OVERLAY="$(cd "$(dirname "$0")/../overlay/system/usr/share/pipa/networkmanager/conf.d" && pwd)"

adb get-state >/dev/null

for conf in 10-wifi-timeout.conf 90-pipa-wifi.conf 91-pipa-wifi-stable.conf; do
	adb push "$OVERLAY/$conf" "/tmp/pipa-$conf"
done

adb shell "echo $SUDO_PASS | sudo -S bash -s" <<'EOF'
mkdir -p /run/NetworkManager/conf.d
for f in /tmp/pipa-*.conf; do
	[ -f "$f" ] || continue
	install -m644 "$f" "/run/NetworkManager/conf.d/${f#/tmp/pipa-}"
done
systemctl restart NetworkManager.service
sleep 2
nmcli general status
EOF

echo "WiFi stability configs applied for this boot (rebuild/flash for permanent pipa-nm-wifi-config.service)."
