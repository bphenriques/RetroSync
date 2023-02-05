#!/bin/bash

SYNC_STATE_DIR=${HOME}/.retro-handheld-sync-state

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
  dialog --infobox "Syncing all folders ..." 3 $width > /dev/tty1
  while read -r id from to filter conflict_strategy; do
    dialog --infobox "Syncing ${id} ...\n\n  From: $from\n  To: $to\n  filter: $filter\n  on-conflict: $conflict_strategy" 8 $width > /dev/tty1
    /roms2/tools/SyncSaveGames/sync.sh "$id" "$from" "$to" /roms2/tools/SyncSaveGames/filters/${filter} "${conflict_strategy:-most-recent}" > /dev/null
  done <<< $(grep -E '^[a-zA-Z]' "/roms2/tools/SyncSaveGames/config/folders.txt")

  dialog --infobox "Sync complete!" 3 $width > /dev/tty1
  sleep 3
}

function SelectiveSync() {
  # Create Associative Array
  declare -A folders=()
  while read -r id from to filter conflict_strategy; do
    folders["$id"]="$from $to $filter ${conflict_strategy:-manual}"
  done <<< $(grep -E '^[a-zA-Z]' "/roms2/tools/SyncSaveGames/config/folders.txt")

  while true; do
    # Generate option list
    options=()
    for id in "${!folders[@]}"; do
      date="$(date -r "${SYNC_STATE_DIR}/${id}.last_sync" '+%Y-%m-%d %H:%M:%S')"
      options+=( "${id}" "${date}" )
    done

    selection=(dialog \
    --backtitle "Retro Games Sync" \
    --no-collapse \
    --clear \
    --title "ID  Last Sync" \
    --ok-label "Sync" \
    --cancel-label "Back" \
    --menu "Select:" $height $width 15)

    choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1) || MainMenu
    for choice in $choices; do
      case $choice in
        *)
          while read -r id from to filter conflict_strategy; do
            dialog --infobox "Syncing ${id} ...\n\n  From: $from\n  To: $to\n  filter: $filter\n  on-conflict: $conflict_strategy" 8 $width > /dev/tty1
            /roms2/tools/SyncSaveGames/sync.sh "$id" "$from" "$to" /roms2/tools/SyncSaveGames/filters/${filter} "${conflict_strategy:-most-recent}" > /dev/null
            dialog --infobox "Sync complete!" 3 $width > /dev/tty1
            sleep 3
          done <<< "${choice} ${folders[$choice]}"
          ;;
      esac
    done
  done
}

function CurrentConfig() {
  unset options
  while read -r filter from to conflict_strategy; do
    options+=("$from" "$to")
  done <<< $(grep -E '^[a-zA-Z]' "/roms2/tools/SyncSaveGames/config/folders.txt")

  while true; do
    selection=(dialog \
    --backtitle "Backtitle" \
    --title "Title" \
    --no-collapse \
    --clear \
    --cancel-label "Back" \
    --radiolist "" $height $width 15)

    choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1) || MainMenu

    for choice in $choices; do
      case $choice in
        *) echo "You chose: $choice" ;;
      esac
    done
  done
}

#- Solve Conflicts
#-     ... [File] modified at X (NEWER)
#-     ... [File] modifed at Y (OLDER)
#-     Skip/Keep-Left/Keep-Right

function SolveConflicts(){
  # Create Associative Array
  declare -A folders=()
  while read -r id from to filter conflict_strategy; do
    folders["$id"]="$from $to $filter ${conflict_strategy:-manual}"
  done <<< $(grep -E '^[a-zA-Z]' "/roms2/tools/SyncSaveGames/config/folders.txt")

  while true; do
    # Generate option list
    options=()
    for id in "${!folders[@]}"; do
      num_conflicts="$(ls *..path1 | wc -l)"
      date="$(date -r "${SYNC_STATE_DIR}/${id}.last_sync" '+%Y-%m-%d %H:%M:%S')"
      options+=( "${id}" "${date}" )
    done

    selection=(dialog \
    --backtitle "Retro Games Sync" \
    --no-collapse \
    --clear \
    --title "ID  Num Conflicts" \
    --ok-label "Solve" \
    --cancel-label "Back" \
    --menu "Select:" $height $width 15)

    choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1) || MainMenu
    for choice in $choices; do
      case $choice in
        *)
          while read -r id from to filter conflict_strategy; do
            dialog --infobox "Syncing ${id} ...\n\n  From: $from\n  To: $to\n  filter: $filter\n  on-conflict: $conflict_strategy" 8 $width > /dev/tty1
            /roms2/tools/SyncSaveGames/sync.sh "$id" "$from" "$to" /roms2/tools/SyncSaveGames/filters/${filter} "${conflict_strategy:-most-recent}" > /dev/null
            dialog --infobox "Sync complete!" 3 $width > /dev/tty1
            sleep 3
          done <<< "${choice} ${folders[$choice]}"
          ;;
      esac
    done
  done



  while read -r filter from to conflict_strategy; do
    while IFS= read -r -d '' file_path1; do
      local file_path2="$(echo -n "$file_path1" | sed 's/\.\.path1/\.\.path2/g')"
      local final_file="$(echo -n "$file_path1" | sed 's/\.\.path1//g')"

      if [ -f "$file_path2" ]; then
        options=("Keep 1" "Description 1" "Keep 2" "Description 2")
        while true; do
          selection=(dialog \
          --backtitle "Backtitle" \
          --title "Title" \
          --no-collapse \
          --clear \
          --cancel-label "Back" \
          --menu "How do you want to handle?" $height $width 15)

          choices=$("${selection[@]}" "${options[@]}" 2>&1 > /dev/tty1) || MainMenu

          for choice in $choices; do
            case $choice in
              *)
                dialog --infobox "You choose $choice!" 3 $width > /dev/tty1
                sleep 3
                ;;
            esac
          done
        done
      fi
    done < <(find "${from}" -name '*..path1' -print0)

    output=$(/roms2/tools/SyncSaveGames/sync.sh "$from" "$to" /roms2/tools/SyncSaveGames/filters/${filter}.txt "${conflict_strategy:-most-recent}")
  done <<< $(grep -E '^[a-zA-Z]' "/roms2/tools/SyncSaveGames/config/folders.txt")
}

MainMenu() {
  mainoptions=(1 "Sync All" 2 "Sync .." 3 "Solve Conflicts" 4 "Manage Backups" 5 "Configure" 6 "Exit")
  while true; do

    mainselection=(dialog
      --backtitle "Retro Gaming Sync"
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
        3) SolveConflicts ;;
        4) ;;
        5) CurrentConfig ;;
        6) ExitMenu ;;
      esac
    done
  done
}

MainMenu
