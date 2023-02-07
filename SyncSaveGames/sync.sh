#!/bin/bash
# shellcheck disable=SC1091

SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/lib/util.sh
source "${SCRIPT_PATH}"/lib/rclone.sh
source "${SCRIPT_PATH}"/lib/config.sh

review_conflicts() {
  id="$1"
  from="$2"
  to="$3"
  filter_file="$4"
  on_conflict="$5"

  debug "Checking conflicts in %s .." "${from}"
  conflicts=()
  while IFS=  read -r -d $'\0' file; do
    conflicts+=("$file")
  done < <(find "${from}" -name '*..path1' -print0)

  num_conflicts="${#conflicts[@]}"
  if [ "${num_conflicts}" -gt 0 ]; then
    warning "Found %s conflict(s)!" "${num_conflicts}"

    if [ "${on_conflict}" != "manual" ]; then
      for file in "${conflicts[@]}"; do
        if ! "${SCRIPT_PATH}"/solve-conflicts.sh "${file}" "${on_conflict}"; then
          fail "Failed to solve conflicts for %s (%s)" "${file}" "${on_conflict}"
        fi
      done

      printf "Addressed %s conflict(s). Syncing again ..\n" "${num_conflicts}"
      if ! "${RCLONE_BIN}" bisync "${from}" "${to}" --filter-from "${filter_file}" --verbose --log-file "${LOG_FILE}"; then
        warn "Failed to sync ${id} after fixing the conflicts"
        cat "$LOG_FILE"
      fi
    else
      debug "Skipping as the resolution is set to 'manual'\n"
    fi
  fi
}

if [ "$#" -ne 5 ]; then
  fail "Illegal number of parameters: ./sync.sh <id> <from> <to> <filter> [manual|most-recent|keep-right|keep-left]"
fi

id="$1"
from="$2"
to="$3"
filter="$4"
on_conflict="$5"

filter_file="${SCRIPT_PATH}/filters/${filter}"

[[ ! -d "${from}" ]] && fail "The from folder %s does not exist!" "${from}"
[[ ! -f "${filter_file}" ]] && fail "The filter file %s does not exist!" "${filter_file}"

printf "Id: %s\n" "${id}"
printf "From: %s\n" "${from}"
printf "To: %s\n" "${to}"
printf "Filter: %s\n" "${filter}"
printf "On Conflict: %s\n" "${on_conflict}"
printf "\n"
printf "Last Sync: %s\n" "$(config::last_sync_ts "${id}")"

debug "Ensuring that %s exists ..." "${SYNC_STATE_DIR}"
mkdir -p "${SYNC_STATE_DIR}" # create if it doesn't exist already

marker_file="$(config::last_sync_file "${id}")"
debug "Marker file: %s" "${marker_file}"

if [ -f "${marker_file}" ]; then
  debug "Syncing %s .." "${id}"
  if rclone::bisync "${from}" "${to}" "${filter_file}" 0; then
    touch "${marker_file}"
    review_conflicts "${id}" "${from}" "${to}" "${filter_file}" "${on_conflict}"
  else
    error "Failed to sync %s! See %s for more details" "${id}" "${LOG_FILE}"
  fi
else
  debug "First time syncing! Ensuring that directory exists beforehand .."
  if rclone::mkdir "${to}" && rclone::bisync "${from}" "${to}" "${filter_file}" 1; then
    touch "${marker_file}"
  else
    error "Failed to resync %s! See %s for more details" "${id}" "${LOG_FILE}"
  fi
fi
