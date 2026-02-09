# Restore from Backup (Current Project State)

Date: 2026-02-09

## Current status
- File-level backups: usable for restoring configs/user data and speeding up Fedora rebuild.
- Baremetal image: **NOT currently trusted/restorable** (GPT structure validation failed). Treat as placeholder until regenerated and re-validated.

## Where backups are
- Latest manual file-level: `/mnt/veyDisk/fedoraBackups/completeFileLevel/recent/01`
- Latest auto file-level: `/mnt/veyDisk/fedoraBackups/completeFileLevel/recent/03`
- HDD archive slots: `/mnt/oyPool/fedoraBackupsArchive/fileLevelBackupsArchive/{daily,monthly}`

## Fast restore workflow (file-level)

1. Install Fedora first (same major release preferred).
2. Boot into Fedora Live or the new install.
3. Retrieve backup data by SSH/SCP/rsync from TrueNAS, or use exported artifact in SMB `mainShared` if present.
4. Restore high-priority files first:
- `/etc/fstab`
- `/etc/crypttab`
- `/boot/grub2/grub.cfg`
- `/boot/loader/entries/*`
- `/home/*`
5. Reinstall packages using backup metadata (`package_list.txt`) as checklist.

## Example restore commands (from Fedora Live)

```bash
# pull latest manual backup slot from TrueNAS
mkdir -p /mnt/restore_src
rsync -avh truenas:/mnt/veyDisk/fedoraBackups/completeFileLevel/recent/01/data/ /mnt/restore_src/

# example: restore into a mounted target system at /mnt/sysroot
rsync -avh /mnt/restore_src/home/ /mnt/sysroot/home/
rsync -avh /mnt/restore_src/etc/  /mnt/sysroot/etc/
rsync -avh /mnt/restore_src/boot/ /mnt/sysroot/boot/
```

## Baremetal placeholder
- Baremetal restore is intentionally not documented as active for this checkpoint.
- Action required later: regenerate baremetal image with fail-fast settings and validate partition table (`fdisk`, `sgdisk -v`) before considering it recoverable.

## Access policy note (to revisit)
- We used pragmatic short-term access methods to keep project velocity high.
- Revisit and harden SMB/SSH access controls after macOS dualboot is in place.
