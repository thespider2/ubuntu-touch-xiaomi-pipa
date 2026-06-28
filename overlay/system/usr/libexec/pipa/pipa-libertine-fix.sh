#!/bin/sh
# pipa: Libertine on UT 26.04 (Python 3.14 + resolute base) needs upstream fixes:
# 1) tarfile.extractall rejects absolute symlinks in ubuntu-base without filter=
# 2) maliit-inputcontext-gtk2 was dropped from resolute but libertine still installs it
# 3) copying host ubports.list into chroots pulls snapd, which fails (setcap missing)
set -eu

CHROOT=/usr/lib/python3/dist-packages/libertine/ChrootContainer.py
LIBERTINE=/usr/lib/python3/dist-packages/libertine/Libertine.py

if [ -f "$CHROOT" ] && ! grep -q 'filter="fully_trusted"' "$CHROOT"; then
	sed -i 's/tarball_tar.extractall(path=self.root_path)/tarball_tar.extractall(path=self.root_path, filter="fully_trusted")/' "$CHROOT"
fi

if [ -f "$LIBERTINE" ] && grep -q "maliit-inputcontext-gtk2" "$LIBERTINE"; then
	sed -i "/maliit-inputcontext-gtk2/d" "$LIBERTINE"
fi

if [ -f "$CHROOT" ] && ! grep -q "startswith('ubports')" "$CHROOT"; then
	sed -i "s/if file.startswith('ubuntu'):/if file.startswith('ubuntu') or file.startswith('ubports'):/" "$CHROOT"
fi

# Repair existing containers broken by ubports snapd (blocks all apt installs).
for rootfs in /home/phablet/.cache/libertine-container/*/rootfs; do
	[ -d "$rootfs/var/lib/dpkg" ] || continue
	rm -f "$rootfs/etc/apt/sources.list.d/ubports.list"
	if dpkg --root="$rootfs" -l snapd 2>/dev/null | grep -qE '^i[FUR]'; then
		dpkg --root="$rootfs" --force-all --remove snapd 2>/dev/null || true
	fi
done
