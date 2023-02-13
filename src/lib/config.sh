#!/usr/bin/env bash

if [ -n "$__RETRO_SYNC_CONFIG_SOURCED" ]; then return; fi
__RETRO_SYNC_CONFIG_SOURCED=1

readonly TIMESTAMP_FORMAT='+%Y-%m-%d %H:%M:%S'
readonly XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Default settings
declare -A RETROSYNC

config::default() {
  RETROSYNC=()

  # Stable defaults
  RETROSYNC[userCfgDir]="${XDG_CONFIG_HOME}/retrosync"
  RETROSYNC[userCfg]="${RETROSYNC[userCfgDir]}/retrosync.cfg"
  RETROSYNC[locationsCfg]="${RETROSYNC[userCfgDir]}/locations.txt"
  RETROSYNC[stateDir]="${XDG_STATE_HOME}/retrosync"
  RETROSYNC[logFile]="$(test -d /dev/shm/ && printf "/dev/shm/retrosync.log" || printf "/tmp/retrosync.log")" # Store in RAM if possible
  RETROSYNC[rcloneBin]="${HOME}/.bin/rclone"
  RETROSYNC[rcloneFilterDir]="${RETROSYNC[userCfgDir]}/filters"
  RETROSYNC[maxDeleteProtectionPercent]=100 # Defaults to 50 in rclone
  RETROSYNC[defaultMergeStrategy]=most-recent
  RETROSYNC[debug]=0
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

  while read -r line; do
    local option value
    option="$(echo "${line}" | sed -e 's/[[:space:]]*=.*$//')"
    value="$(echo "${line}" | sed -e 's/^.*=[[:space:]]*//')"
    RETROSYNC["${option}"]="${value}"
  done < <(grep -E '^[a-zA-Z]' "${config}")
}

config::locations() {
  grep -E '^[a-zA-Z]' "${RETROSYNC[locationsCfg]}"
}

config::set() {
  local key="${1}"
  local value="${2}"
  local keyValue="${key}=${value}"

  RETROSYNC["${key}"]="${value}"

  if [[ ! -f "${RETROSYNC[userCfg]}" ]]; then
    echo "${keyValue}" >> "${RETROSYNC[userCfg]}"
  elif grep -E "^[[:space:]]*${key}[[:space:]]*=.*$" "${RETROSYNC[userCfg]}" >/dev/null; then
    sed -iE "s/^[[:space:]]*${key}[[:space:]]*=.*$/${keyValue}/" "${RETROSYNC[userCfg]}"
  else
    echo "${keyValue}" >> "${RETROSYNC[userCfg]}"
  fi
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

# Ensure this exists
if [[ ! -f "${RETROSYNC[userCfg]}" ]]; then
  mkdir -p "${RETROSYNC[userCfgDir]}"
  touch "${RETROSYNC[userCfg]}"
fi

# Ensure this exists
if [[ ! -f "${RETROSYNC[locationsCfg]}" ]]; then
  touch "${RETROSYNC[locationsCfg]}"
fi

# Ensure this exists
mkdir -p "${RETROSYNC[rcloneFilterDir]}"

config::load "${RETROSYNC[userCfg]}"



