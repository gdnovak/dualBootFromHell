# Log of Dualboot Project

## Instructions for Codex
- See Readme first for writing instructions.
- Log data here extensively such that at any time, if a new codex session with no understanding of this project were to look at this log, it will know what stage of the project we are at, what has been done, etc.
- This file is all yours, although I may add a few things here and there. Otherwise, use this as your memory.
  - **That is not a suggestion** after each action we take, if something, even a minor detail of our plan *changed* then it is to be logged.
  - If it was something that will be utilized in later steps you **must** document what you did, why, and any info a new session codex agent would need to make use of the changes (**regardless of whether they are changes to system, this repository - the readme especially, or changes in how much progress we have made.**)
- The section below is the log. You may format it however you like. Be SURE to read the ENTIRE README.md, as well as these instructions before beginning.

## LOG

- 2026-02-06 00:17 EST (Codex): Added full system specs to README.md. Key facts: Apple Mac mini (Macmini8,1, 2018), Intel i7-8700B, 16 GiB RAM, Intel UHD 630, Apple NVMe 512 GB, Fedora 43 KDE (Wayland), kernel 6.18.7-210.t2.fc43.x86_64, GRUB 2.12, Secure Boot disabled, internal disk layout EFI (/boot/efi, vfat) + /boot (ext4) + LUKS -> Btrfs (root + /home; label "fedora"). Note: macOS is deleted; Fedora owns the entire disk; EFI still has stale Mac OS X entries. Backup details still pending (rsync to TrueNAS via /home/tdj/bin/rsync_to_truenas.sh).
- 2026-02-06 00:23 EST (Codex): Workflow decision: Codex will make local commits but will not push to GitHub; user will run `git push` manually. Codex should remind user to push regularly.
- 2026-02-06 00:33 EST (Codex): GitHub auth fixed by switching to SSH; `ssh -T git@github.com` succeeded. Test file `deleteIfYouSee.md` was created, committed, pushed, deleted on GitHub, and local repo synced via `git pull --ff-only`. Repository sync workflow confirmed working.
- 2026-02-06 00:46 EST (Codex): If MacOS reinstall does **NOT** require a *full* wipe, plan path is: backup + restore test first, then shrink Fedora (LUKS+Btrfs) to free space, then install macOS into new APFS space via Recovery, then fix boot flow. No changes executed yet.
- 2026-02-06 06:25 EST (Codex): Added target macOS size to README.md: 200 GB (OS + Office + 100 GB spare).
- 2026-02-06 14:17 EST (Codex): User updated target macOS size to 300 GB (supersedes 200 GB). README update pending user approval per instruction.
- 2026-02-06 15:17 EST (Codex): Updated /home/tdj/bin/rsync_to_truenas.sh to use SSH host alias "truenas" (new key) instead of a hardcoded key path; no changes needed to the TrueNAS Backup Now desktop entry.
- 2026-02-06 15:31 EST (Codex): Added baremetal option (3) to /home/tdj/bin/rsync_to_truenas.sh. It prompts for confirmation, asks for source disk, clears /mnt/veyDisk/fedoraBackups/baremetalImage, and streams a full-disk image to NAS.
- 2026-02-06 15:40 EST (Codex): Fixed rsync_to_truenas.sh to use explicit IP/user and absolute key/known_hosts paths so sudo rsync uses the correct SSH identity (host alias was not available under sudo).
- 2026-02-06 16:03 EST (Codex): Updated baremetal option to show source disk size, warn about deletion, prompt (y/n), and short-circuit before normal rsync backups.
- 2026-02-06 16:10 EST (Codex): Baremetal option now auto-detects the source disk from root mount, asks for confirmation, and no longer prompts for manual device entry.
- 2026-02-06 16:18 EST (Codex): Fixed baremetal auto-detection to handle /dev/mapper root sources by querying lsblk on the mapper device.
- 2026-02-06 16:26 EST (Codex): Improved baremetal auto-detect: strip btrfs subvol suffix, prefer /boot/efi device to identify disk, then fall back to root mapper.
- 2026-02-06 16:35 EST (Codex): Fixed baremetal auto-detect to walk parent devices to the top-level disk (avoids selecting partition like nvme0n1p3).
- 2026-02-06 16:46 EST (Codex): Reworked baremetal auto-detect to climb to top-level disk by device type and prefer /boot/efi or /boot mount sources.
- 2026-02-06 16:58 EST (Codex): Revised baremetal auto-detect to use lsblk mountpoints and a single-disk fallback; avoids findmnt edge cases.
- 2026-02-06 17:09 EST (Codex): Adjusted baremetal auto-detect to derive parent disk from /boot/efi (or /boot) partition via lsblk PKNAME, matching user’s suggested approach.
- 2026-02-06 17:20 EST (Codex): Added fallback in baremetal auto-detect to use findmnt if lsblk mountpoint parsing returns empty.
- 2026-02-06 17:31 EST (Codex): Baremetal detection now succeeds via /boot/efi -> PKNAME; added sudo prompt (sudo -v) and sudo blockdev for disk size to avoid permission errors.
- 2026-02-06 17:41 EST (Codex): Fixed baremetal dataset path to /mnt/veyDisk/fedoraBackups/bareMetalImage and adjusted rm glob quoting to avoid zsh "no matches found".
- 2026-02-06 17:48 EST (Codex): Replaced remote rm glob with find -delete to avoid zsh nonomatch errors when directory is empty.
- 2026-02-06 17:36 EST (Codex): Added README sections for resumable baremetal imaging (ddrescue) and optional optimizations list.
- 2026-02-06 18:20 EST (Codex): Baremetal image completed successfully. Source: /dev/nvme0n1. Destination: /mnt/veyDisk/fedoraBackups/bareMetalImage/macmini-2018-baremetal-2026-02-06_16-59-43.img. Size copied: 500,296,581,120 bytes (466 GiB). Duration ~4826s @ ~104 MB/s.
- 2026-02-06 18:40 EST (Codex): Agreed backup structure plan. SSD (veyDisk): completeFileLevel/current + manual/01..02 + meta; bareMetalImage/current + meta. HDD (oyPool): completeFileLevel/daily/01..07, monthly/01..12, meta; bareMetalArchive/current, previous, monthly, meta. Auto backups copy SSD current to HDD daily and monthly (month rollover), SSD keeps last auto + two manual. Baremetal: after SSD image completes, copy to HDD current, rotate old HDD current to previous, then monthly copy. User will create datasets/paths and set SSH perms before script changes.
- 2026-02-06 22:42 EST (Codex): TrueNAS CLI paste issues continue (multiline shell formatting). Codex can SSH to TrueNAS but cannot run sudo non-interactively because password is required; recommended next step is to run a script file on TrueNAS (or install Codex there) to avoid fragile one-liner pastes.
- 2026-02-06 23:06 EST (Codex): Root over SSH is unavailable for this setup; workflow pivot is to transfer script/list files between Fedora and TrueNAS (scp + single sudo run) to avoid error-prone multiline pastes.
- 2026-02-06 23:10 EST (Codex): Security direction: create dedicated SSH automation user for backup datasets with least privilege (dataset-scoped commands, restricted SSH key options), avoiding broad sudo/root.
- 2026-02-06 23:28 EST (Codex): User requested direct Codex-operated TrueNAS config due fatigue; proposed temporary passwordless sudo access for an SSH key (time-boxed, then revoke) so Codex can execute shell tasks end-to-end.
- 2026-02-06 23:36 EST (Codex): First temporary sudoers attempt still prompted for password over SSH; next step is enforce explicit `Defaults:macmini_bu !authenticate` and re-test with `ssh truenas 'sudo -n id'`.
- 2026-02-06 23:40 EST (Codex): Here-doc commands for sudoers setup proved fragile in TrueNAS shell; switching to single-line `printf | sudo tee` commands to avoid paste/newline parsing issues.
- 2026-02-06 23:41 EST (Codex): SSH auth failure root cause likely key mismatch: ~/.ssh/config host `truenas` uses id_ed25519_truenas, while a new automation key id_ed25519_buAuto was generated. Next step is add matching pubkey to TrueNAS user or update SSH config identity.
- 2026-02-06 23:48 EST (Codex): TrueNAS root check showed `/etc/sudoers.d/99-codex-temp` exists but `sudo -l -U macmini_bu` still denies sudo; likely sudoers include path mismatch (TrueNAS may be using `/usr/local/etc/sudoers*` instead of `/etc/sudoers*`).
- 2026-02-07 00:32 EST (Codex): Provided root SSH rollback commands (remove root authorized_keys and disable root SSH login via TrueNAS settings/CLI) before user pause for the night.
- 2026-02-06 18:27 EST (Codex): Added README task to define a reliable access method for the baremetal image during restore.
