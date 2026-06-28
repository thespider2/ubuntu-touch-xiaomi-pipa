#!/bin/sh

[ -e /sys/kernel/boot_wlan/boot_wlan ] && echo 1 > /sys/kernel/boot_wlan/boot_wlan

[ -e /dev/wlan ] && echo ON > /dev/wlan

if [ -e /dev/wmtWifi ]; then
	sleep 3
	echo 1 > /dev/wmtWifi
fi

exit 0
