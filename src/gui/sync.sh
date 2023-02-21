#!/usr/bin/env bash

if [ -n "$__RETRO_GUI_SYNC_SOURCED" ]; then return; fi
__RETRO_GUI_SYNC_SOURCED=1

Sync() {
  while true; do
    # Generate option list
    local syncOpts=()
    for id in $(config::location_ids); do
      local last_sync
      last_sync="$(config::last_sync_ts "${id}")"
      syncOpts+=("${id}" "${last_sync}")
    done

    if [ "${#syncOpts[@]}" -gt 0 ]; then
      local selectId=(dialog
        --backtitle "${BACKTITLE}"
        --no-collapse
        --clear
        --title "ID              Last Sync"
        --ok-label "Sync"
        --cancel-label "Back"
        --menu "Select:" "${height}" "${width}" 15)

      selectedId=$("${selectId[@]}" "${syncOpts[@]}" 2>&1 >"${tty_fd}") || MainMenu
      "${SYNC_BIN}" "${selectedId}" |
        dialog --backtitle "${BACKTITLE}" --title "Syncing ${selectedId}..." --progressbox "${height}" "${width}" >"${tty_fd}"
      sleep 3
    else
      dialog --backtitle "${BACKTITLE}" --infobox "No available locations!" 3 "${width}" >"${tty_fd}"
      sleep 3
      break
    fi
  done
}
