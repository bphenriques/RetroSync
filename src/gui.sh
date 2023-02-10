#!/usr/bin/env bash
# shellcheck disable=SC1091

SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/lib/config.sh
source "${SCRIPT_PATH}"/lib/util.sh

readonly SYNC_ALL_BIN="${SCRIPT_PATH}/sync-all.sh"
readonly SYNC_BIN="${SCRIPT_PATH}/sync.sh"
readonly SOLVE_CONFLICTS_BIN="${SCRIPT_PATH}/fix-conflicts.sh"
readonly HEALTH_BIN="${SCRIPT_PATH}/doctor.sh"

# Constants
readonly BACKTITLE="Retro Sync"

if [ "$#" -ne 2 ]; then
  fail "Illegal number of parameters: ./gui.sh <height> <width>"
fi

height="${1}"
width="${2}"

dialog --clear

ExitMenu() {
  exit 0
}

SyncAll() {
  "${SYNC_ALL_BIN}" | dialog --backtitle "${BACKTITLE}" --title "Sync All" --sleep 3 --progressbox "${height}" "${width}" >/dev/tty1
}

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

ListConflicts() {
  declare -A conflicts=()
  declare -A fromDir=()
  while read -r id from to filter conflict_strategy; do
    fromDir["${id}"]="${from}"

    while IFS=  read -r -d $'\0' file_path1; do
      rel="$(realpath -m --relative-to="${from}" "${file_path1}")"
      # Some characters are reserved - ':' is a safe bet.
      conflicts["${id}:${rel}"]="${file_path1}"
    done < <(find "${from}" -name '*..path1' -print0)
  done <<<"$(config::locations)"

  while true; do
    if [ "${#conflicts[@]}" -gt 0 ]; then
      # Generate all the conflicts by id and file
      local conflictOpts=()
      for key in "${!conflicts[@]}"; do
        conflictOpts+=("${key}" "")
      done

      local selectConflict=(dialog
        --backtitle "${BACKTITLE}"
        --no-collapse
        --clear
        --title "Conflicting files"
        --ok-label "Solve"
        --cancel-label "Back"
        --menu "Select:" "${height}" "${width}" 15)

      selectedConflict=$("${selectConflict[@]}" "${conflictOpts[@]}" 2>&1 >/dev/tty1) || MainMenu

      local id
      id="$(echo "${selectedConflict}" | sed -e "s/:.*$//g")"
      local from="${fromDir["${id}"]}"
      local full_path="${conflicts["${selectedConflict}"]}"
      if [[ "$(SolveFileConflict "${id}" "${from}" "${full_path}")" == "Solved" ]]; then
        unset 'conflicts["${selectedConflict}"]'
      fi
    else
      dialog --backtitle "${BACKTITLE}" --infobox "No conflicts!" 5 "${width}" >/dev/tty1
      sleep 3
      break
    fi
  done
}

# Id: Id of the system
# from: Root folder that is being synced
# file_path1: The absolute path to the "..path1" file that represents a conflict
SolveFileConflict() {
  local id="$1"
  local from="$2"
  local file_path1="$3"

  local file_path2 left right left_date right_date
  file_path2="$(echo -n "$file_path1" | sed 's/\.\.path1/\.\.path2/g')"
  left="$(realpath -m --relative-to="${from}" "${file_path1}")"
  right="$(realpath -m --relative-to="${from}" "${file_path2}")"
  left_date=$(date -r "${file_path1}" "${TIMESTAMP_FORMAT}")
  right_date=$(date -r "${file_path2}" "${TIMESTAMP_FORMAT}")

  local msg=""
  if [ "${file_path1}" -nt "${file_path2}" ]; then
    msg="Left: ${left}\nLast modified: ${left_date} (NEWER)\n\nRight: ${right}\nLast modified: ${right_date} (OLDER)"
  else
    msg="Left: ${left}\nLast modified: ${left_date} (OLDER)\n\nRight: ${right}\nLast modified: ${right_date} (NEWER)"
  fi

  local resolutionOpts=("Keep Both" "and do nothing for now" "Keep NEWER" "and backup older progress" "Keep Left" "and backup right" "Keep Right" "and backup left")
  local chooseResolution=(dialog
    --backtitle "${BACKTITLE}"
    --title "Solving Conflict (${id})"
    --no-collapse
    --clear
    --menu "${msg}" "${height}" "${width}" 4)

  resolution="$("${chooseResolution[@]}" "${resolutionOpts[@]}" 2>&1 >/dev/tty1)" || ListConflicts
  case "${resolution}" in
    "Keep Both") "${SOLVE_CONFLICTS_BIN}" "${file_path1}" "manual" >/dev/null ;;
    "Keep NEWER")
      "${SOLVE_CONFLICTS_BIN}" "${file_path1}" "most-recent" >/dev/null
      printf "Solved"
      ;;
    "Keep Left")
      "${SOLVE_CONFLICTS_BIN}" "${file_path1}" "keep-left" >/dev/null
      printf "Solved"
      ;;
    "Keep Right")
      "${SOLVE_CONFLICTS_BIN}" "${file_path1}" "keep-right" >/dev/null
      printf "Solved"
      ;;
    *)
      dialog --backtitle "${BACKTITLE}" --infobox "ERROR: Unknown resolution $resolution" 0 "${width}" >/dev/tty1
      sleep 3
      ;;
  esac
}

ListConfig() {
  echo "Hello"
}

Health() {
  local health_indication
  health_indication="$(mktemp)"
  "${HEALTH_BIN}" > "${health_indication}"
  dialog --backtitle "${BACKTITLE}" --exit-label "OK" --textbox "${health_indication}" "${height}" "${width}" >/dev/tty1
  rm "${health_indication}"
}

MainMenu() {
  local menuOpts=(1 "Sync All" 2 "Sync..." 3 "Solve Conflicts..." 4 "Config..." 5 "Verify Installation" 6 "Exit")
  while true; do
    local selectMenu=(dialog
      --backtitle "${BACKTITLE}"
      --title "Main Menu"
      --no-collapse
      --clear
      --cancel-label "Exit"
      --nook
      --nocancel
      --menu "Please make your selection" "${height}" "${width}" 15)

    case "$("${selectMenu[@]}" "${menuOpts[@]}" 2>&1 >/dev/tty1)" in
      1) SyncAll        ;;
      2) Sync           ;;
      3) ListConflicts  ;;
      4) ListConfig     ;;
      5) Health         ;;
      6) ExitMenu       ;;
    esac
  done
}

MainMenu
