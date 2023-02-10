#!/usr/bin/env bash
SCRIPT_PATH="$(dirname "$0")"

# shellcheck disable=SC1091
source "${SCRIPT_PATH}"/lib/config.sh

any_failure=0

# TODO: Check Bash greater than 4

if command -v dialog >/dev/null; then
  printf '[OK] dialog is present for the GUI app\n'
else
  printf '[WARN] dialog binary not available which is required for the GUI interface!\n'
fi

if [ -f "${RETROSYNC[userCfg]}" ]; then
  printf "[OK] configuration file exists: %s\n" "${RETROSYNC[userCfg]}"
else
  any_failure=1
  printf "[FAIL] configuration file missing: %s\n" "${RETROSYNC[userCfg]}"
fi

if [ -f "${RETROSYNC[locationsCfg]}" ]; then
  printf "[OK] locations file exists: %s\n" "${RETROSYNC[locationsCfg]}"
else
  any_failure=1
  printf "[FAIL] locations file missing: %s\n" "${RETROSYNC[userCfg]}"
fi

# TODO: Check list remotes if the locations.txt is not empty

if [[ -f "${RETROSYNC[rcloneBin]}" ]]; then
  printf "[OK] rclone is installed: %s\n" "${RETROSYNC[rcloneBin]}"
else
  any_failure=1
  printf "[FAIL] rclone is not installed: %s\n" "${RETROSYNC[rcloneBin]}"
fi

# TODO: Check if there are not duplicate ids in the locations.txt file
# TODO: Check if the remote is valid for each config

while read -r id from to filter conflict_strategy; do
  location_fail=0

  if [ ! -d "${from}" ]; then
    location_fail=1
    any_failure=1
    printf "[FAIL] %s: path1 directory missing: ${from}\n" "${id}" "${from}"
  fi

  if [ ! -f "${RETROSYNC[rcloneFilterDir]}/${filter}" ]; then
    location_fail=1
    any_failure=1
    printf "[FAIL] %s: filter missing: %s\n" "${id}" "${filter}"
  fi

  case "${conflict_strategy}" in
    manual|most-recent|keep-left|keep-right|"")       ;;
    *)
      location_fail=1
      any_failure=1
      printf "[FAIL] %s: unrecognized conflict strategy: %s\n" "${id}" "${conflict_strategy}"
      ;;
  esac

  if [[ "${location_fail}" == 0 ]]; then
    printf "[OK] %s\n" "${id}"
  fi
done <<< "$(config::locations)"

if [[ "${any_failure}" == 0 ]]; then
  printf "\n"
  printf "[OK] Everything is ok!"
fi

# Check retroarch settings..
# echo "   Setting 'savefiles_in_content_dir' 'savestates_in_content_dir' to true .. (${build_dir} to ${host}:${remote_dest})"
# "sed -i 's/^savefiles_in_content_dir.*$/savefiles_in_content_dir = \"true\"/g' $retroarch_config"
# "sed -i 's/^savestates_in_content_dir.*$/savestates_in_content_dir = \"true\"/g' $retroarch_config"
