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

## Device overlay

Files in `overlay/system/` are merged into the system image during build:

| Area | Config | Source |
|------|--------|--------|
| Display | `pipa-brightness-perm.service` — fix backlight node ownership for slider | Droidian adaptation |
| Display | `pipa-unblank-display.service` — unblank msm fb on boot | Droidian adaptation |
| Display | `devices/pipa.yaml` — Lomiri device config (tablet, 2880×1800, landscape) | Droidian adaptation |
| Audio | ALSA UCM2 for Qualcomm SM8250 (Aqstic WCD938x) | Droidian adaptation |
| Audio | `pulse/arm_droid_card_custom.pa` — PulseAudio droid card profile (s24le) | Droidian adaptation |
| WiFi | `pipa-boot-wlan.service` + `.path` — power on cnss via `/dev/wlan` at boot | Droidian adaptation |
| WiFi | `pipa-nm-wifi-config.service` — apply NM conf from `/usr/share/pipa/` at boot (rootfs `/etc` is ro) | pipa port |
| WiFi | `NetworkManager/conf.d/10-wifi-timeout.conf` — autoconnect/DHCP timeouts | Droidian adaptation |
| WiFi | `NetworkManager/conf.d/90-pipa-wifi.conf` — ignore duplicate cnss ifaces (wlan1, p2p0, wifi-aware0), disable P2P | Droidian adaptation |
| WiFi | `NetworkManager/dispatcher.d/90-pipa-networking` — remove netd rule 220, fix default route | Droidian adaptation |
| WiFi | `pipa-networking.service` — kernel-level netd rule 220 watcher | Droidian adaptation |
| Bluetooth | `bluetooth/main.conf` — Experimental=true | Droidian adaptation |
| Bluetooth | `bluetooth/input.conf` — ClassicBondedOnly=false for LE HID | Droidian adaptation |
| Bluetooth | `bluebinder.service.d/timeout.conf` — reduce timeout 120s→10s | Droidian adaptation |
| Camera | No CamX overrides — stock HAL tuning works best with AAL+ on Halium | pipa port |
| Torch | `pipa-flashlight-trigger.service` — torch0_trigger and sysfs permissions | Droidian adaptation |
| Input | `udev/rules.d/70-pipa.rules` — full Qualcomm SM8250 udev ruleset | Droidian adaptation |
| Power | `default/repowerd` — sysfs backlight, disable booster | Reference ports |
| USB | `default/usb-moded.d/device-specific-config.conf` — Xiaomi VID/PID | Reference ports |
| Android HAL | `gbinder.conf` — ApiLevel=33 | Reference ports |
| Android HAL | `halium-overlay/vendor/` — gralloc masks (force minigbm), mi_thermald disable | Reference ports |
| Display | `ubuntu-touch-session.d/android.conf` — GridUnit 20, DPR 2.0 | Reference ports |
| Systemd | `system.conf.d/faster_stop_timeout.conf` — 10s stop timeout | Droidian adaptation |
| Waydroid | `waydroid-binder.service` — binderfs for Android app support | Community |

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
2. Connect to WiFi
3. Update via System Settings -> Updates

## Resources

- **Kernel source**: [linux-android-xiaomi-pipa](https://github.com/aymanrgab/linux-android-xiaomi-pipa) (branch: droidian)
- **Droidian port** (base for configs): [adaptation-droidian-pipa](https://github.com/aymanrgab/adaptation-droidian-pipa)
- **Reference ports**: [google-eos](https://gitlab.com/ubports/porting/community-ports/android13/google-eos), [oneplus-salami](https://gitlab.com/ubports/porting/community-ports/android13/oneplus-11)
- **Device**: Xiaomi Pad 6 (pipa) — SM8250 (Snapdragon 870), 11" 2880×1800 144Hz, 6/8GB RAM

## Credits

- Based on the working [Droidian port](https://github.com/aymanrgab/droidian-images-xiaomi-pipa) by @aymanrgab
- UBports community for build tools and documentation
- Halium project for Android compatibility layer
