#!/bin/bash
# Apply pipa WiFi duplicate-list fix on a live device (no rebuild needed).
set -eu
SUDO_PASS="${SUDO_PASS:-1234}"
CONF="$(cd "$(dirname "$0")/../overlay/system/etc/NetworkManager/conf.d/90-pipa-wifi.conf" && pwd)"

adb get-state >/dev/null
adb push "$CONF" /tmp/90-pipa-wifi.conf
adb shell "echo $SUDO_PASS | sudo -S bash -s" <<'EOF'
install -m644 /tmp/90-pipa-wifi.conf /etc/NetworkManager/conf.d/90-pipa-wifi.conf
systemctl restart NetworkManager.service
sleep 3
echo "=== WiFi devices (expect only wlp1s0 managed) ==="
nmcli -t -f DEVICE,TYPE,STATE device status | grep -E 'wifi|802-11' || true
echo "=== Scan count (unique SSIDs) ==="
nmcli -t -f SSID dev wifi list | sort -u | wc -l
EOF
