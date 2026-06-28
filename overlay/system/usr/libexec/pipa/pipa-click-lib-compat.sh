#!/bin/sh
# pipa: Preinstalled clicks (OpenStore) link against old SONAMEs; UT 26.04 ships newer libs.
set -eu

LIB=/usr/lib/aarch64-linux-gnu

link_if_missing() {
	target=$1
	source=$2
	[ -e "$LIB/$source" ] || return 0
	[ -e "$LIB/$target" ] && return 0
	ln -sf "$source" "$LIB/$target"
}

link_if_missing libxml2.so.2 libxml2.so.16
link_if_missing libsnapd-qt.so.1 libsnapd-qt-2.so.1
link_if_missing libsnapd-glib.so.1 libsnapd-glib-2.so.1
