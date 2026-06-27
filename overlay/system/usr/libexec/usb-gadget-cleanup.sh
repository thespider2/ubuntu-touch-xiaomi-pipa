#!/bin/sh
GADGET=/sys/kernel/config/usb_gadget/g1
if [ ! -d "$GADGET" ]; then
    exit 0
fi
echo "" > "$GADGET/UDC" 2>/dev/null
sleep 0.1
for c in "$GADGET"/configs/*/; do
    [ -d "$c" ] || continue
    for f in "$c"/functions/*; do
        [ -L "$f" ] && rm -f "$f" 2>/dev/null
    done
    for s in "$c"/strings/*/; do
        [ -d "$s" ] && rmdir "$s" 2>/dev/null
    done
    rmdir "$c" 2>/dev/null
done
for f in "$GADGET"/functions/*/; do
    [ -d "$f" ] && rmdir "$f" 2>/dev/null
done
for s in "$GADGET"/strings/*/; do
    [ -d "$s" ] && rmdir "$s" 2>/dev/null
done
rmdir "$GADGET" 2>/dev/null
