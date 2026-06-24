#!/bin/bash
set -e

# Prepare fake OTA for Xiaomi Pad 6 (pipa)
# This script creates the necessary files for the UBports installer

OUT_DIR="${1:-out}"
DEVICE="pipa"
BUILD_NUMBER="${2:-$(date +%Y%m%d)}"

mkdir -p "$OUT_DIR/$DEVICE"

# Copy boot image
if [ -f "out/boot.img" ]; then
    cp out/boot.img "$OUT_DIR/$DEVICE/boot.img"
fi

# Copy recovery image
if [ -f "out/recovery.img" ]; then
    cp out/recovery.img "$OUT_DIR/$DEVICE/recovery.img"
fi

# Copy system image
if [ -f "out/system.img" ]; then
    cp out/system.img "$OUT_DIR/$DEVICE/system.img"
fi

# Copy DTBO image
if [ -f "out/dtbo.img" ]; then
    cp out/dtbo.img "$OUT_DIR/$DEVICE/dtbo.img"
fi

# Create version file
echo "$BUILD_NUMBER" > "$OUT_DIR/$DEVICE/version.txt"

echo "Fake OTA prepared at $OUT_DIR/$DEVICE"
