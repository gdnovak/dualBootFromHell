# Backup Automation Setup

This repo now has:

- Fedora manual/interactive backup script: `scripts/rsync_to_truenas.sh`
- Fedora auto wrapper: `scripts/auto_filelevel_to_truenas.sh`
- TrueNAS archive script: `scripts/truenas_archive_rotate.sh`

## 1) Fedora auto backup task (daily)

Run this on Fedora (as `tdj`) to install a user timer:

```bash
mkdir -p ~/.config/systemd/user
cat > ~/.config/systemd/user/truenas-filelevel-auto.service <<'EOF'
[Unit]
Description=Auto file-level backup to TrueNAS

[Service]
Type=oneshot
ExecStart=/home/tdj/bin/auto_filelevel_to_truenas.sh
EOF

cat > ~/.config/systemd/user/truenas-filelevel-auto.timer <<'EOF'
[Unit]
Description=Daily auto file-level backup to TrueNAS

[Timer]
OnCalendar=*-*-* 03:30:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now truenas-filelevel-auto.timer
systemctl --user list-timers truenas-filelevel-auto.timer
```

## 2) TrueNAS archive task (daily)

Copy `scripts/truenas_archive_rotate.sh` to TrueNAS (example path `/root/truenas_archive_rotate.sh`) and mark executable:

```bash
chmod +x /root/truenas_archive_rotate.sh
```

Create a TrueNAS periodic task (daily, after Fedora auto backup time) to run:

```bash
/root/truenas_archive_rotate.sh
```

Suggested time: `04:30` local.

## 3) Restore access

- Baremetal image source of truth for restore tooling:  
  `/mnt/veyDisk/fedoraBackups/bareMetalImage/current`
- Archive copies maintained on HDD by TrueNAS task:
  - `/mnt/oyPool/fedoraBackupsArchive/bareMetalImagesArchive/current`
  - `/mnt/oyPool/fedoraBackupsArchive/bareMetalImagesArchive/previous`
  - `/mnt/oyPool/fedoraBackupsArchive/bareMetalImagesArchive/monthly`
