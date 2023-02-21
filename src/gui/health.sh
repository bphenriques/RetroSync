#!/usr/bin/env bash

if [ -n "$__RETRO_GUI_HEALTH_SOURCED" ]; then return; fi
__RETRO_GUI_HEALTH_SOURCED=1

Health() {
  local health_indication
  health_indication="$(mktemp)"
  "${HEALTH_BIN}" > "${health_indication}"
  dialog --backtitle "${BACKTITLE}" --exit-label "OK" --textbox "${health_indication}" "${height}" "${width}" >"${tty_fd}"
  rm "${health_indication}"
}
