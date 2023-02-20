#!/usr/bin/env bash
# shellcheck disable=SC1091

SCRIPT_PATH="$(dirname "$0")"

# scripts
source "${SCRIPT_PATH}"/lib/config.sh
source "${SCRIPT_PATH}"/lib/retroarch.sh
source "${SCRIPT_PATH}"/lib/util.sh

# gui
source "${SCRIPT_PATH}"/gui/configure.sh
source "${SCRIPT_PATH}"/gui/handle-conflicts.sh
source "${SCRIPT_PATH}"/gui/health.sh
source "${SCRIPT_PATH}"/gui/sync.sh
source "${SCRIPT_PATH}"/gui/sync-all.sh

# Constants
readonly BACKTITLE="Retro Sync"
readonly SYNC_ALL_BIN="${SCRIPT_PATH}/sync-all.sh"
readonly SYNC_BIN="${SCRIPT_PATH}/sync.sh"
readonly SOLVE_CONFLICTS_BIN="${SCRIPT_PATH}/fix-conflicts.sh"
readonly HEALTH_BIN="${SCRIPT_PATH}/doctor.sh"

MainMenu() {
  local menuOpts=(1 "Sync All" 2 "Sync..." 3 "Solve Conflicts..." 4 "Configure..." 5 "Doctor" 6 "Exit")
  while true; do
    local selectMenu=(dialog
      --backtitle "${BACKTITLE}"
      --title "Main Menu"
      --no-collapse
      --clear
      --nook
      --nocancel
      --menu "Please make your selection" "${height}" "${width}" 15)

    case "$("${selectMenu[@]}" "${menuOpts[@]}" 2>&1 >/dev/tty1)" in
      1) SyncAll        ;;
      2) Sync           ;;
      3) ListConflicts  ;;
      4) Configure      ;;
      5) Health         ;;
      6) exit 0         ;;
    esac
  done
}


if [ "$#" -ne 2 ]; then
  fail "Illegal number of parameters: ./gui.sh <height> <width>"
fi

height="${1}"
width="${2}"

dialog --clear

MainMenu
