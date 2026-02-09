# Clonezilla to TrueNAS bare-metal runbook

Date validated: 2026-02-09

## Outcome
Clonezilla/Rescuezilla can save images to TrueNAS using **NFS** with this target:
- Server: `192.168.5.100`
- Export path: `/mnt/veyDisk/fedoraBackups/bareMetalImage/clonezilla`
- Effective write user on TrueNAS: `macmini_bu` (via NFS `mapall_user/mapall_group`)
- Credentials in Clonezilla for NFS: **none**

## Why this protocol
- SSH on TrueNAS is key-only (`passwordauth=false`, `ssh_password_enabled=false` for `macmini_bu`), so Clonezilla password SSH flow is not reliable without extra key-handling work.
- SMB for `macmini_bu` is currently not enabled and requires password reset to activate SMB auth.
- NFS required the least-risk operational change and was validated end-to-end.

## Clonezilla UI steps (device-image -> NFS)
1. Boot Clonezilla live.
2. Choose `device-image`.
3. Choose `ssh_server | samba_server | nfs_server`, then select `nfs_server`.
4. For server/IP, enter `192.168.5.100`.
5. For remote directory, enter `/mnt/veyDisk/fedoraBackups/bareMetalImage/clonezilla`.
6. If prompted for NFS version, use default first (works), or `nfs`/`v4`.
7. Choose beginner or expert mode.
8. Choose `savedisk` for whole-disk image (bare metal).
9. Set image name (example: `macmini-fedora-YYYYMMDD`).
10. Select source disk (`/dev/nvme0n1` if that is the internal disk).
11. Confirm prompts and start backup.

Expected behavior:
- Clonezilla mounts the NFS export and creates an image directory under the export path.
- Files appear on TrueNAS under `/mnt/veyDisk/fedoraBackups/bareMetalImage/clonezilla/<image-name>/`.

## Rescuezilla notes
- In Rescuezilla, choose an image destination on the same NFS server/path:
  - Server: `192.168.5.100`
  - Path: `/mnt/veyDisk/fedoraBackups/bareMetalImage/clonezilla`
- No username/password needed for this NFS target.

## Quick verification commands
From any Linux host on the same LAN:

```bash
showmount -e 192.168.5.100
```

```bash
sudo mkdir -p /tmp/cz_nfs_test
sudo mount -t nfs 192.168.5.100:/mnt/veyDisk/fedoraBackups/bareMetalImage/clonezilla /tmp/cz_nfs_test
echo ok | sudo tee /tmp/cz_nfs_test/.probe >/dev/null
sudo ls -l /tmp/cz_nfs_test/.probe
sudo rm -f /tmp/cz_nfs_test/.probe
sudo umount /tmp/cz_nfs_test
```

TrueNAS-side spot check:

```bash
ssh truenas 'ls -lah /mnt/veyDisk/fedoraBackups/bareMetalImage/clonezilla'
```

## Rollback (if needed)
If you want to undo this prep:

```bash
# from rb1-pve
qm guest exec 100 -- /usr/bin/midclt call sharing.nfs.delete 1
qm guest exec 100 -- /usr/bin/midclt call service.stop nfs
qm guest exec 100 -- /usr/bin/midclt call service.update nfs '{"enable": false}'
```
