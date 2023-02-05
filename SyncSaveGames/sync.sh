#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

# shellcheck source=util.sh
source "${SCRIPT_PATH}"/util.sh

RESYNC_MARKER_DIR=${HOME}/.rclone_resync_markers

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters: ./sync.sh <from> <to> <filter_file> [manual|most-recent|keep-right|keep-left]"
    exit 1
fi

from="$1"
to="$2"
filter_file="$3"
conflict_strategy="$4"

if [ ! -d "$from" ]; then
  warning "The folder $from does not exist!"
  exit 2
fi

mkdir -p "${RESYNC_MARKER_DIR}" # create if it doesn't exist already

marker_file="$(echo "$from:$to" | sed 's/[.\/:]/_/g').done"
log_file="$(mktemp /tmp/rclone-log.XXX)"
if [ ! -f "${RESYNC_MARKER_DIR}/$marker_file" ]; then
  info "Resyncing $from <-> $to"
  "$RCLONE_BIN" mkdir "$to" --verbose

  if "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --resync --verbose --log-file "$log_file"; then
    touch "${RESYNC_MARKER_DIR}/$marker_file"
  else
    error "Failed to resync $from <-> $to!"
    cat "$log_file"
  fi
else
  info "Syncing $from <-> $to"
  if ! "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --verbose --log-file "$log_file"; then
    warn "Failed to sync $from <-> $to!"
    cat "$log_file"
  fi
fi

# Deals with filenames with spaces: https://unix.stackexchange.com/a/9499
debug "Checking conflicts in $from .."
num_conflicts=0
while IFS= read -r -d '' file; do
  (( num_conflicts++ )) || true
  "${SCRIPT_PATH}"/solve-conflicts.sh "${file}" "${conflict_strategy}"
done < <(find "${from}" -name '*..path1' -print0)

if [ "${num_conflicts}" -gt 0 ] && [ "${conflict_strategy}" != "manual" ]; then
  info "Solved ${num_conflicts} conflict(s). Syncing again .."
  if ! "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --verbose --log-file "$log_file"; then
    warn "Failed to sync after conflict resolution $from <-> $to!"
    cat "$log_file"
  fi
fi

rm "$log_file"
