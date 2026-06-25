#!/bin/sh
set -e

IMAGES_DIR=""
for dir in /userdata /var/lib/lxc/android /data; do
    [ -d "$dir" ] && IMAGES_DIR="$dir" && break
done
: "${IMAGES_DIR:=/userdata}"

slot=""
for src in /proc/bootconfig /proc/cmdline; do
    s="$(grep -o 'androidboot\.slot_suffix[= ].*' "$src" 2>/dev/null | grep -o '[_ab]\+' || true)"
    [ -n "$s" ] && slot="$s" && break
done

PARTS="vendor odm"

for part in $PARTS; do
    img="$IMAGES_DIR/$part.img"
    [ -f "$img" ] || { echo "$part: $img not found, skipping"; continue; }

    existing=""
    for d in /dev/disk/by-partlabel /dev/block/by-partlabel; do
        sym="$d/$part"
        [ -L "$sym" ] && existing="$(readlink -f "$sym")" && break
    done

    if [ -n "$existing" ] && losetup "$existing" 2>/dev/null | grep -qF "$img"; then
        echo "$part: already loop-mounted as $existing -> $img"
        continue
    fi

    kill_dynpart() {
        for dm in "$part" "$part$slot"; do
            for suffix in "" "_a" "_b"; do
                target="dynpart-${dm}${suffix}"
                for mp in /vendor /android/vendor /var/lib/lxc/android/rootfs/vendor; do
                    mountpoint -q "$mp" 2>/dev/null && umount -l "$mp" 2>/dev/null || true
                done
                dmsetup remove "$target" 2>/dev/null && echo "$part: removed stale $target" || true
            done
        done
    }

    kill_dynpart

    loop="$(losetup -f --show "$img")"
    echo "$part: $loop -> $img"

    kill_dynpart

    mkdir -p /dev/disk/by-partlabel /dev/block/by-partlabel
    for link_dir in /dev/disk/by-partlabel /dev/block/by-partlabel; do
        ln -sf "$loop" "$link_dir/$part"
        [ -n "$slot" ] && ln -sf "$loop" "$link_dir/${part}${slot}"
    done
done
