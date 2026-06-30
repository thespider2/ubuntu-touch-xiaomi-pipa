#!/system/bin/sh
# Loads the touchscreen driver for Xiaomi Pad 6 (pipa)

MODULES=/lib/modules

focaltech_node=$(echo /proc/device-tree/*/i2c@*/focaltech@*)
focaltech_spi_node=$(echo /proc/device-tree/*/spi@*/focaltech@*)
synaptics_node=$(echo /proc/device-tree/*/i2c@*/synaptics@*)

if [ -d "$focaltech_node" ] || [ -d "$focaltech_spi_node" ]; then
    for mod in "$MODULES/"focaltech*; do
        [ -f "$mod" ] && insmod "$mod"
    done
elif [ -d "$synaptics_node" ]; then
    for mod in "$MODULES/"synaptics*; do
        [ -f "$mod" ] && insmod "$mod"
    done
fi
