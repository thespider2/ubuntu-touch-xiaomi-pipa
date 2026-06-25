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

## Device overlay

The `overlay/system/` directory contains device-specific configs overlaid onto the
Halium GSI during system image build:

| Area | Config | Source |
|------|--------|--------|
| Display | `pipa-brightness-perm.service` — fix brightness node ownership for slider | Droidian adaptation |
| Display | `pipa-unblank-display.service` — unblank msm fb on boot | Droidian adaptation |
| Audio | ALSA UCM2 for Qualcomm SM8250 (Aqstic WCD938x) | Droidian adaptation |
| Audio | `arm_droid_card_custom.pa` — PulseAudio droid card profile (s24le) | Droidian adaptation |
| WiFi | `10-wifi-timeout.conf` — cnss driver timeout (60s), MAC randomization off | Droidian adaptation |
| WiFi | `90-pipa-wifi.conf` — ignore duplicate wlan1 interface | Droidian adaptation |
| WiFi | `90-pipa-networking` — NM dispatcher: remove netd rule 220, add missing default route | Droidian adaptation |
| WiFi | `pipa-networking.service` — kernel-level netd rule 220 watcher | Droidian adaptation |
| Bluetooth | `main.conf` — experimental features | Droidian adaptation |
| Bluetooth | `input.conf` — ClassicBondedOnly=false for LE HID | Droidian adaptation |
| Bluetooth | `timeout.conf` — reduce bluebinder timeout 120s→10s | Droidian adaptation |
| Camera | `gstdroidcamsrcquirks.conf` — HDR, ZSL, high-quality edge/noise reduction | Droidian adaptation |
| Camera | `camxoverridesettings.txt` — Qualcomm camera tuning (HDR, multi-frame NR, 95% JPEG) | Droidian adaptation |
| Torch | `pipa-flashlight-trigger.service` — set torch0_trigger on boot | Droidian adaptation |
| Power | `30-suspend.conf` — disable elogind suspend/lid handling (repowerd manages it) | Droidian adaptation |
| Input | `70-pipa.rules` — full udev ruleset for Qualcomm SM8250 (KGSL, SMD, camera, modem, audio, etc.) | Droidian adaptation |
| GPU | KGSL, genlock, HAB kernel node permissions in udev rules | Droidian adaptation |
| Thermal | `init.mi_thermald.rc` — override to disable mi_thermald in vendor overlay | Droidian adaptation |
| Systemd | `faster_stop_timeout.conf` — reduce DefaultTimeoutStopSec to 10s | Droidian adaptation |
| Flashing | `10-pipa-slot.conf` — flash-bootimage A/B slot auto-detection | Droidian adaptation |
| Waydroid | `waydroid-binder.service` — mount binderfs for Android app support | Community |

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
- **Droidian port** (base for configs): [adaptation-droidian-pipa](https://github.com/aymanrgab/adaptation-droidian-pipa)
- **Device**: Xiaomi Pad 6 (pipa) — SM8250 (Snapdragon 870), 11" 2880x1800 144Hz, 6/8GB RAM

## Credits

- Based on the working [Droidian port](https://github.com/aymanrgab/droidian-images-xiaomi-pipa) by @aymanrgab
- UBports community for build tools and documentation
- Halium project for Android compatibility layer
