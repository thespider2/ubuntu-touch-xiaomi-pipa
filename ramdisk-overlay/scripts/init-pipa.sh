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
SYSTEM_PART_ALTERNATE="/dev/block/bootdevice/by-name/system"

if [ -b "$SYSTEM_PART" ]; then
    systempart="$SYSTEM_PART"
elif [ -b "$SYSTEM_PART_ALTERNATE" ]; then
    systempart="$SYSTEM_PART_ALTERNATE"
fi

# Map userdata
USERDATA_PART="/dev/block/bootdevice/by-name/userdata"
if [ -b "$USERDATA_PART" ]; then
    export userdata="$USERDATA_PART"
fi

export systempart
