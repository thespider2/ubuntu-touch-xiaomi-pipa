#!/bin/bash
# Build a fastboot-flashable zip for pipa.
# Contains boot.img (with systempart cmdline), system.img, dtbo.img.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$(realpath "${1:-$HERE/out_devel}")"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

source "$HERE/deviceinfo"

BOOT_IMG="$OUT_DIR/boot.img"
SYSTEM_IMG="$OUT_DIR/system.img"
DTBO_IMG="$OUT_DIR/dtbo.img"

for f in "$BOOT_IMG" "$SYSTEM_IMG" "$DTBO_IMG"; do
    if [ ! -f "$f" ]; then
        echo "Missing: $f" >&2
        exit 1
    fi
done

# Copy images
cp "$BOOT_IMG" "$STAGING/boot.img"
cp "$SYSTEM_IMG" "$STAGING/system.img"
cp "$DTBO_IMG" "$STAGING/dtbo.img"

# Modify boot.img cmdline to add systempart
python3 "$HERE/scripts/modify-bootimg-cmdline.py" \
    "$STAGING/boot.img" "$STAGING/boot.img" \
    "systempart=/dev/mapper/system"

ZIP_NAME="ubuntu-touch-${deviceinfo_codename}-fastboot-flashable.zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"

rm -f "$ZIP_PATH"
(
    cd "$STAGING"
    zip -r9 "$ZIP_PATH" .
)

echo "Created $ZIP_PATH (boot.img + system.img + dtbo.img, systempart in cmdline)"
