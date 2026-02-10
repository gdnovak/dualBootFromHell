# macOS Install Solo Runbook (No Live Codex Needed)

Use this guide directly from GitHub on the project machine.
Goal: install macOS into free space and keep Fedora bootable/default.

## Known Machine Context

- Target machine: 2018 Mac mini (Intel, T2)
- Current Linux state: Fedora on `/dev/nvme0n1p3` (LUKS+Btrfs), already shrunk to 320G
- Important rule: do **not** erase whole disk in Disk Utility

## Before You Reboot (Fedora)

1. Save preflight boot metadata (for quick rollback checks):

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$HOME/preflight_snapshots/$STAMP"
mkdir -p "$OUT"

sudo efibootmgr -v > "$OUT/efibootmgr-v.txt"
lsblk -f > "$OUT/lsblk-f.txt"
sudo blkid > "$OUT/blkid.txt"
sudo cp -a /boot/efi/EFI "$OUT/EFI-backup"

echo "Saved snapshot in: $OUT"
```

2. Unplug non-essential USB gear:
- Keep only keyboard, display, installer/recovery path, and power.
- Avoid dock/hub during install to reduce boot/input weirdness.

3. Power stability:
- Use known-good outlet and surge protection.
- Do not interrupt power during install/firmware updates.

## Install macOS in Recovery

1. Reboot and hold `Option` (Alt) to open Startup Manager.
2. Enter Recovery (`Options`/Recovery entry).
3. Open Disk Utility and enable `View -> Show All Devices`.
4. Confirm Linux/Fedora partitions are still present.
5. Use only free space to create APFS target (container/volume).
6. Run `Reinstall macOS` and select that new APFS target.
7. Let installation complete.

## Set Default Startup Back to Fedora

After macOS finishes, it may set itself as default. This is expected.

### Fastest method (Startup Manager)

1. Reboot and hold `Option`.
2. Select Fedora/EFI Boot entry.
3. Hold `Control` and press `Enter` (or click the up-arrow) to set it as default startup disk.

### Fedora method (explicit NVRAM order)

Boot Fedora once (via Startup Manager if needed), then:

```bash
sudo efibootmgr -v
```

Find Fedora Boot#### (example: `Boot0000* Fedora`) and set it first:

```bash
sudo efibootmgr -o 0000
```

If there are multiple entries, place Fedora first, then others:

```bash
sudo efibootmgr -o 0000,0080,0081
```

Reboot and verify Fedora is now default.

## Quick Validation Checklist

1. Startup Manager shows both macOS and Fedora/EFI entry.
2. Fedora boots with normal mounts:
- `/`
- `/home`
- `/boot`
- `/boot/efi`
3. macOS boots and basic network/login works.

## If Fedora Does Not Appear

1. Use Startup Manager (`Option`) and try `EFI Boot`.
2. If still missing, boot Fedora Live USB and repair from backup/runbooks:
- `restore_from_backup.md`
- `macos_recovery_post_resize.md`

## About Using 2020 MacBook Pro as Safety Net

Yes, this is a good fallback path for T2 firmware recovery only.
It does **not** replace normal Recovery install; it is for rescue if firmware/boot gets stuck.
If needed, use Apple Configurator DFU revive/restore from the MacBook Pro.
