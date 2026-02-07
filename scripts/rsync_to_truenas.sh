#!/usr/bin/env bash
set -euo pipefail

TRUENAS_HOST="${TRUENAS_HOST:-192.168.5.100}"
TRUENAS_USER="${TRUENAS_USER:-macmini_bu}"

SSD_BASE="/mnt/veyDisk/fedoraBackups"
FILELEVEL_BASE="$SSD_BASE/completeFileLevel/recent"
MANUAL_SLOT="$FILELEVEL_BASE/01"
PREV_MANUAL_SLOT="$FILELEVEL_BASE/02"
AUTO_SLOT="$FILELEVEL_BASE/03"
BAREMETAL_BASE="$SSD_BASE/bareMetalImage"

KNOWN_HOSTS="${KNOWN_HOSTS:-/home/tdj/.ssh/known_hosts}"
KEY_PATH="${KEY_PATH:-/home/tdj/.ssh/id_ed25519_truenas}"

LOGDIR="${BACKUP_LOGDIR:-/home/tdj/backup-logs}"
STAMP="$(date +%F_%H-%M-%S)"
LOGFILE="$LOGDIR/rsync_truenas_$STAMP.log"
START_EPOCH="$(date +%s)"

mkdir -p "$LOGDIR"

SSH_CMD=(
  ssh
  -i "$KEY_PATH"
  -o BatchMode=yes
  -o StrictHostKeyChecking=yes
  -o UserKnownHostsFile="$KNOWN_HOSTS"
)
RSYNC_SSH="ssh -i $KEY_PATH -o BatchMode=yes -o StrictHostKeyChecking=yes -o UserKnownHostsFile=$KNOWN_HOSTS"

run_ssh() {
  "${SSH_CMD[@]}" "$TRUENAS_USER@$TRUENAS_HOST" "$@"
}

format_duration() {
  local total="$1"
  local h m s
  h=$((total / 3600))
  m=$(((total % 3600) / 60))
  s=$((total % 60))
  printf "%02d:%02d:%02d" "$h" "$m" "$s"
}

run_rsync() {
  set +e
  "$@" 2>&1 | tee -a "$LOGFILE"
  local rc="${PIPESTATUS[0]}"
  set -e
  if [[ "$rc" -ne 0 && "$rc" -ne 24 ]]; then
    return "$rc"
  fi
  if [[ "$rc" -eq 24 ]]; then
    echo "Warning: rsync reported vanished/changed files (code 24)." | tee -a "$LOGFILE"
  fi
  return 0
}

ensure_ssh_ready() {
  if [[ ! -r "$KEY_PATH" ]]; then
    echo "SSH key not readable: $KEY_PATH"
    exit 1
  fi
  if [[ ! -r "$KNOWN_HOSTS" ]]; then
    echo "known_hosts not readable: $KNOWN_HOSTS"
    exit 1
  fi
  run_ssh "echo ok" >/dev/null
}

MODE="${1:-}"
if [[ -z "$MODE" ]]; then
  read -r -p "Backup mode (2) complete-manual, (3) baremetal, or (4) complete-auto? " MODE
fi

case "$MODE" in
  1|lightweight)
    MODE="complete-manual"
    echo "Mode 1 (lightweight) is deprecated and now maps to complete-manual."
    ;;
  2|complete|manual|complete-manual) MODE="complete-manual" ;;
  3|baremetal) MODE="baremetal" ;;
  4|auto|complete-auto) MODE="complete-auto" ;;
  *)
    echo "Invalid mode: $MODE"
    echo "Valid: 2|complete-manual, 3|baremetal, 4|complete-auto"
    exit 1
    ;;
esac

BASE_EXCLUDES=(
  ".cache/"
  ".local/share/Trash/"
  "Downloads/"
  ".mozilla/firefox/*/cache2/"
)

RSYNC_COMMON_OPTS=(
  -aHAX
  --numeric-ids
  --delete
  --info=progress2
  --human-readable
  -e "$RSYNC_SSH"
)

get_top_disk() {
  local dev="$1"
  local parent=""
  local dtype=""
  while true; do
    dtype="$(lsblk -no TYPE "$dev" 2>/dev/null || true)"
    if [[ "$dtype" == "disk" ]]; then
      echo "$dev"
      return 0
    fi
    parent="$(lsblk -no PKNAME "$dev" 2>/dev/null || true)"
    if [[ -z "$parent" ]]; then
      return 1
    fi
    dev="/dev/$parent"
  done
}

detect_disk_from_mountpoint() {
  local mnt="$1"
  local part=""
  local parent=""
  part="$(lsblk -nrpo NAME,TYPE,MOUNTPOINT | awk -v m="$mnt" '$2=="part" && $3==m {print $1; exit}')"
  if [[ -z "$part" ]]; then
    part="$(findmnt -n -o SOURCE "$mnt" 2>/dev/null || true)"
    part="${part%%[*}"
  fi
  if [[ -n "$part" && -b "$part" ]]; then
    parent="$(lsblk -no PKNAME "$part" 2>/dev/null || true)"
    if [[ -n "$parent" ]]; then
      echo "/dev/$parent"
      return 0
    fi
    get_top_disk "$part"
    return 0
  fi
  return 1
}

write_filelevel_metadata() {
  local slot="$1"
  local backup_kind="$2"
  local host
  local pretty_os=""
  local kernel
  local backup_id
  local now_iso
  local tmp_meta

  host="$(hostname -f 2>/dev/null || hostname)"
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    pretty_os="${PRETTY_NAME:-}"
  fi
  kernel="$(uname -r)"
  backup_id="${backup_kind}-${STAMP}"
  now_iso="$(date --iso-8601=seconds)"
  tmp_meta="$(mktemp -d)"

  cat > "$tmp_meta/backup_info.md" <<EOF
# Backup Metadata

- backup_id: $backup_id
- backup_kind: $backup_kind
- created_at: $now_iso
- source_host: $host
- os: ${pretty_os:-unknown}
- kernel: $kernel
- source_script: /home/tdj/dualBootFromHell/scripts/rsync_to_truenas.sh
- destination_slot: $slot
EOF

  rpm -qa --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' | sort > "$tmp_meta/package_list.txt"
  lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT > "$tmp_meta/lsblk.txt"
  findmnt -A -o SOURCE,TARGET,FSTYPE,OPTIONS > "$tmp_meta/findmnt.txt"

  run_ssh "mkdir -p '$slot/meta'"
  run_rsync rsync -a --human-readable -e "$RSYNC_SSH" \
    "$tmp_meta/backup_info.md" \
    "$TRUENAS_USER@$TRUENAS_HOST:$slot/meta/backup_info.md"
  run_rsync rsync -a --human-readable -e "$RSYNC_SSH" \
    "$tmp_meta/package_list.txt" \
    "$TRUENAS_USER@$TRUENAS_HOST:$slot/meta/package_list.txt"
  run_rsync rsync -a --human-readable -e "$RSYNC_SSH" \
    "$tmp_meta/lsblk.txt" \
    "$TRUENAS_USER@$TRUENAS_HOST:$slot/meta/lsblk.txt"
  run_rsync rsync -a --human-readable -e "$RSYNC_SSH" \
    "$tmp_meta/findmnt.txt" \
    "$TRUENAS_USER@$TRUENAS_HOST:$slot/meta/findmnt.txt"

  rm -rf "$tmp_meta"
}

rotate_manual_slots() {
  run_ssh "mkdir -p '$MANUAL_SLOT/data' '$MANUAL_SLOT/meta' '$PREV_MANUAL_SLOT/meta'"
  run_ssh "rm -rf '$PREV_MANUAL_SLOT/data'"
  run_ssh "mv '$MANUAL_SLOT/data' '$PREV_MANUAL_SLOT/data' 2>/dev/null || mkdir -p '$PREV_MANUAL_SLOT/data'"
  run_ssh "mkdir -p '$MANUAL_SLOT/data'"
  run_ssh "find '$PREV_MANUAL_SLOT/meta' -mindepth 1 -delete || true"
  run_ssh "find '$MANUAL_SLOT/meta' -mindepth 1 -print -quit | grep -q . && cp -a '$MANUAL_SLOT/meta/.' '$PREV_MANUAL_SLOT/meta/' || true"
}

run_filelevel_backup() {
  local target_slot="$1"
  local backup_kind="$2"

  echo "=== File-level backup started: $STAMP ($backup_kind) ===" | tee -a "$LOGFILE"
  run_ssh "mkdir -p '$target_slot/data' '$target_slot/meta'"

  if [[ "$backup_kind" == "complete-manual" ]]; then
    echo "Rotating manual slot 01 -> 02..." | tee -a "$LOGFILE"
    rotate_manual_slots
  fi

  echo "Escalating privileges for system paths (sudo)..." | tee -a "$LOGFILE"
  sudo -v

  local home_excludes=()
  for ex in "${BASE_EXCLUDES[@]}"; do
    home_excludes+=(--exclude="$ex")
  done

  run_rsync rsync \
    "${RSYNC_COMMON_OPTS[@]}" \
    "${home_excludes[@]}" \
    "$HOME/" \
    "$TRUENAS_USER@$TRUENAS_HOST:$target_slot/data/home/"

  run_rsync sudo rsync \
    "${RSYNC_COMMON_OPTS[@]}" \
    /etc/ \
    "$TRUENAS_USER@$TRUENAS_HOST:$target_slot/data/etc/"

  run_rsync sudo rsync \
    "${RSYNC_COMMON_OPTS[@]}" \
    /var/lib/ \
    "$TRUENAS_USER@$TRUENAS_HOST:$target_slot/data/var_lib/"

  run_rsync sudo rsync \
    "${RSYNC_COMMON_OPTS[@]}" \
    /var/log/ \
    "$TRUENAS_USER@$TRUENAS_HOST:$target_slot/data/var_log/"

  run_rsync sudo rsync \
    "${RSYNC_COMMON_OPTS[@]}" \
    /var/spool/ \
    "$TRUENAS_USER@$TRUENAS_HOST:$target_slot/data/var_spool/"

  run_rsync sudo rsync \
    "${RSYNC_COMMON_OPTS[@]}" \
    /boot/ \
    "$TRUENAS_USER@$TRUENAS_HOST:$target_slot/data/boot/"

  if [[ -d /usr/local ]]; then
    run_rsync sudo rsync \
      "${RSYNC_COMMON_OPTS[@]}" \
      /usr/local/ \
      "$TRUENAS_USER@$TRUENAS_HOST:$target_slot/data/usr_local/"
  fi

  if [[ -d /opt ]]; then
    run_rsync sudo rsync \
      "${RSYNC_COMMON_OPTS[@]}" \
      /opt/ \
      "$TRUENAS_USER@$TRUENAS_HOST:$target_slot/data/opt/"
  fi

  write_filelevel_metadata "$target_slot" "$backup_kind"

  local end_stamp end_epoch duration_sec total_kb total_human avg_human avg_bps total_bytes
  end_stamp="$(date +%F_%H-%M-%S)"
  end_epoch="$(date +%s)"
  duration_sec="$((end_epoch - START_EPOCH))"
  total_kb="$(run_ssh "du -sk '$target_slot/data' 2>/dev/null | cut -f1" 2>/dev/null || true)"
  total_human=""
  avg_human=""

  if [[ "$total_kb" =~ ^[0-9]+$ ]]; then
    total_bytes="$((total_kb * 1024))"
    total_human="$(numfmt --to=iec --suffix=B "$total_bytes")"
    if (( duration_sec > 0 )); then
      avg_bps="$((total_bytes / duration_sec))"
      avg_human="$(numfmt --to=iec --suffix=B "$avg_bps")/s"
    fi
  fi

  {
    echo "=== File-level backup finished: $end_stamp ==="
    echo "Backup kind: $backup_kind"
    echo "Destination slot: $target_slot"
    echo "Duration: $(format_duration "$duration_sec")"
    if [[ -n "$total_human" ]]; then
      echo "Slot size: $total_human"
    fi
    if [[ -n "$avg_human" ]]; then
      echo "Average speed: $avg_human"
    fi
  } | tee -a "$LOGFILE"
}

write_baremetal_metadata() {
  local source_dev="$1"
  local source_size_human="$2"
  local image_name="$3"
  local now_iso host kernel pretty_os tmp_meta

  host="$(hostname -f 2>/dev/null || hostname)"
  kernel="$(uname -r)"
  pretty_os=""
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    pretty_os="${PRETTY_NAME:-}"
  fi
  now_iso="$(date --iso-8601=seconds)"
  tmp_meta="$(mktemp -d)"

  cat > "$tmp_meta/backup_info.md" <<EOF
# Baremetal Metadata

- backup_kind: baremetal
- created_at: $now_iso
- source_host: $host
- os: ${pretty_os:-unknown}
- kernel: $kernel
- source_device: $source_dev
- source_size: $source_size_human
- image_name: $image_name
- image_path: $BAREMETAL_BASE/current/$image_name
- source_script: /home/tdj/dualBootFromHell/scripts/rsync_to_truenas.sh
EOF

  run_ssh "mkdir -p '$BAREMETAL_BASE/meta'"
  run_rsync rsync -a --human-readable -e "$RSYNC_SSH" \
    "$tmp_meta/backup_info.md" \
    "$TRUENAS_USER@$TRUENAS_HOST:$BAREMETAL_BASE/meta/backup_info.md"

  rm -rf "$tmp_meta"
}

run_baremetal_backup() {
  local root_src_raw root_src source_dev source_size_bytes source_size_human
  local timestamp image_name tmp_remote final_remote

  root_src_raw="$(findmnt -n -o SOURCE /)"
  root_src="${root_src_raw%%[*}"

  source_dev="$(detect_disk_from_mountpoint /boot/efi || true)"
  if [[ -z "$source_dev" ]]; then
    source_dev="$(detect_disk_from_mountpoint /boot || true)"
  fi
  if [[ -z "$source_dev" && -b "$root_src" ]]; then
    source_dev="$(get_top_disk "$root_src" || true)"
  fi
  if [[ -z "$source_dev" ]]; then
    mapfile -t disks < <(lsblk -nrpo NAME,TYPE | awk '$2=="disk"{print $1}')
    if [[ "${#disks[@]}" -eq 1 ]]; then
      source_dev="${disks[0]}"
    fi
  fi

  if [[ -z "$source_dev" ]]; then
    echo "Could not auto-detect source disk from root mount: $root_src_raw"
    echo "Aborting."
    exit 1
  fi

  echo "Detected source disk: $source_dev (root source: $root_src)"
  read -r -p "Use this disk? (y/n): " confirm_disk
  if [[ ! "$confirm_disk" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi

  echo "Escalating privileges for disk access (sudo)..."
  sudo -v
  source_size_bytes="$(sudo blockdev --getsize64 "$source_dev")"
  source_size_human="$(numfmt --to=iec --suffix=B "$source_size_bytes")"

  echo "WARNING: Baremetal backup will replace the existing image in:"
  echo "  $TRUENAS_USER@$TRUENAS_HOST:$BAREMETAL_BASE/current"
  echo "Source disk size: $source_size_human"
  read -r -p "Proceed? (y/n): " confirm_bare
  if [[ ! "$confirm_bare" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi

  timestamp="$(date +%F_%H-%M-%S)"
  image_name="macmini-2018-baremetal-$timestamp.img"
  tmp_remote="$BAREMETAL_BASE/current/.incoming-$timestamp.img"
  final_remote="$BAREMETAL_BASE/current/$image_name"

  run_ssh "mkdir -p '$BAREMETAL_BASE/current' '$BAREMETAL_BASE/meta'"

  echo "=== Baremetal image started: $timestamp ===" | tee -a "$LOGFILE"
  echo "Source device: $source_dev" | tee -a "$LOGFILE"
  echo "Temporary destination: $TRUENAS_USER@$TRUENAS_HOST:$tmp_remote" | tee -a "$LOGFILE"

  sudo dd if="$source_dev" bs=64M status=progress conv=sync,noerror | \
    run_ssh "cat > '$tmp_remote'"

  run_ssh "find '$BAREMETAL_BASE/current' -maxdepth 1 -type f -name '*.img' ! -name '.incoming-$timestamp.img' -delete"
  run_ssh "mv '$tmp_remote' '$final_remote'"

  write_baremetal_metadata "$source_dev" "$source_size_human" "$image_name"

  echo "=== Baremetal image finished: $(date +%F_%H-%M-%S) ===" | tee -a "$LOGFILE"
  echo "Final destination: $TRUENAS_USER@$TRUENAS_HOST:$final_remote" | tee -a "$LOGFILE"
}

ensure_ssh_ready

case "$MODE" in
  complete-manual) run_filelevel_backup "$MANUAL_SLOT" "$MODE" ;;
  complete-auto) run_filelevel_backup "$AUTO_SLOT" "$MODE" ;;
  baremetal) run_baremetal_backup ;;
esac
