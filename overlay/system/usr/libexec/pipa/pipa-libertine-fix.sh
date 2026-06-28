#!/bin/sh
# pipa: Libertine on UT 26.04 (Python 3.14 + resolute base) needs two upstream fixes:
# 1) tarfile.extractall rejects absolute symlinks in ubuntu-base without filter=
# 2) maliit-inputcontext-gtk2 was dropped from resolute but libertine still installs it
set -eu

CHROOT=/usr/lib/python3/dist-packages/libertine/ChrootContainer.py
LIBERTINE=/usr/lib/python3/dist-packages/libertine/Libertine.py

if [ -f "$CHROOT" ] && ! grep -q 'filter="fully_trusted"' "$CHROOT"; then
	sed -i 's/tarball_tar.extractall(path=self.root_path)/tarball_tar.extractall(path=self.root_path, filter="fully_trusted")/' "$CHROOT"
fi

if [ -f "$LIBERTINE" ] && grep -q "maliit-inputcontext-gtk2" "$LIBERTINE"; then
	sed -i "/maliit-inputcontext-gtk2/d" "$LIBERTINE"
fi
