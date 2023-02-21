#!/usr/bin/env bash
# shellcheck disable=SC2059

if [ -n "$__RETRO_SYNC_UTIL_SOURCED" ]; then return; fi
__RETRO_SYNC_UTIL_SOURCED=1

debug() {
  [[ "${RETROSYNC[debug]}" != 0 ]] && printf "$1\n" "${@:2}"
}

warn() { printf "Warning! $1\n" "${@:2}"; }

# Notes: Usually, error and fail should pipe to stderror, however leads to no message being displayed in ArkOS.
error() { printf "Error! $1\n" "${@:2}"; }

fail() {
  printf "Fail!! $1\n" "${@:2}"
  exit 1
}
