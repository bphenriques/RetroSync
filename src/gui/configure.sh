#!/usr/bin/env bash

if [ -n "$__RETRO_GUI_CONFIGURE_SOURCED" ]; then return; fi
__RETRO_GUI_CONFIGURE_SOURCED=1

SetupDefaultConflictResolution() {
  local resolutionOpts=("manual" "Do nothing" "most-recent" "Keep most recent file" "keep-left" "Keep local file" "keep-right" "Keep remote file")
  local chooseResolution=(dialog
    --backtitle "${BACKTITLE}"
    --title "Default conflict resolver"
    --no-collapse
    --clear
    --menu "Current: ${RETROSYNC[defaultMergeStrategy]}" "${height}" "${width}" 4)

  resolution="$("${chooseResolution[@]}" "${resolutionOpts[@]}" 2>&1 >/dev/tty1)" || true
  config::set defaultMergeStrategy "${resolution}"
}

Configure() {
  local configureOpts=(1 "Set default conflict resolver" 2 "Enable/Disable..." 3 "Setup RetroArch..." 4 "Backup/Restore RetroSync" 5 "Back")
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
      1) SetupDefaultConflictResolution        ;;
      2) ;;
      3) ;;
      4) ;;
      5) break ;;
    esac
  done
  # What do I want to get out of this screen...
  # 1. Set default conflict resolution
  # 2. Enable/Disable...
  # 3. RetroArch - Setup
  # 4. Backup/Restore RetroSync settings:
      # 1st - N-1 entries: restore backup and sort by age
      # Last entry: create backup
      # Backup:
        # Zip from "${RETROSYNC[userCfgDir]}" to "${RETROSYNC[deviceId]}"
        # Copy to retrosync-backups
      # Restore
        # Prompt to select one, which will overwrite the existing one
        # Copy and overwrite all settings
}
