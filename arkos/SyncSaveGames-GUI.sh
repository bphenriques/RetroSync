#!/bin/bash
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/SyncSaveGames/util.sh

# Constants
BACKTITLE="Retro Handheld Sync"

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
  "${SCRIPT_PATH}/SyncSaveGames.sh" | \
    dialog --backtitle "${BACKTITLE}" --title "Sync All" --progressbox 16 $width > /dev/tty1
}

function SelectiveSync() {
  # Create Associative Array
  declare -A folders=()
  while read -r id from to filter conflict_strategy; do
    folders["$id"]="$from $to $filter ${conflict_strategy:-manual}"
  done <<< $(grep -E '^[a-zA-Z]' "${SCRIPT_PATH}/SyncSaveGames/config/folders.txt")

  while true; do
    # Generate option list
    options=()
    for id in "${!folders[@]}"; do
      date="$(last_sync_ts "${id}")"
      options+=( "${id}" "${date}" )
    done

    selection=(dialog \
    --backtitle "${BACKTITLE}" \
    --no-collapse \
    --clear \
    --title "ID      Last Sync" \
    --ok-label "Sync" \
    --cancel-label "Back" \
    --menu "Select:" $height $width 15)

    choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1) || MainMenu
    for choice in $choices; do
      case $choice in
        *)
          while read -r id from to filter conflict_strategy; do
            /roms2/tools/SyncSaveGames/sync.sh "$id" "$from" "$to" "${SCRIPT_PATH}/SyncSaveGames/filters/${filter}" "${conflict_strategy:-most-recent}" | \
              dialog --backtitle "${BACKTITLE}" --title "Syncing ${id}..." --progressbox 15 $width > /dev/tty1
          done <<< "${choice} ${folders[$choice]}"
          ;;
      esac
    done
  done
}

function CurrentConfig() {
  echo "Hello"
}

function ListConflicts(){
  declare -A folders=()
  total_num_conflicts=0
  while read -r id from to filter conflict_strategy; do
    total_num_conflicts="$((total_num_conflicts + "$(find "${from}" -name '*..path1' | wc -l)"))"
    folders["$id"]="${from}"
  done <<< $(grep -E '^[a-zA-Z]' "${SCRIPT_PATH}/SyncSaveGames/config/folders.txt")

  if [ "${total_num_conflicts}" -gt 0 ]; then
    while true; do
      # Generate option list
      options=()
      for id in "${!folders[@]}"; do
        from="${folders[$id]}"
        num_conflicts="$(find "${from}" -name '*..path1' | wc -l)"
        if [ "${num_conflicts}" -gt 0 ]; then
          options+=( "${id}" "${num_conflicts}" )
        fi
      done

      selection=(dialog \
      --backtitle "${BACKTITLE}" \
      --no-collapse \
      --clear \
      --title "ID      #Conflicts" \
      --ok-label "Resolve" \
      --cancel-label "Back" \
      --menu "Select:" $height $width 15)

      choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1) || MainMenu
      for choice in $choices; do
        case $choice in
          *)
            while read -r id from; do
              SolveConflicts "${id}" "${from}"
            done <<< "${choice} ${folders[$choice]}"
            ;;
        esac
      done
    done
  else
    dialog --infobox "No conflicts present!" 3 $width > /dev/tty1
    sleep 3
  fi
}

SolveConflicts() {
  local id="$1"
  local from="$2"

  from=/roms2/gba
  conflicts=()
  while IFS=  read -r -d $'\0' file; do
    conflicts+=("$file")
  done < <(find "${from}" -name '*..path1' -print0)

  for file_path1 in "${conflicts[@]}"; do
    file_path2="$(echo -n "$file_path1" | sed 's/\.\.path1/\.\.path2/g')"
    left="$(realpath -m --relative-to="${from}" "${file_path1}")"
    right="$(realpath -m --relative-to="${from}" "${file_path2}")"
    left_date=$(date -r "${file_path1}" "${TIMESTAMP_FORMAT}")
    right_date=$(date -r "${file_path2}" "${TIMESTAMP_FORMAT}")

    msg=""
    if [ "${file_path1}" -nt "${file_path2}" ]; then
      msg="Left: ${left}\nLast modified: ${left_date} (NEWER)\n\nRight: ${right}\nLast modified: ${right_date} (OLDER)"
    else
      msg="Left: ${left}\nLast modified: ${left_date} (OLDER)\n\nRight: ${right}\nLast modified: ${right_date} (NEWER)"
    fi

    options=("Keep Both" "and do nothing for now" "Keep NEWER" "and backup older progress" "Keep Left" "and backup right" "Keep Right" "and backup left")
    selection=(dialog \
      --backtitle "${BACKTITLE}" \
      --title "Conflict (${id})" \
      --no-collapse \
      --clear \
      --menu "${msg}" $height $width 4)

    choices=$("${selection[@]}" "${options[@]}" 2>&1 >/dev/tty1)
    for choice in $choices; do
      case $choice in
      "Keep Both")
        while read -r id from; do
          dialog --infobox "Solving conflict for ... id=${id} from=${from} with BOTH" 15 $width > /dev/tty1
          sleep 3
        done <<< "${choice} ${folders[$choice]}"
        ;;
      "Keep NEWER")
        while read -r id from; do
          dialog --infobox "Solving conflict for ... id=${id} from=${from} with BOTH" 15 $width > /dev/tty1
          sleep 3
        done <<< "${choice} ${folders[$choice]}"
        ;;
      "Keep Left")
        while read -r id from; do
          dialog --infobox "Solving conflict for ... id=${id} from=${from} with BOTH" 15 $width > /dev/tty1
          sleep 3
        done <<< "${choice} ${folders[$choice]}"
        ;;
      "Keep Right")
        while read -r id from; do
          dialog --infobox "Solving conflict for ... id=${id} from=${from} with BOTH" 15 $width > /dev/tty1
          sleep 3
        done <<< "${choice} ${folders[$choice]}"
        ;;
      *)
        dialog --infobox "ERROR: Unknown choice $choice" 15 $width > /dev/tty1
        sleep 3
        ;;
      esac
    done
  done
}

MainMenu() {
  mainoptions=(1 "Sync All" 2 "Sync..." 3 "Solve Conflicts" 4 "Configure" 6 "Exit")
  while true; do
    mainselection=(dialog
      --backtitle "${BACKTITLE}"
      --title "Main Menu"
      --no-collapse
      --clear
      --cancel-label "Select + Start to Exit"
      --menu "Please make your selection" $height $width 15)

    mainchoices=$("${mainselection[@]}" "${mainoptions[@]}" 2>&1 >/dev/tty1)

    for mchoice in $mainchoices; do
      case $mchoice in
        1) SyncAll ;;
        2) SelectiveSync ;;
        3) ListConflicts ;;
        5) CurrentConfig ;;
        6) ExitMenu ;;
      esac
    done
  done
}

MainMenu
