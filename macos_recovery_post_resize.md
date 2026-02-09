# macOS Recovery Install Checklist (After Fedora Resize)

Use this after Fedora has already been shrunk and verified bootable.

## Scope

- Goal: install macOS into the free space created by Fedora resize, without deleting Fedora.
- Assumption: resize target was completed using `fedora_resize_to_320gib.md`.

## Preflight (From Fedora, before reboot)

1. Confirm Fedora is currently bootable and stable.
2. Confirm backup risk is accepted for this phase (file-level path is primary; baremetal image is not currently trusted).
3. Confirm you know how to reach Apple Startup Manager:
- Hold `Option` (Alt) immediately after power-on/chime.

## Recovery Install Steps

1. Reboot and enter Apple Startup Manager (`Option` key).
2. Choose Recovery (`Options` / Recovery entry).
3. Open Disk Utility and switch to "Show All Devices".
4. Verify free space exists on internal SSD and Fedora/Linux partitions are present.
5. If needed, create an APFS container/volume in free space only. Do not erase the whole disk.
6. Run "Reinstall macOS" and target the new APFS volume/container.
7. Let install complete and boot into macOS.

## Immediate Post-Install Checks

1. In macOS, verify core first-run items (user login, network, and required school apps path).
2. Reboot and open Startup Manager (`Option`) again.
3. Verify both macOS and Fedora boot entries are available.
4. Boot Fedora and confirm:
- `/` and `/home` mount correctly.
- `/boot` and `/boot/efi` are normal.
- No urgent bootloader errors.

## Expected Bootloader Behavior

- macOS install can change default boot target/NVRAM order.
- This is expected; it does not automatically mean Fedora is broken.
- If Fedora entry is missing from default flow but still appears in Startup Manager, fix default selection after install.

## If Fedora Fails to Boot

1. Boot Fedora live USB.
2. Use `restore_from_backup.md` for priority file-level restore targets.
3. Repair boot flow as needed, then retest both OS boots.
