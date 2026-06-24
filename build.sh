#!/bin/bash
set -e

# Build wrapper for Xiaomi Pad 6 (pipa) Ubuntu Touch port
# Uses halium-generic-adaptation-build-tools

BUILD_DIR="${1:-build}"
WORK_DIR="${2:-workdir}"

if [ ! -d halium-generic-adaptation-build-tools ]; then
    echo "Cloning halium-generic-adaptation-build-tools..."
    git clone https://gitlab.com/halium/halium-generic-adaptation-build-tools.git
fi

exec ./halium-generic-adaptation-build-tools/build.sh "$BUILD_DIR" "$WORK_DIR"
