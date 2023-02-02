#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

CONFIG_DIR=${SCRIPT_PATH}/config
source "${CONFIG_DIR}"/config.env
source "${SCRIPT_PATH}"/util.sh

RESYNC_MARKER_DIR=${HOME}/.rclone_resync_markers

function sync() {
  local from="$1"
  local to="$2"
  local filter_file="$3"
  local marker_file="$(echo $from:$to | sed 's/[.\/:]/_/g').done"
  local log_file="$(mktemp /tmp/rclone-log.XXX)"

  if [ ! -d "$from" ]; then
    error "The folder $1 does not exist! Skipping.."
    sleep 3
    return
  fi

  mkdir -p ${RESYNC_MARKER_DIR} # create if it doesn't exist already
  if [ ! -f "${RESYNC_MARKER_DIR}/$marker_file" ]; then
    info "Resyncing $from <-> $to"
    "$RCLONE_BIN" mkdir "$to" --verbose

    if "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --resync --verbose --log-file $log_file; then
      touch "${RESYNC_MARKER_DIR}/$marker_file"
      success "Resynced $from <-> $to"
    else
      error "Failed to resync $from <-> $to!"
      cat "$log_file"
    fi
  else
    info "Syncing $from <-> $to"
    if "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --verbose --log-file $log_file; then
      success "Synced $from <-> $to"
    else
      warn "Failed to sync $from <-> $to!"
      cat "$log_file"
    fi
  fi

  rm $log_file
}

function sync_emulators() {
  sync "$SRC_ARCADE_DIR"      "$DEST_ROMS_DIR"/arcade          "${CONFIG_DIR}/filter-arcade.txt"
  sync "$SRC_DOS_DIR"         "$DEST_ROMS_DIR"/dos             "${CONFIG_DIR}/filter-dos.txt"
  sync "$SRC_DC_DIR"          "$DEST_ROMS_DIR"/dreamcast       "${CONFIG_DIR}/filter-dreamcast.txt"
  sync "$SRC_DC_BIOS_DIR"     "$DEST_ROMS_DIR"/bios/dc         "${CONFIG_DIR}/filter-dreamcast.txt"
  sync "$SRC_GB_DIR"          "$DEST_ROMS_DIR"/gb              "${CONFIG_DIR}/filter-gb.txt"
  sync "$SRC_GBC_DIR"         "$DEST_ROMS_DIR"/gbc             "${CONFIG_DIR}/filter-gbc.txt"
  sync "$SRC_GBA_DIR"         "$DEST_ROMS_DIR"/gba             "${CONFIG_DIR}/filter-gba.txt"
  sync "$SRC_MEGADRIVE_DIR"   "$DEST_ROMS_DIR"/megadrive       "${CONFIG_DIR}/filter-megadrive.txt"
  sync "$SRC_NDS_DIR"         "$DEST_ROMS_DIR"/nds             "${CONFIG_DIR}/filter-nds.txt"
  sync "$SRC_NES_DIR"         "$DEST_ROMS_DIR"/nes             "${CONFIG_DIR}/filter-nes.txt"
  sync "$SRC_PSP_DIR"         "$DEST_ROMS_DIR"/psp             "${CONFIG_DIR}/filter-psp.txt"
  sync "$SRC_PSX_DIR"         "$DEST_ROMS_DIR"/psx             "${CONFIG_DIR}/filter-psx.txt"
  sync "$SRC_SNES_DIR"        "$DEST_ROMS_DIR"/snes            "${CONFIG_DIR}/filter-snes.txt"
}

function sync_ports() {
  sync "$SRC_STARDEW_VALLEY_DIR"   "$DEST_PORTS_DIR"/stardew_valley "${CONFIG_DIR}/filter-stardew-valley.txt"
}

sync_emulators
success "Synced emulator save games"

sync_ports
echo ""
success "Synced ports save games"
