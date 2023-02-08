#!/usr/bin/env bash

if [ -n "$__RETRO_SYNC_CONFIG_SOURCED" ]; then return; fi
__RETRO_SYNC_CONFIG_SOURCED=1

readonly TIMESTAMP_FORMAT='+%Y-%m-%d %H:%M:%S'
readonly XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Default settings
declare -A RETROSYNC

config::default() {
  [[ ! -f "${RETROSYNC[userCfg]}" ]] && mkdir -p "${RETROSYNC[userCfgDir]}"

  RETROSYNC=()
  RETROSYNC[installDir]="${HOME}/.bin/retrosync"
  RETROSYNC[userCfgDir]="${XDG_CONFIG_HOME}/retrosync"
  RETROSYNC[userCfg]="${RETROSYNC[userCfgDir]}/retrosync.cfg"
  RETROSYNC[locationsCfg]="${RETROSYNC[userCfgDir]}/locations.txt"
  RETROSYNC[stateDir]="${XDG_STATE_HOME}/retrosync"
  RETROSYNC[logFile]="$(test -d /dev/shm/ && printf "/dev/shm/retrosync.log" || printf "/tmp/retrosync.log")" # Store in RAM if possible
  RETROSYNC[rcloneBin]="${HOME}/.bin/rclone"
  RETROSYNC[rcloneFilterDir]="${RETROSYNC[userCfgDir]}/filters"
  RETROSYNC[maxDeleteProtectionPercent]=100 # Defaults to 50 in rclone
  RETROSYNC[debug]=0
  RETROSYNC[defaultMergeStrategy]=most-recent
}

# Load configuration to a global  array (Only Bash 4.3 supports passing arrays as argument and then using local -n)
# declare -A RETROSYNC
# config::load "<path>"
config::load() {
  local config=${1}

  if [[ ! -f "${config}" ]]; then
    printf "Error: config not found: %s\n" "${config}"
    exit 1
  fi

  # Remove any previous values and recomputes defaults and any overridden key within the file
  config::resetDefault

  while read line; do
    local option="$(echo "${line}" | sed -e 's/[[:space:]]*=.*$//')"
    local value="$(echo "${line}" | sed -e 's/^.*=[[:space:]]*//')"
    RETROSYNC["${option}"]="${value}"
  done < <(grep -E '^[a-zA-Z]' "${config}")
}

config::last_sync_file() {
  local id="$1"
  printf "%s/%s.last_sync" "${RETROSYNC[stateDir]}" "${id}"
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

config::default
config::load "${RETROSYNC[userCfg]}"



