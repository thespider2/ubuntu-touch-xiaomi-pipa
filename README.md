# Ubuntu Touch for Xiaomi Pad 6 (pipa)

Ubuntu Touch port for the Xiaomi Pad 6 (codename: pipa) based on **Halium 13**.

## Status

| Feature      | Status |
|--------------|--------|
| Boot         | Working |
| Display      | Working |
| Touch        | Working |
| WiFi         | Working |
| Bluetooth    | Working |
| Audio        | Working (4-speaker ALSA/UCM + droid HAL) |
| Camera       | Working (AAL+; photo quality below stock MIUI) |
| OpenStore    | Working |
| Torch        | Working |
| Battery      | Working |
| Sensors      | Working |

Tested on UT 26.04 (Halium 13) with kernel from [linux-android-xiaomi-pipa](https://github.com/aymanrgab/linux-android-xiaomi-pipa) (`droidian` branch).

## Device overlay

Files in `overlay/system/` are merged into the system image during build:

| Area | Config | Notes |
|------|--------|-------|
| Display | `pipa-brightness-perm.service` | Backlight node ownership for slider |
| Display | `pipa-unblank-display.service` | Unblank msm fb on boot |
| Display | `devices/pipa.yaml` | Lomiri tablet config (2880×1800, landscape) |
| Display | `ubuntu-touch-session.d/android.conf` | GridUnit 20, DPR 2.0 |
| Audio | ALSA UCM2 `QUALCOMM-SM8250/` | 4-speaker Aqstic WCD938x routing |
| Audio | `etc/pulse/touch.pa` | PulseAudio 4-channel upmix for all speakers |
| Audio | `pulse/droid_card_custom.pa` | Droid HAL card profile (s24le) |
| Audio | `pipa-droid-audio.conf` | PulseAudio droid HAL env at session start |
| WiFi | `pipa-boot-wlan.service` + `.path` | Power on cnss via `/dev/wlan` at boot |
| WiFi | `pipa-nm-wifi-config.service` | Copy NM conf to `/run/` (rootfs `/etc` is ro) |
| WiFi | `NetworkManager/conf.d/` | Timeouts, ignore duplicate cnss ifaces, stable autoconnect |
| WiFi | `pipa-networking.service` + dispatcher | netd rule 220 / default route fix |
| Bluetooth | `bluetooth/main.conf`, `input.conf` | Experimental mode, LE HID |
| Bluetooth | `bluebinder.service.d/timeout.conf` | Reduce start timeout 120s→10s |
| Camera | `libexiv2.so.0.27.6` | Camera app QML plugin needs exiv2 0.27 SONAME |
| Camera | `pipa-fix-camera-apparmor.service` | Hybris ashmem/GPU rules for confined capture |
| Camera | Stock HAL (no CamX overrides) | CamX tuning breaks AAL+ preview on Halium |
| Apps | `pipa-click-lib-compat.service` | OpenStore: `libxml2.so.2`, `libsnapd-qt.so.1` compat |
| Torch | `pipa-flashlight-trigger.service` | torch0_trigger sysfs permissions |
| Input | `udev/rules.d/70-pipa.rules` | Qualcomm SM8250 device permissions |
| Power | `default/repowerd` | Sysfs backlight, disable booster |
| USB | `usb-moded` cleanup + device VID/PID | Gadget cleanup on disconnect |
| Android HAL | `gbinder.conf` | ApiLevel=33 |
| Android HAL | `halium-overlay/vendor/` | mi_thermald disable, vendor audio HAL |
| Systemd | `faster_stop_timeout.conf` | 10s stop timeout |

## Known limitations

- **Camera quality** is functional but does not match MIUI (no Xiaomi AI/ISP stack on UT).
- **Preinstalled clicks** (camera, OpenStore) were built against older library SONAMEs; the overlay ships compat libraries/symlinks until UBports rebases the apps.
- **Kernel** includes a netd route fix (`0.0.0.0` gateway rejection) for WiFi on pipa.

## Prerequisites

- Xiaomi Pad 6 with unlocked bootloader
- [Android 11 firmware](https://xiaomifirmwareupdater.com/firmware/pipa/) installed
- ADB and fastboot tools
- Linux build environment (or use GitLab CI)

## Building locally

```bash
# Install dependencies
sudo apt install bc bison build-essential ca-certificates cpio curl flex \
  git kmod libssl-dev libtinfo5 python3 sudo unzip wget xz-utils img2simg jq

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
2. Connect to WiFi (hidden networks: pin BSSID in NM settings for faster connect)
3. Update via System Settings → Updates

## Resources

- **Kernel source**: [linux-android-xiaomi-pipa](https://github.com/aymanrgab/linux-android-xiaomi-pipa) (branch: `droidian`)
- **Droidian port** (base for configs): [adaptation-droidian-pipa](https://github.com/aymanrgab/adaptation-droidian-pipa)
- **Reference ports**: [google-eos](https://gitlab.com/ubports/porting/community-ports/android13/google-eos), [oneplus-salami](https://gitlab.com/ubports/porting/community-ports/android13/oneplus-11)
- **Device**: Xiaomi Pad 6 (pipa) — SM8250 (Snapdragon 870), 11" 2880×1800 144Hz, 6/8GB RAM

## Credits

- Based on the working [Droidian port](https://github.com/aymanrgab/droidian-images-xiaomi-pipa) by @aymanrgab
- UBports community for build tools and documentation
- Halium project for Android compatibility layer
