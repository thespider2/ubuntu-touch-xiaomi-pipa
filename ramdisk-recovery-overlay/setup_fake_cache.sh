#!/system/bin/sh
# Mounts /data and bind-mounts /data/cache to /cache for recovery OTA operations

MAX_RETRIES=3
RETRY=0

while [ $RETRY -lt $MAX_RETRIES ]; do
    if mount /data; then
        mkdir -p /data/cache
        if mount --bind /data/cache /cache; then
            setprop halium.datamount.done 1
            exit 0
        fi
    fi
    RETRY=$((RETRY + 1))
    sleep 1
done

setprop halium.datamount.done 1
exit 1
