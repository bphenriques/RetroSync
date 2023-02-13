#!/usr/bin/env bash

if [ -n "$__RETRO_GUI_SYNC_SOURCED" ]; then return; fi
__RETRO_GUI_SYNC_SOURCED=1

Sync() {
  declare -A idConfig=()
  while read -r id from to filter conflict_strategy; do
    # TODO: Does this work if 'from' or 'to' contain space?
    idConfig["$id"]="${from} ${to} ${filter} ${conflict_strategy:-"${RETROSYNC[defaultMergeStrategy]}"}"
  done <<<"$(config::locations)"

  while true; do
    # Generate option list
    local syncOpts=()
    for id in "${!idConfig[@]}"; do
      local last_sync
      last_sync="$(config::last_sync_ts "${id}")"
      syncOpts+=("${id}" "${last_sync}")
    done

    local selectId=(dialog
      --backtitle "${BACKTITLE}"
      --no-collapse
      --clear
      --title "ID              Last Sync"
      --ok-label "Sync"
      --cancel-label "Back"
      --menu "Select:" "${height}" "${width}" 15)

    selectedId=$("${selectId[@]}" "${syncOpts[@]}" 2>&1 >/dev/tty1) || MainMenu
    while read -r id from to filter conflict_strategy; do
      "${SYNC_BIN}" "${id}" "${from}" "${to}" "${filter}" "${conflict_strategy:-"${RETROSYNC[defaultMergeStrategy]}"}" |
        dialog --backtitle "${BACKTITLE}" --title "Syncing ${id}..." --progressbox "${height}" "${width}" >/dev/tty1
      sleep 3
    done <<<"${selectedId} ${idConfig["${selectedId}"]}"
  done
}
