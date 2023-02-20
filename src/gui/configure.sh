#!/usr/bin/env bash

if [ -n "$__RETRO_GUI_CONFIGURE_SOURCED" ]; then return; fi
__RETRO_GUI_CONFIGURE_SOURCED=1

gui::config::defaultConflictResolution() {
  local resolutionOpts=("manual" "Do nothing" "most-recent" "Keep most recent file" "keep-left" "Keep local file" "keep-right" "Keep remote file")
  local chooseResolution=(dialog
    --backtitle "${BACKTITLE}"
    --title "Default conflict resolver"
    --no-collapse
    --clear
    --menu "Current: ${RETROSYNC[defaultMergeStrategy]}" "${height}" "${width}" 4)

  resolution="$("${chooseResolution[@]}" "${resolutionOpts[@]}" 2>&1 >/dev/tty1)" || true
  case "${resolution}" in
    manual|most-recent|keep-left|keep-right)
    config::set defaultMergeStrategy "${resolution}"
    ;;
    *)  ;;
  esac
}

gui::config::retroarch() {
  # Generate all the conflicts by id and file
  local retroarchLocations=()
  for location in $(retroarch::possible_locations); do
    retroarchLocations+=("${location}" "")
  done

  local selectConflict=(dialog
    --backtitle "${BACKTITLE}"
    --no-collapse
    --clear
    --title "Conflicting files"
    --ok-label "Solve"
    --cancel-label "Back"
    --menu "Select:" "${height}" "${width}" 15)

  selectedRetroarchLoc=$("${selectConflict[@]}" "${retroarchLocations[@]}" 2>&1 >/dev/tty1)
  gui::config::retroarch::setup "${selectedRetroarchLoc}"
}

gui::config::retroarch::setup() {
  local file="${1}"
  message="Location: ${file}\n\nBackup and update retroarch.cfg to put saves next to the content?"
  if dialog --backtitle "${BACKTITLE}" --title "Organize saves" --yesno "${message}" "${height}" "${width}"; then
    retroarch::setup "${file}" |
      dialog --backtitle "${BACKTITLE}" --title "Updating retroarch.cfg..." --progressbox "${height}" "${width}" >/dev/tty1
      sleep 4
  fi
}

Configure() {
  local configureOpts=(1 "Set default conflict resolver..." 2 "Setup retroarch..." 3 "Back")
  local configureMenu=(dialog
    --backtitle "${BACKTITLE}"
    --title "Configure"
    --no-collapse
    --clear
    --nocancel
    --nook
    --menu "Please make your selection" "${height}" "${width}" 15)

  while true; do
    configureOpt="$("${configureMenu[@]}" "${configureOpts[@]}" 2>&1 >/dev/tty1)"
    case "${configureOpt}" in
      1) gui::config::defaultConflictResolution ;;
      2) gui::config::retroarch ;;
      3) break ;;
    esac
  done
}
