# Hardware Inventory and Operations Guide

Last updated: 2026-02-11 23:40 EST

This file is a practical inventory plus operating guide for future sessions/agents.
It combines command-verified system state and user-identified device context.

## 1) Core Systems

### 1.1 Local machine (current working host)
- Model: Apple Mac mini 2018 (`Macmini8,1`)
- OS: Fedora Linux 43 KDE
- Kernel: `6.18.7-210.t2.fc43.x86_64`
- CPU: Intel i7-8700B (6C/12T)
- Internal SSD: Apple SSD AP0512M (`/dev/nvme0n1`, ~465.9G)
- Current Fedora layout:
  - `/dev/nvme0n1p1` 600M EFI, mounted `/boot/efi`
  - `/dev/nvme0n1p2` 2G ext4, mounted `/boot`
  - `/dev/nvme0n1p3` 320G LUKS (`UUID 0382b52d-...`)
  - mapped LUKS contains btrfs root/home (`UUID 54ab4d67-...`)

### 1.2 Proxmox host
- SSH alias: `rb1-pve`
- Hostname: `rb1-pve`
- PVE version: `pve-manager/9.1.4`
- VM inventory (relevant):
  - VM 100: `truenas` (running, 8G RAM, 4 cores, q35)
  - VM 101: `tsDeb` (running)

### 1.3 TrueNAS guest (VM 100)
- Hostname: `GlaDOS`
- OS: TrueNAS SCALE base (`Debian 12`, kernel `6.12.33-production+truenas`)
- Guest agent: enabled and reachable via `qm agent 100 ...`

## 2) Network + Access Interfaces

### 2.1 Local network identity (Fedora)
- Primary interface: `enp4s0`
- IPv4: `192.168.5.81/22`

### 2.2 SSH aliases (from `~/.ssh/config`)
- `truenas` -> `macmini_bu@192.168.5.100` (key: `~/.ssh/id_ed25519_truenas`)
- `rb1-pve` -> `root@192.168.5.98` (key: `~/.ssh/id_ed25519_rb1-pve`)

### 2.3 Fast command paths
- Proxmox shell: `ssh rb1-pve`
- TrueNAS through Proxmox guest agent:
  - `ssh rb1-pve 'qm agent 100 ping'`
  - `ssh rb1-pve 'qm guest exec 100 -- /bin/sh -lc "<command>"'`

## 3) Display and Dock Topology

## 3.1 Hard constraints
- Maximum active display endpoints on this Mac mini workflow: **3**
- Current KDE state confirms 3 active DP outputs: `DP-2`, `DP-4`, `DP-6`

### 3.2 User-identified hardware context
- One display is identified by user as **Sceptre**
- Soundbar brand identified by user as **TCL**
- Dock in use: Dell WD19 family (USB audio device presents as WD19/WD15 dock codec)

### 3.3 Dock USB inventory fingerprints
- WD19 components observed on USB bus (multiple Dell/Realtek functions)
- USB audio codec: Realtek `0bda:402e` (`USB Audio`)
- Card profile set: `dell-dock-tb16-usb-audio.conf`

## 4) Audio Inventory and Known-Good Routing

### 4.1 Audio cards seen by PipeWire/Pulse
- `alsa_card.usb-Generic_USB_Audio_200901010001-00` (WD19 USB Audio)
- `alsa_card.pci-0000_02_00.3` (Apple Audio Device/T2 path)
- `alsa_card.pci-0000_00_1f.3` (Intel PCH audio/HDMI path)

### 4.2 WD19 profile and ports (verified)
- Active profile to use: `HiFi`
- Available output ports in HiFi profile:
  - `Headphones` (not available in current jack-detect state)
  - `Line Out` (available)

### 4.3 Current preferred output for soundbar
- Sink label: `USB Audio Line Out`
- Sink name: `alsa_output.usb-Generic_USB_Audio_200901010001-00.HiFi__Line__sink`
- Physical chain: `WD19 line-out (3.5mm) -> TCL soundbar aux-in`
- Strategy: avoid Mac mini aux output path due prior buzzing/instability reports.

### 4.4 One-shot recovery commands (Fedora)
```bash
pactl set-card-profile alsa_card.usb-Generic_USB_Audio_200901010001-00 HiFi
pactl set-default-sink alsa_output.usb-Generic_USB_Audio_200901010001-00.HiFi__Line__sink
pactl set-sink-mute alsa_output.usb-Generic_USB_Audio_200901010001-00.HiFi__Line__sink 0
pactl set-sink-volume alsa_output.usb-Generic_USB_Audio_200901010001-00.HiFi__Line__sink 85%
pactl list short sink-inputs | awk '{print $1}' | xargs -r -I{} \
  pactl move-sink-input {} alsa_output.usb-Generic_USB_Audio_200901010001-00.HiFi__Line__sink
```

## 5) Storage and Backup Inventory

### 5.1 SSD source datasets on TrueNAS (`veyDisk`)
- Root: `/mnt/veyDisk/fedoraBackups`
- File-level recent slots:
  - `/mnt/veyDisk/fedoraBackups/completeFileLevel/recent/01`
  - `/mnt/veyDisk/fedoraBackups/completeFileLevel/recent/02`
  - `/mnt/veyDisk/fedoraBackups/completeFileLevel/recent/03`
- Baremetal path:
  - `/mnt/veyDisk/fedoraBackups/bareMetalImage`

### 5.2 HDD archive datasets on TrueNAS (`oyPool`)
- Root: `/mnt/oyPool/fedoraBackupsArchive`
- File-level archive:
  - `fileLevelBackupsArchive/daily/01..07`
  - `fileLevelBackupsArchive/monthly/01..12`
- Baremetal archive:
  - `bareMetalImagesArchive/current`
  - `bareMetalImagesArchive/previous`
  - `bareMetalImagesArchive/monthly`

### 5.3 Backup automation state (verified)
- Fedora user timer enabled:
  - unit: `truenas-filelevel-auto.timer`
  - schedule: daily `03:30`
- TrueNAS cron job enabled (id `1`):
  - schedule: daily `04:30`
  - command: `/root/truenas_archive_rotate.sh >> /var/log/truenas_archive_rotate.log 2>&1`

### 5.4 Backup scripts in repo
- `scripts/rsync_to_truenas.sh`
- `scripts/auto_filelevel_to_truenas.sh`
- `scripts/truenas_archive_rotate.sh`
- `scripts/backup_automation_setup.md`

## 6) Known Risks / Caveats to Carry Forward

- Historical T2 audio instability occurred when routing back to Apple audio path (`aaudio_pcm_pointer while not started` and related kernel noise), documented in `log.md`.
- Current preferred mitigation is to stay on WD19 line-out sink.
- Prior raw baremetal image from 2026-02-06 was flagged non-restorable (invalid GPT structure) in prior validation; do not assume that image is viable without re-validation.
- Display endpoint budget is tight (3 max): avoid plans that add an extra active video endpoint for audio unless explicitly redesigning display topology.

## 7) Quick Verification Checklist for Future Agents

1. Confirm local host and kernel:
   - `hostnamectl`
2. Confirm dock audio appears and Line Out is available:
   - `pactl list cards | sed -n '/Card #47/,/Card #48/p'`
3. Confirm default sink is WD19 line-out:
   - `pactl get-default-sink`
4. Confirm timers/cron:
   - `systemctl --user status truenas-filelevel-auto.timer`
   - `ssh rb1-pve 'qm guest exec 100 -- /bin/sh -lc "midclt call cronjob.query"'`
5. Confirm Proxmox/TrueNAS reachability:
   - `ssh rb1-pve 'qm agent 100 ping'`

## 8) Where to Read Full History

- Primary timeline: `log.md`
- Project status and runbooks: `README.md`
- Install-only macOS flow: `macos_install_solo_runbook.md`
- Recovery flow after Fedora resize: `macos_recovery_post_resize.md`
- Clonezilla path: `clonezilla_to_truenas_baremetal.md`
