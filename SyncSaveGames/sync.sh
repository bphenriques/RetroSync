#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

# shellcheck source=util.sh
source "${SCRIPT_PATH}"/util.sh

if [ "$#" -ne 5 ]; then
  fail "Illegal number of parameters: ./sync.sh <id> <from> <to> <filter_file> [manual|most-recent|keep-right|keep-left]"
fi

id="$1"
from="$2"
to="$3"
filter_file="$4"
conflict_strategy="$5"

if [ ! -d "$from" ]; then
  warning "The folder %s does not exist!" "$from"
  exit 2
fi

printf "Last Sync: %s\n" "$(last_sync_ts "${id}")"
printf "From: %s\n" "${from}"
printf "To: %s\n" "${to}"
printf "Filter: %s\n" "$(basename "$filter_file")"
printf "On Conflict: %s\n" "${conflict_strategy}"

mkdir -p "${SYNC_STATE_DIR}" # create if it doesn't exist already

marker_file="$1".last_sync
log_file="$(mktemp /tmp/rclone-log.XXX)"
if [ ! -f "${SYNC_STATE_DIR}/$marker_file" ]; then
  printf "First time syncing ..\n"
  "$RCLONE_BIN" mkdir "$to" --verbose # Ensure directory exists
  if ! "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --resync --verbose --log-file "$log_file"; then
    error "Failed to resync $from <-> $to!"
    cat "$log_file"
  fi
else
  if ! "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --verbose --log-file "$log_file"; then
    error "Failed to sync $from <-> $to!"
    cat "$log_file"
  fi
fi

touch "${SYNC_STATE_DIR}/$marker_file"

debug "Checking conflicts in $from .."
conflicts=()
while IFS=  read -r -d $'\0' file; do
  conflicts+=("$file")
done < <(find "${from}" -name '*..path1' -print0)

num_conflicts="${#conflicts[@]}"
if [ "${num_conflicts}" -gt 0 ]; then
  warn "Found ${num_conflicts} conflict(s)!"

  for file in "${conflicts[@]}"; do
    "${SCRIPT_PATH}"/solve-conflicts.sh "${file}" "${conflict_strategy}"
  done

  if [ "${conflict_strategy}" != "manual" ]; then
    printf "Addressed ${num_conflicts} conflict(s). Syncing again ..\n"
    if ! "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --verbose --log-file "$log_file"; then
      warn "Failed to sync ${id} after fixing the conflicts"
      cat "$log_file"
    fi
  fi
fi

if [[ $DEBUG != 0 ]]; then
  cat "$log_file"
fi

rm "$log_file"
