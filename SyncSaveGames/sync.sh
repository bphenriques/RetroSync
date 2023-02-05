#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

# shellcheck source=util.sh
source "${SCRIPT_PATH}"/util.sh

SYNC_STATE_DIR=${HOME}/.retro-handheld-sync-state

if [ "$#" -ne 5 ]; then
  error "Illegal number of parameters: ./sync.sh <id> <from> <to> <filter_file> [manual|most-recent|keep-right|keep-left]"
  exit 1
fi

id="$1"
from="$2"
to="$3"
filter_file="$4"
conflict_strategy="$5"

if [ ! -d "$from" ]; then
  warning "The folder $from does not exist!"
  exit 2
fi

mkdir -p "${SYNC_STATE_DIR}" # create if it doesn't exist already

marker_file="$1".last_sync
log_file="$(mktemp /tmp/rclone-log.XXX)"
if [ ! -f "${SYNC_STATE_DIR}/$marker_file" ]; then
  info "Resyncing $id"
  "$RCLONE_BIN" mkdir "$to" --verbose

  if ! "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --resync --verbose --log-file "$log_file"; then
    error "Failed to resync $from <-> $to!"
    cat "$log_file"
  fi
else
  info "Syncing $id"
  if ! "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --verbose --log-file "$log_file"; then
    warn "Failed to sync $from <-> $to!"
    cat "$log_file"
  fi
fi

touch "${SYNC_STATE_DIR}/$marker_file"

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
