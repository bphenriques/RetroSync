#!/bin/bash
if [ -n "$__RETRO_SYNC_MERGE_STRATEGIES_SOURCED" ]; then return; fi
__RETRO_SYNC_MERGE_STRATEGIES_SOURCED=1

merge::backup_and_restore() {
  local file_to_backup="$1"
  local file_to_keep="$2"
  local target_file="$3"

  local timestamp
  timestamp="$(date -r "${file_to_backup}" '+%Y-%m-%d_%H-%M-%S')"
  local backup="${target_file}.backup.${timestamp}"

  printf "Creating backup %s ..\n" "${backup}"
  mv "${file_to_backup}" "${backup}"
  printf "Restoring %s ..\n" "${file_to_keep}"
  mv "${file_to_keep}" "${target_file}"
}

merge::keep_left() {
  local left="$1"
  local right="$2"
  local final="$3"

  merge::backup_and_restore "${right}" "${left}" "${final}"
}

merge::keep_right() {
  local left="$1"
  local right="$2"
  local final="$3"

  merge::backup_and_restore "${left}" "${right}" "${final}"
}

merge::most_recent() {
  local left="$1"
  local right="$2"
  local final="$3"
  local date_left date_right

  date_left="$(date -r "${left}" '+%Y-%m-%d %H:%M:%S')"
  date_right="$(date -r "${right}" '+%Y-%m-%d %H:%M:%S')"

  if [ "${left}" -nt "${right}" ]; then
    printf "Left: %s\nLast modified: %s (NEWER)\n\nRight: %s\nLast modified: %s (OLDER)" "${left}" "${date_left}" "${right}" "${date_right}"
    merge::keep_left  "${left}" "${right}" "${final}"
  else
    printf "Left: %s\nLast modified: %s (OLDER)\n\nRight: %s\nLast modified: %s (NEWER)" "${left}" "${date_left}" "${right}" "${date_right}"
    merge::keep_right  "${left}" "${right}" "${final}"
  fi
}
