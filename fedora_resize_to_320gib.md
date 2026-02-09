# Fedora Shrink Plan (Target: 320 GiB Fedora, free space for macOS)

Date: 2026-02-09

## Why this target
- Fedora currently uses a 463.3 GiB LUKS partition (`/dev/nvme0n1p3`).
- We are shrinking Fedora to 320 GiB to leave roughly ~140 GiB free for macOS/APFS.
- This is a moderate shrink compared with more aggressive options.

## Important context
- File-level backups are usable for reinstall/config restore workflows, but integrity is not treated as fully proven for full-system disaster recovery.
- Current baremetal image is present but failed GPT structural checks and must be treated as non-restorable.

## Exact values for this disk
From current layout (`/dev/nvme0n1p3` starts at sector `5425152`):
- LUKS mapped target size (320 GiB): `671088640` sectors (512-byte sectors)
- LUKS header offset allowance observed on this system: `32768` sectors
- Partition target size: `671121408` sectors
- New partition end sector for `p3` in 512-byte sector math: `676546559`
- `parted unit s` sector size on this machine is `4096B`, so the value to actually pass to `parted` is `84568319`

## Required environment
Do this from Fedora Live USB (NOT from installed Fedora):
- Ventoy -> Fedora Live
- Open terminal
- Ensure AC power is connected

## Step-by-step commands

1. Unlock LUKS and mount btrfs root subvolume:
```bash
sudo cryptsetup luksOpen /dev/nvme0n1p3 fedora_crypt
sudo mkdir -p /mnt/fedora
sudo mount -o subvol=/root /dev/mapper/fedora_crypt /mnt/fedora
```

2. Shrink btrfs filesystem to 320 GiB:
```bash
sudo btrfs filesystem resize 320G /mnt/fedora
sudo umount /mnt/fedora
```

3. Shrink mapped LUKS device to 320 GiB (in sectors):
```bash
sudo cryptsetup resize --size 671088640 fedora_crypt
sudo cryptsetup close fedora_crypt
```

4. Shrink partition 3 to computed end sector:
```bash
sudo parted /dev/nvme0n1 unit s print
sudo parted /dev/nvme0n1 unit s resizepart 3 84568319
sudo partprobe /dev/nvme0n1
```

5. Re-open and verify:
```bash
sudo cryptsetup luksOpen /dev/nvme0n1p3 fedora_crypt
sudo mount -o subvol=/root /dev/mapper/fedora_crypt /mnt/fedora
sudo btrfs filesystem usage /mnt/fedora
sudo lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT /dev/nvme0n1
```

6. Optional quick integrity checks after reboot into installed Fedora:
```bash
sudo btrfs scrub start -Bd /
sudo dmesg -T | tail -n 120
```

## Stop conditions
Stop immediately and do not continue if:
- `btrfs filesystem resize 320G` fails
- `cryptsetup resize` fails
- `parted resizepart` errors
- Any command reports I/O errors

If any stop condition occurs, capture full terminal output and review before proceeding.
