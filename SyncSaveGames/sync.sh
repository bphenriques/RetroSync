#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

CONFIG_DIR=${SCRIPT_PATH}/config
source "${SCRIPT_PATH}"/util.sh

RESYNC_MARKER_DIR=${HOME}/.rclone_resync_markers

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters: ./sync.sh <from> <to> <filter>"
    return
fi

from="$1"
to="$2"
filter_file="$3"

if [ ! -d "$from" ]; then
  warning "The folder $1 does not exist!"
  return
fi

mkdir -p ${RESYNC_MARKER_DIR} # create if it doesn't exist already

marker_file="$(echo $from:$to | sed 's/[.\/:]/_/g').done"
log_file="$(mktemp /tmp/rclone-log.XXX)"
if [ ! -f "${RESYNC_MARKER_DIR}/$marker_file" ]; then
  info "Resyncing $from <-> $to"
  "$RCLONE_BIN" mkdir "$to" --verbose

  if "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --resync --verbose --log-file $log_file; then
    touch "${RESYNC_MARKER_DIR}/$marker_file"
    success "Resynced $from <-> $to"
  else
    error "Failed to resync $from <-> $to!"
    cat "$log_file"
  fi
else
  info "Syncing $from <-> $to"
  if "$RCLONE_BIN" bisync "$from" "$to" --filter-from "$filter_file" --verbose --log-file $log_file; then
    success "Synced $from <-> $to"
  else
    warn "Failed to sync $from <-> $to!"
    cat "$log_file"
  fi
fi

rm $log_file
