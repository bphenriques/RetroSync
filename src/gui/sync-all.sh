#!/usr/bin/env bash

if [ -n "$__RETRO_GUI_SYNC_ALL_SOURCED" ]; then return; fi
__RETRO_GUI_SYNC_ALL_SOURCED=1

SyncAll() {
  "${SYNC_ALL_BIN}" | dialog --backtitle "${BACKTITLE}" --title "Sync All" --sleep 3 --progressbox "${height}" "${width}" >/dev/tty1
}
