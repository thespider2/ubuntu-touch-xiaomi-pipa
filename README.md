# Ubuntu Touch for Xiaomi Pad 6 (pipa)

Ubuntu Touch port for the Xiaomi Pad 6 (codename: pipa) based on **Halium 13**.

## Status

| Feature      | Status |
|--------------|--------|
| Boot         | Untested |
| Display      | Untested |
| Touch        | Untested |
| WiFi         | Untested |
| Bluetooth    | Untested |
| Audio        | Untested |
| Camera       | Untested |
| Torch        | Untested |
| Battery      | Untested |
| Sensors      | Untested |
| Flash        | N/A (no SD card) |

## Prerequisites

- Xiaomi Pad 6 with unlocked bootloader
- [Android 13 firmware](https://xiaomifirmwareupdater.com/firmware/pipa/) installed
- ADB and fastboot tools
- Linux build environment (or use GitLab CI)

## Building locally

```bash
# Install dependencies
sudo apt install bc bison build-essential ca-certificates cpio curl flex \
  git kmod libssl-dev libtinfo5 python2 sudo unzip wget xz-utils img2simg jq

# Clone this repo
git clone https://gitlab.com/aymanrgab/ubuntu-touch-xiaomi-pipa
cd ubuntu-touch-xiaomi-pipa

# Build
./build.sh -b workdir
```

Artifacts will be in `out/`:
- `boot.img` — Kernel + initramfs
- `recovery.img` — UBports recovery
- `system.img` — Halium GSI + device overlay
- `dtbo.img` — Device Tree Blob Overlay

## Installation

> **WARNING**: This will replace your existing OS. Backup your data first.

### Flashing via fastboot

```bash
# Reboot to bootloader
adb reboot bootloader

# Determine active slot
fastboot getvar current-slot   # should print "a" or "b"

# Flash boot to opposite slot (e.g., if slot a is active)
fastboot flash boot_b out/boot.img    # or boot_a if slot b is active
fastboot flash dtbo_b out/dtbo.img    # or dtbo_a

# Set active slot to the one we just flashed
fastboot set_active b                 # or a

# Flash system and recovery
fastboot flash system out/system.img
fastboot flash recovery out/recovery.img

# Format data for first boot
fastboot format userdata

# Reboot
fastboot reboot
```

### First boot

First boot may take several minutes. After booting:
1. Follow the on-device setup wizard
2. Connect to WiFi
3. Update via System Settings -> Updates

## Resources

- **Kernel source**: [linux-android-xiaomi-pipa](https://github.com/aymanrgab/linux-android-xiaomi-pipa)
- **Droidian port** (base): [adaptation-droidian-pipa](https://github.com/aymanrgab/adaptation-droidian-pipa)
- **Device**: Xiaomi Pad 6 (pipa) — SM8250 (Snapdragon 870), 11" 2880x1800 144Hz, 6/8GB RAM

## Credits

- Based on the working [Droidian port](https://github.com/aymanrgab/droidian-images-xiaomi-pipa) by @aymanrgab
- UBports community for build tools and documentation
- Halium project for Android compatibility layer
