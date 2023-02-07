#!/bin/bash
# shellcheck disable=SC2059
# Notes: Usually, error and fail should pipe to stderror, however leads to no message being displayed in ArkOS.

DEBUG=0
RCLONE_BIN="$HOME/.bin/rclone"
SYNC_STATE_DIR=${HOME}/.retro-handheld-sync-state
TIMESTAMP_FORMAT='+%Y-%m-%d %H:%M:%S'

debug() {
  if [[ $DEBUG != 0 ]]; then
    printf "[DEBU] $1\n" "${@:2}"
  fi
}

warn() { printf "[WARN] $1\n" "${@:2}"; }
success() { printf "[ OK ] $1\n" "${@:2}"; }
error() { printf "[ERR] $1\n" "${@:2}"; }

fail() {
  printf "[FAIL] $1\n" "${@:2}"
  exit 1
}

last_sync_ts() {
  local id="$1"
  if [ -f "${SYNC_STATE_DIR}/${id}.last_sync" ]; then
    date -r "${SYNC_STATE_DIR}/${id}.last_sync" "${TIMESTAMP_FORMAT}"
  else
    printf "N/A"
  fi
}
