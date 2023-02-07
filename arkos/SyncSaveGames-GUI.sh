#!/bin/bash
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/SyncSaveGames/util.sh

# Constants
BACKTITLE="Retro Sync"

sudo chmod 666 /dev/tty1
printf "\033c" >/dev/tty1

# hide cursor
printf "\e[?25l" >/dev/tty1
dialog --clear

height="15"
width="55"
if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RG503 | tr -d '\0')"; then
  height="20"
  width="60"
fi

export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/

printf "\033c" >/dev/tty1

ExitMenu() {
  printf "\033c" >/dev/tty1
  pgrep -f oga_controls | sudo xargs kill -9
  exit 0
}

#
# Joystick controls
#
# only one instance
CONTROLS="/opt/wifi/oga_controls"
sudo $CONTROLS test-ui.sh rg552 &

function SyncAll() {
  "${SCRIPT_PATH}/SyncSaveGames.sh" |
    dialog --backtitle "${BACKTITLE}" --title "Sync All" --progressbox 16 $width >/dev/tty1
  sleep 3
}

function Sync() {
  declare -A idFolders=()
  while read -r id from to filter conflict_strategy; do
    # TODO: Does this value work if from or to contain space?
    idFolders["$id"]="$from $to $filter ${conflict_strategy:-manual}"
  done <<<$( grep -E '^[a-zA-Z]' "${SCRIPT_PATH}/SyncSaveGames/config/folders.txt")

  while true; do
    # Generate option list
    local syncOpts=()
    for id in "${!idFolders[@]}"; do
      local date="$(last_sync_ts "${id}")"
      local syncOpts+=("${id}" "${date}")
    done

    local selectId=(dialog
      --backtitle "${BACKTITLE}"
      --no-collapse
      --clear
      --title "ID      Last Sync"
      --ok-label "Sync"
      --cancel-label "Back"
      --menu "Select:" $height $width 15)

    selectedId=$("${selectId[@]}" "${syncOpts[@]}" 2>&1 >/dev/tty1) || MainMenu
    while read -r id from to filter conflict_strategy; do
      /roms2/tools/SyncSaveGames/sync.sh "$id" "$from" "$to" "${SCRIPT_PATH}/SyncSaveGames/filters/${filter}" "${conflict_strategy:-most-recent}" |
        dialog --backtitle "${BACKTITLE}" --title "Syncing ${id}..." --progressbox 15 $width >/dev/tty1
    done <<<"${selectedId} ${idFolders["${selectedId}"]}"
  done
}

function ListConflicts() {
  declare -A conflicts=()
  declare -A fromDir=()
  while read -r id from to filter conflict_strategy; do
    fromDir["${id}"]="${from}"

    while IFS=  read -r -d $'\0' file_path1; do
      rel="$(realpath -m --relative-to="${from}" "${file_path1}")"
      # Some characters are reserved - ':' is a safe bet.
      conflicts["${id}:${rel}"]="${file_path1}"
    done < <(find "${from}" -name '*..path1' -print0)
  done <<<$( grep -E '^[a-zA-Z]' "${SCRIPT_PATH}/SyncSaveGames/config/folders.txt")

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
        --menu "Select:" $height $width 15)

      selectedConflict=$("${selectConflict[@]}" "${conflictOpts[@]}" 2>&1 >/dev/tty1) || MainMenu

      local id="$(echo "${selectedConflict}" | sed -e "s/:.*$//g")"
      local from="${fromDir["${id}"]}"
      local full_path="${conflicts["${selectedConflict}"]}"
      if [[ "$(SolveFileConflict "${id}" "${from}" "${full_path}")" == "Solved" ]]; then
        unset conflicts["${selectedConflict}"]
      fi
    else
      dialog --infobox "No conflicts!" 3 $width >/dev/tty1
      sleep 3
      break
    fi
  done
}

# Id: Id of the system
# from: Root folder that is being synced
# file_path1: The absolute path to the "..path1" file that represents a conflict
SolveFileConflict() {
  local id="${1}}"
  local from="${2}"
  local file_path1="${3}"

  local file_path2="$(echo -n "$file_path1" | sed 's/\.\.path1/\.\.path2/g')"
  local left="$(realpath -m --relative-to="${from}" "${file_path1}")"
  local right="$(realpath -m --relative-to="${from}" "${file_path2}")"
  local left_date=$(date -r "${file_path1}" "${TIMESTAMP_FORMAT}")
  local right_date=$(date -r "${file_path2}" "${TIMESTAMP_FORMAT}")

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
    --menu "${msg}" $height $width 4)

  resolution="$("${chooseResolution[@]}" "${resolutionOpts[@]}" 2>&1 >/dev/tty1)" || ListConflicts
  case "${resolution}" in
    "Keep Both") "${SCRIPT_PATH}/SyncSaveGames/solve-conflicts.sh" "${file_path1}" "manual" >/dev/null ;;
    "Keep NEWER")
      "${SCRIPT_PATH}/SyncSaveGames/solve-conflicts.sh" "${file_path1}" "most-recent" >/dev/null
      echo "Solved"
      ;;
    "Keep Left")
      "${SCRIPT_PATH}/SyncSaveGames/solve-conflicts.sh" "${file_path1}" "keep-left" >/dev/null
      echo "Solved"
      ;;
    "Keep Right")
      "${SCRIPT_PATH}/SyncSaveGames/solve-conflicts.sh" "${file_path1}" "keep-right" >/dev/null
      echo "Solved"
      ;;
    *)
      dialog --infobox "ERROR: Unknown choice $choice" 15 $width >/dev/tty1
      sleep 3
      ;;
  esac
}

function CurrentConfig() {
  # List all Ids with the default-conflict-resolution
  echo "Hello"
}

MainMenu() {
  local menuOpts=(1 "Sync All" 2 "Sync..." 3 "Solve Conflicts..." 4 "Configure..." 6 "Exit")
  while true; do
    local selectMenu=(dialog
      --backtitle "${BACKTITLE}"
      --title "Main Menu"
      --no-collapse
      --clear
      --cancel-label "Exit"
      --menu "Please make your selection" $height $width 15)

    case "$("${selectMenu[@]}" "${menuOpts[@]}" 2>&1 >/dev/tty1)" in
      1) SyncAll ;;
      2) Sync ;;
      3) ListConflicts ;;
      5) CurrentConfig ;;
      6) ExitMenu ;;
    esac
  done
}

MainMenu
