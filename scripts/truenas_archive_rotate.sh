#!/usr/bin/env bash
set -euo pipefail

# Run this script on TrueNAS as root from a periodic task.

SSD_BASE="/mnt/veyDisk/fedoraBackups"
HDD_BASE="/mnt/oyPool/fedoraBackupsArchive"

SSD_FILELEVEL_AUTO="$SSD_BASE/completeFileLevel/recent/03"
HDD_FILELEVEL_DAILY="$HDD_BASE/fileLevelBackupsArchive/daily"
HDD_FILELEVEL_MONTHLY="$HDD_BASE/fileLevelBackupsArchive/monthly"

SSD_BAREMETAL_CURRENT="$SSD_BASE/bareMetalImage/current"
HDD_BAREMETAL_CURRENT="$HDD_BASE/bareMetalImagesArchive/current"
HDD_BAREMETAL_PREVIOUS="$HDD_BASE/bareMetalImagesArchive/previous"
HDD_BAREMETAL_MONTHLY="$HDD_BASE/bareMetalImagesArchive/monthly"

STATE_DIR="$HDD_BASE/.state"
FILELEVEL_MONTH_STATE="$STATE_DIR/filelevel_last_month"
BAREMETAL_MONTH_STATE="$STATE_DIR/baremetal_last_month"

STAMP="$(date +%F_%H-%M-%S)"

log() {
  printf '[%s] %s\n' "$(date +%F_%T)" "$*"
}

write_text_file() {
  local path="$1"
  local content="$2"
  printf '%s\n' "$content" > "$path"
}

ensure_layout() {
  mkdir -p "$STATE_DIR"
  mkdir -p "$HDD_FILELEVEL_DAILY" "$HDD_FILELEVEL_MONTHLY"
  mkdir -p "$HDD_BAREMETAL_CURRENT" "$HDD_BAREMETAL_PREVIOUS" "$HDD_BAREMETAL_MONTHLY"
  mkdir -p "$HDD_BAREMETAL_CURRENT/meta" "$HDD_BAREMETAL_PREVIOUS/meta" "$HDD_BAREMETAL_MONTHLY/meta"
}

sync_filelevel_daily() {
  local src_data="$SSD_FILELEVEL_AUTO/data"
  local src_meta="$SSD_FILELEVEL_AUTO/meta"
  local slot_num target

  if [[ ! -d "$src_data" ]]; then
    log "Skipping file-level daily archive: source missing ($src_data)"
    return 0
  fi

  slot_num="$(date +%u)"
  target="$HDD_FILELEVEL_DAILY/$(printf '%02d' "$slot_num")"
  mkdir -p "$target/data" "$target/meta"

  log "Sync file-level daily -> slot $(printf '%02d' "$slot_num")"
  rsync -aHAX --delete "$src_data/" "$target/data/"
  if [[ -d "$src_meta" ]]; then
    rsync -a --delete "$src_meta/" "$target/meta/"
  fi

  write_text_file "$target/meta/archive_info.md" \
"# Archive Metadata

- archive_type: daily
- archived_at: $(date --iso-8601=seconds)
- source_path: $SSD_FILELEVEL_AUTO
- target_slot: $(printf '%02d' "$slot_num")
- trigger: truenas_archive_rotate.sh"
}

sync_filelevel_monthly_if_due() {
  local month_now month_last slot target src_data src_meta
  src_data="$SSD_FILELEVEL_AUTO/data"
  src_meta="$SSD_FILELEVEL_AUTO/meta"

  if [[ ! -d "$src_data" ]]; then
    log "Skipping file-level monthly archive: source missing ($src_data)"
    return 0
  fi

  month_now="$(date +%m)"
  month_last=""
  if [[ -f "$FILELEVEL_MONTH_STATE" ]]; then
    month_last="$(cat "$FILELEVEL_MONTH_STATE" 2>/dev/null || true)"
  fi

  if [[ "$month_now" == "$month_last" ]]; then
    return 0
  fi

  slot="$month_now"
  target="$HDD_FILELEVEL_MONTHLY/$slot"
  mkdir -p "$target/data" "$target/meta"

  log "Sync file-level monthly -> slot $slot"
  rsync -aHAX --delete "$src_data/" "$target/data/"
  if [[ -d "$src_meta" ]]; then
    rsync -a --delete "$src_meta/" "$target/meta/"
  fi

  write_text_file "$target/meta/archive_info.md" \
"# Archive Metadata

- archive_type: monthly
- archived_at: $(date --iso-8601=seconds)
- source_path: $SSD_FILELEVEL_AUTO
- target_slot: $slot
- trigger: truenas_archive_rotate.sh"

  write_text_file "$FILELEVEL_MONTH_STATE" "$month_now"
}

latest_img() {
  local dir="$1"
  find "$dir" -maxdepth 1 -type f -name '*.img' -printf '%f\n' 2>/dev/null | sort | tail -n 1
}

sync_baremetal_current() {
  local src_name dst_name src_path dst_current_path

  src_name="$(latest_img "$SSD_BAREMETAL_CURRENT")"
  if [[ -z "$src_name" ]]; then
    log "Skipping baremetal archive: no image in $SSD_BAREMETAL_CURRENT"
    return 0
  fi

  src_path="$SSD_BAREMETAL_CURRENT/$src_name"
  dst_name="$(latest_img "$HDD_BAREMETAL_CURRENT")"

  if [[ "$src_name" == "$dst_name" ]]; then
    log "Baremetal current already up to date ($src_name)"
    return 0
  fi

  if [[ -n "$dst_name" && -f "$HDD_BAREMETAL_CURRENT/$dst_name" ]]; then
    log "Rotating baremetal current -> previous ($dst_name)"
    rm -f "$HDD_BAREMETAL_PREVIOUS"/*.img
    cp -a "$HDD_BAREMETAL_CURRENT/$dst_name" "$HDD_BAREMETAL_PREVIOUS/$dst_name"
    write_text_file "$HDD_BAREMETAL_PREVIOUS/meta/archive_info.md" \
"# Archive Metadata

- archive_type: baremetal-previous
- archived_at: $(date --iso-8601=seconds)
- image_name: $dst_name
- trigger: truenas_archive_rotate.sh"
  fi

  log "Sync baremetal current -> $src_name"
  rm -f "$HDD_BAREMETAL_CURRENT"/*.img
  cp -a "$src_path" "$HDD_BAREMETAL_CURRENT/$src_name"

  write_text_file "$HDD_BAREMETAL_CURRENT/meta/archive_info.md" \
"# Archive Metadata

- archive_type: baremetal-current
- archived_at: $(date --iso-8601=seconds)
- source_path: $src_path
- image_name: $src_name
- trigger: truenas_archive_rotate.sh"
}

sync_baremetal_monthly_if_due() {
  local month_now month_last src_name src_path monthly_name

  src_name="$(latest_img "$SSD_BAREMETAL_CURRENT")"
  if [[ -z "$src_name" ]]; then
    log "Skipping baremetal monthly archive: no current source image"
    return 0
  fi
  src_path="$SSD_BAREMETAL_CURRENT/$src_name"

  month_now="$(date +%m)"
  month_last=""
  if [[ -f "$BAREMETAL_MONTH_STATE" ]]; then
    month_last="$(cat "$BAREMETAL_MONTH_STATE" 2>/dev/null || true)"
  fi
  if [[ "$month_now" == "$month_last" ]]; then
    return 0
  fi

  monthly_name="${src_name%.img}-monthly-${month_now}.img"
  log "Sync baremetal monthly -> $monthly_name"
  rm -f "$HDD_BAREMETAL_MONTHLY"/*.img
  cp -a "$src_path" "$HDD_BAREMETAL_MONTHLY/$monthly_name"

  write_text_file "$HDD_BAREMETAL_MONTHLY/meta/archive_info.md" \
"# Archive Metadata

- archive_type: baremetal-monthly
- archived_at: $(date --iso-8601=seconds)
- source_path: $src_path
- image_name: $monthly_name
- trigger: truenas_archive_rotate.sh"

  write_text_file "$BAREMETAL_MONTH_STATE" "$month_now"
}

main() {
  log "Archive rotation run started: $STAMP"
  ensure_layout
  sync_filelevel_daily
  sync_filelevel_monthly_if_due
  sync_baremetal_current
  sync_baremetal_monthly_if_due
  log "Archive rotation run finished"
}

main "$@"
