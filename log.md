# Log of Dualboot Project

## Instructions for Codex
- See Readme first for writing instructions.
- Log data here extensively such that at any time, you will know what stage of the project we are at, what has been done, etc.
- This file is all yours, although I may add a few things here and there. Otherwise, use this as your memory.
- The section below is the log. You may format it however you like. Be SURE to read the ENTIRE README.md before beginning.

## LOG

- 2026-02-06 00:17 EST (Codex): Added full system specs to README.md. Key facts: Apple Mac mini (Macmini8,1, 2018), Intel i7-8700B, 16 GiB RAM, Intel UHD 630, Apple NVMe 512 GB, Fedora 43 KDE (Wayland), kernel 6.18.7-210.t2.fc43.x86_64, GRUB 2.12, Secure Boot disabled, internal disk layout EFI (/boot/efi, vfat) + /boot (ext4) + LUKS -> Btrfs (root + /home; label "fedora"). Note: macOS is deleted; Fedora owns the entire disk; EFI still has stale Mac OS X entries. Backup details still pending (rsync to TrueNAS via /home/tdj/bin/rsync_to_truenas.sh).
- 2026-02-06 00:23 EST (Codex): Workflow decision: Codex will make local commits but will not push to GitHub; user will run `git push` manually. Codex should remind user to push regularly.
