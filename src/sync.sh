#!/usr/bin/env bash
# shellcheck disable=SC1091

SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/lib/util.sh
source "${SCRIPT_PATH}"/lib/rclone.sh
source "${SCRIPT_PATH}"/lib/config.sh

if [ "$#" -ne 1 ]; then
  fail "Illegal number of parameters: ./sync.sh <id>"
fi

id="$1"
while IFS=$'\t' read -r id from to filter on_conflict; do
  filter_file="${RETROSYNC[rcloneFilterDir]}/${filter}"
  [[ ! -d "${from}" ]] && fail "The from folder %s does not exist!" "${from}"
  [[ ! -f "${filter_file}" ]] && fail "The filter file %s does not exist!" "${filter_file}"
  case "${on_conflict}" in
    manual|most-recent|keep-left|keep-right)  ;;
    *)                                        fail "Unrecognized conflict strategy: %s" "${on_conflict}";;
  esac

  printf "From: %s\n" "${from}"
  printf "To: %s\n" "${to}"
  printf "Filter: %s\n" "${filter}"
  printf "On Conflict: %s\n" "${on_conflict}"
  printf "\n"
  printf "Last Sync: %s\n" "$(config::last_sync_ts "${id}")"

  debug "Ensuring that %s exists ..." "${RETROSYNC[stateDir]}"
  mkdir -p "${RETROSYNC[stateDir]}" # create if it doesn't exist already

  marker_file="$(config::last_sync_file "${id}")"
  debug "Marker file: %s" "${marker_file}"

  if [ -f "${marker_file}" ]; then
    debug "Syncing %s .." "${id}"
    if rclone::bisync "${from}" "${to}" "${filter_file}" 0; then
      touch "${marker_file}"
      "${SCRIPT_PATH}"/fix-dir-conflicts.sh "${id}" "${from}" "${to}" "${filter_file}" "${on_conflict}"
    else
      error "Failed to sync %s! See %s for more details" "${id}" "${RETROSYNC[logFile]}"
    fi
  else
    debug "First time syncing! Ensuring that directory exists beforehand .."
    if rclone::mkdir "${to}" && rclone::bisync "${from}" "${to}" "${filter_file}" 1; then
      touch "${marker_file}"
    else
      error "Failed to resync %s! See %s for more details" "${id}" "${RETROSYNC[logFile]}"
    fi
  fi
done <<< "$(config::location_config "${id}")"
