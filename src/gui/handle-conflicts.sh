#!/usr/bin/env bash

if [ -n "$__RETRO_GUI_HANDLE_CONFLICTS_SOURCED" ]; then return; fi
__RETRO_GUI_HANDLE_CONFLICTS_SOURCED=1

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
      dialog --backtitle "${BACKTITLE}" --infobox "ERROR: Unknown resolution $resolution" 4 "${width}" >/dev/tty1
      sleep 3
      ;;
  esac
}
