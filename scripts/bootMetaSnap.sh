STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$HOME/preflight_snapshots/$STAMP"
mkdir -p "$OUT"

sudo efibootmgr -v > "$OUT/efibootmgr-v.txt"
lsblk -f > "$OUT/lsblk-f.txt"
sudo blkid > "$OUT/blkid.txt"
sudo cp -a /boot/efi/EFI "$OUT/EFI-backup"

echo "Saved snapshot in: $OUT"
