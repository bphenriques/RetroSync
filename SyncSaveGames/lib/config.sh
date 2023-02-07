#!/bin/bash
if [ -n "$__RETRO_SYNC_CONFIG_SOURCED" ]; then return; fi
__RETRO_SYNC_CONFIG_SOURCED=1

readonly SYNC_STATE_DIR=${HOME}/.retro-handheld-sync-state
readonly TIMESTAMP_FORMAT='+%Y-%m-%d %H:%M:%S'

# shellcheck disable=SC2034,SC2155
readonly LOG_FILE="/tmp/retro_sync.log"

config::readAll() {
  grep -E '^[a-zA-Z]' "${SCRIPT_PATH}"/config/folders.txt
}

config::last_sync_file() {
  local id="$1"
  printf "%s/%s.last_sync" "${SYNC_STATE_DIR}" "${id}"
}

config::last_sync_ts() {
  local id="$1"
  local file
  file="$(config::last_sync_file "$id")"
  if [ -f "${file}" ]; then
    date -r "${file}" "${TIMESTAMP_FORMAT}"
  else
    printf "Never"
  fi
}
