#!/usr/bin/env python3
"""Modify the kernel cmdline in an Android boot image (header v3)."""
import struct
import sys

BOOT_MAGIC = b'ANDROID!'
BOOT_ARGS_SIZE = 512
BOOT_EXTRA_ARGS_SIZE = 1024
CMDLINE_OFFSET = 44


def modify_cmdline(boot_img_path, output_path, append):
    with open(boot_img_path, 'rb') as f:
        data = bytearray(f.read())

    if data[:8] != BOOT_MAGIC:
        print(f"Not a valid Android boot image (bad magic)", file=sys.stderr)
        sys.exit(1)

    header_version = struct.unpack_from('<I', data, 40)[0]
    if header_version != 3:
        print(f"Unsupported header version: {header_version} (only v3)", file=sys.stderr)
        sys.exit(1)

    cmdline_buf = data[CMDLINE_OFFSET:CMDLINE_OFFSET + BOOT_ARGS_SIZE + BOOT_EXTRA_ARGS_SIZE]
    cmdline = cmdline_buf.rstrip(b'\x00').decode('ascii', errors='replace').strip()

    if append not in cmdline:
        cmdline = (cmdline + ' ' + append) if cmdline else append
        print(f"cmdline: {cmdline}")

    encoded = cmdline.encode('ascii')
    buf_size = BOOT_ARGS_SIZE + BOOT_EXTRA_ARGS_SIZE
    if len(encoded) >= buf_size:
        print(f"Cmdline too long ({len(encoded)} >= {buf_size})", file=sys.stderr)
        sys.exit(1)

    new_buf = encoded + b'\x00' * (buf_size - len(encoded))
    data[CMDLINE_OFFSET:CMDLINE_OFFSET + buf_size] = new_buf

    with open(output_path, 'wb') as f:
        f.write(data)
    print(f"Wrote {output_path}")


if __name__ == '__main__':
    if len(sys.argv) != 4:
        print(f"Usage: {sys.argv[0]} <input_boot.img> <output_boot.img> <append_cmdline>")
        sys.exit(1)
    modify_cmdline(sys.argv[1], sys.argv[2], sys.argv[3])
