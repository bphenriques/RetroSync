#!/usr/bin/env bash
SCRIPT_PATH="$(dirname "$0")"

# shellcheck disable=SC1091
source "${SCRIPT_PATH}"/lib/config.sh
# shellcheck disable=SC1091
source "${SCRIPT_PATH}"/lib/rclone.sh

if [[ ! -f "${RETROSYNC[userCfg]}" ]]; then
  mkdir -p "${RETROSYNC[userCfgDir]}"
  touch "${RETROSYNC[userCfg]}"
fi

config::set deviceId "${HOSTNAME:-$HOST}" "${RETROSYNC[userCfg]}"

cp -f "${SCRIPT_PATH}"/resources/filters/* "${RETROSYNC[rcloneFilterDir]}"
