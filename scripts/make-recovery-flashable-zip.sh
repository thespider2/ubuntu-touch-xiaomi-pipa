#!/bin/bash
# Build a TWRP/OrangeFox-compatible recovery flashable zip for pipa.
# Payload: ubuntu.img, boot.img, dtbo.img only.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$(realpath "${1:-$HERE/out_devel}")"
TEMPLATE="$HERE/scripts/recovery-flashable"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

# shellcheck source=/dev/null
source "$HERE/deviceinfo"

ZIP_NAME="ubuntu-touch-${deviceinfo_codename}-recovery-flashable.zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"

if [ ! -d "$TEMPLATE" ]; then
	echo "Missing template: $TEMPLATE" >&2
	exit 1
fi

UBUNTU_IMG="$OUT_DIR/ubuntu.img"
if [ ! -f "$UBUNTU_IMG" ] && [ -f "$OUT_DIR/rootfs.img" ]; then
	UBUNTU_IMG="$OUT_DIR/rootfs.img"
fi

for required in "$UBUNTU_IMG" "$OUT_DIR/boot.img" "$OUT_DIR/dtbo.img"; do
	if [ ! -f "$required" ]; then
		echo "Missing required image: $required" >&2
		exit 1
	fi
done

mkdir -p "$STAGING/data" "$STAGING/tools" "$STAGING/META-INF/com/google/android"

cp -a "$TEMPLATE/META-INF/com/google/android/"* "$STAGING/META-INF/com/google/android/"
cp "$TEMPLATE/setup.sh" "$STAGING/"
cp "$TEMPLATE/tools/busybox" "$STAGING/tools/"
chmod 755 "$STAGING/tools/busybox" "$STAGING/setup.sh"

cp "$UBUNTU_IMG" "$STAGING/data/ubuntu.img"
cp "$OUT_DIR/boot.img" "$STAGING/data/boot.img"
cp "$OUT_DIR/dtbo.img" "$STAGING/data/dtbo.img"

rm -f "$ZIP_PATH"
(
	cd "$STAGING"
	zip -r9 "$ZIP_PATH" .
)

echo "Created $ZIP_PATH (ubuntu.img, boot.img, dtbo.img)"
