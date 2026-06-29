# Ubuntu Touch pipa install script
# Adapted from https://github.com/droidian-releng/android-recovery-flashing-template
# Zip payload: /data/ubuntu.img, /data/boot.img, /data/dtbo.img

OUTFD=/proc/self/fd/$1;

ui_print() { echo -e "ui_print $1\nui_print" > $OUTFD; }
error() { ui_print "$*"; exit 1; }

get_partitions() {
	if [ -f '/proc/bootconfig' ]; then
		current_slot=$(grep -oE 'androidboot\.slot_suffix[[:space:]]*=[[:space:]]*"_[ab]"' /proc/bootconfig | sed -E 's/[[:space:]]*=[[:space:]]*"/=/' | tr -d '"')
	fi

	if [ -z "$current_slot" ]; then
		current_slot=$(grep -o 'androidboot\.slot_suffix=_[a-b]' /proc/cmdline)
	fi
	case "${current_slot}" in
		"androidboot.slot_suffix=_a")
			target_boot_partition="boot_a"
			target_dtbo_partition="dtbo_a"
			;;
		"androidboot.slot_suffix=_b")
			target_boot_partition="boot_b"
			target_dtbo_partition="dtbo_b"
			;;
		"")
			target_boot_partition="boot"
			target_dtbo_partition="dtbo"
			;;
		*)
			error "Unknown slot suffix"
			;;
	esac
}

find_partition() {
	find /dev/block/by-name -name "$1" 2>/dev/null | head -n 1
}

flash_image() {
	label="$1"
	part_name="$2"
	image="$3"
	partition=$(find_partition "$part_name")
	if [ -z "${partition}" ]; then
		error "${label} partition ${part_name} not found"
	fi
	ui_print "Flashing ${label} to ${part_name}"
	dd if="${image}" of="${partition}" || error "Unable to flash ${label}"
	ui_print "${label} flashed"
}

mv /data/ubports-install/data/* /data/ 2>/dev/null || true

for f in ubuntu.img boot.img dtbo.img; do
	if [ ! -f "/data/${f}" ]; then
		error "${f} missing from zip payload"
	fi
done

get_partitions
flash_image "boot.img" "$target_boot_partition" /data/boot.img
flash_image "dtbo.img" "$target_dtbo_partition" /data/dtbo.img

ui_print "Preparing /data/ubuntu.img"
e2fsck -fy /data/ubuntu.img
resize2fs -f /data/ubuntu.img 8G

if [ ! -e /data/android-rootfs.img ]; then
	ln -sf /halium-system/var/lib/lxc/android/android-rootfs.img /data/android-rootfs.img 2>/dev/null || true
fi
