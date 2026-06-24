#!/sbin/sh

# Set up A/B slot detection for Xiaomi Pad 6
# The bootloader passes androidboot.slot_suffix in cmdline

SLOT=$(cat /proc/cmdline | tr ' ' '\n' | grep androidboot.slot_suffix | cut -d= -f2)
if [ -z "$SLOT" ]; then
    SLOT="_a"
fi

# Export for init scripts
export SLOT_SUFFIX="$SLOT"

# Map system partition based on slot
SYSTEM_PART="/dev/block/bootdevice/by-name/system$SLOT"
if [ -b "$SYSTEM_PART" ]; then
    export systempart="$SYSTEM_PART"
fi
