#!/bin/sh
# pipa: Hybris camera capture mmaps /dev/ashmem<uuid> via binder threads.
# Stock policy only allows /dev/ashmem (exact), so confined capture gets empty JPEGs.

PROF=/var/lib/apparmor/profiles/click_camera.ubports_camera_4.1.1
MARKER="# pipa: hybris camera capture buffers"
CACHE=/var/cache/apparmor

[ -f "$PROF" ] || exit 0

if ! grep -Fq "$MARKER" "$PROF" 2>/dev/null; then
	sed -i '/\/dev\/kgsl-3d0 rw,/d; /\/dev\/ion rw,/d; /\/dev\/dri\/ r,/d; /\/dev\/dri\/\*\* rw,/d; /\/dev\/ashmem\* rw,/d' "$PROF"

	sed -i "/# Description: Can access the camera(s)/,/\\/dev\\/{,binderfs\\/}hwbinder rw,/{
		/\\/dev\\/{,binderfs\\/}hwbinder rw,/a\\
  $MARKER\\
  /dev/ashmem{,*} rw,\\
  /dev/kgsl-3d0 rw,\\
  /dev/ion rw,\\
  /dev/dri/ r,\\
  /dev/dri/** rw,
	}" "$PROF"

	if ! grep -Fq '@{PROC}/@{pid}/mountinfo r,' "$PROF" 2>/dev/null; then
		sed -i '/@{PROC}\/\[0-9\]\*\/attr\/current r,/a\  @{PROC}/@{pid}/mountinfo r,' "$PROF"
	fi
fi

find "$CACHE" -name 'click_camera.ubports_camera_4.1.1' -delete 2>/dev/null || true
apparmor_parser -r --write-cache --cache-loc="$CACHE" "$PROF" 2>/dev/null || \
	apparmor_parser -r "$PROF" 2>/dev/null || true
exit 0
