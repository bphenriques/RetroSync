#!/usr/bin/env bash
# shellcheck disable=SC1091

SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/lib/util.sh
source "${SCRIPT_PATH}"/lib/rclone.sh
source "${SCRIPT_PATH}"/lib/config.sh

id="$1"
from="$2"
to="$3"
filter_file="$4"
on_conflict="$5"

debug "Checking conflicts in %s .." "${from}"
declare -a conflicts=()
while IFS=  read -r -d $'\0' file; do
  conflicts+=("$file")
done < <(find "${from}" -name '*..path1' -print0)

num_conflicts="${#conflicts[@]}"
if [ "${num_conflicts}" -gt 0 ]; then
  warning "Found %s conflict(s)!" "${num_conflicts}"

  if [ "${on_conflict}" != "manual" ]; then
    for file in "${conflicts[@]}"; do
      if ! "${SCRIPT_PATH}"/fix-conflicts.sh "${file}" "${on_conflict}"; then
        fail "Failed to solve conflicts for %s (%s)" "${file}" "${on_conflict}"
      fi
    done

    printf "Addressed %s conflict(s). Syncing again ..\n" "${num_conflicts}"
    if ! rclone::bisync "${from}" "${to}" "${filter_file}" 0; then
      error "Failed to sync %s! See %s for more details" "${id}" "${RETROSYNC[logFile]}"
    fi
  else
    debug "Skipping as the resolution is set to 'manual'\n"
  fi
fi
