# Mac Mini Dual Boot Project

## Overview

Goal: dual-boot macOS and Fedora KDE Plasma on a 2018 Mac mini while preserving the current Fedora setup enough to recover quickly if needed.

Current priority: complete disk resize and macOS reinstall path quickly.

## Current Status

- Fedora currently occupies nearly the full internal SSD.
- File-level backup/automation is working and usable for rapid reinstall/config recovery.
- Existing baremetal image is currently treated as non-restorable until regenerated and validated.
- A resize guide exists: `fedora_resize_to_320gib.md`.

## System Specs

- Model: Apple Mac mini (Macmini8,1, 2018)
- CPU: Intel Core i7-8700B (6 cores / 12 threads)
- RAM: 16 GiB
- GPU: Intel UHD Graphics 630
- T2: Apple iBridge (T2 present)
- Storage: Apple NVMe SSD 512 GB (APPLE SSD AP0512M)
- OS: Fedora Linux 43 KDE Plasma
- Kernel: `6.18.7-210.t2.fc43.x86_64`
- Bootloader: GRUB 2.12
- Internal layout: EFI (`/boot/efi`, vfat), `/boot` (ext4), LUKS -> Btrfs (`/root`, `/home` subvols)

## Environment Inventory

### Hardware

- Mac mini (project machine)
- 64 GB USB drive
- 256 GB Ventoy USB (includes Fedora live + Rescuezilla)
- 2020 MacBook Pro (no wipe)
- 2015 Razer Blade (optional test machine)
- 2 TB external SSD on TrueNAS (`veyDisk`)
- 5 TB external HDD on TrueNAS (`oyPool`)

### Software/Systems

- Backup launcher script: `~/bin/rsync_to_truenas.sh`
- Repo scripts: `scripts/rsync_to_truenas.sh`, `scripts/auto_filelevel_to_truenas.sh`, `scripts/truenas_archive_rotate.sh`
- TrueNAS hosted in Proxmox (VMID `100`)
- Proxmox alias: `ssh rb1-pve`

## Problem Plan

### Problem 1: Planning, Backup, and Testing

1. Confirm macOS reinstall approach.
2. Validate recovery path before disk changes.
3. Resize Fedora/LUKS/Btrfs to free space for macOS.
4. Preserve enough metadata/package state to rebuild quickly if needed.

#### Working Backup Conclusions

1. File-level backup is currently the practical recovery path.
2. Baremetal image is present but currently not trusted for restore.
3. Keep moving forward with dualboot timeline; regenerate baremetal later if needed.

#### Restore Instructions (Current)

1. Use file-level restore path first.
2. Priority restore targets:
- `/etc/fstab`
- `/etc/crypttab`
- `/boot/grub2/grub.cfg`
- `/boot/loader/entries/*`
- `/home/*`
3. Treat baremetal restore as unavailable until revalidated.

### Problem 2: Reinstall macOS

1. Proceed only after accepting current backup risk profile.
2. Install macOS into newly freed disk space.
3. Confirm macOS boots and core apps required for school work are operational.

### Problem 3: Final Dualboot State

1. Ensure Fedora still boots after partition changes.
2. Reinstall/repair Fedora only if necessary.
3. Restore settings/data from file-level backup if required.

## Notes

- Optional optimization: resumable disk imaging (`ddrescue`) for future baremetal runs.
- Optional optimization: 2.5/5/10 GbE upgrade for faster large backup jobs.
