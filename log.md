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
