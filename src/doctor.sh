#!/usr/bin/env bash
SCRIPT_PATH="$(dirname "$0")"

# shellcheck disable=SC1091
source "${SCRIPT_PATH}"/lib/config.sh

any_failure=0

case "$BASH_VERSION" in
  4* | 5*) ;;
  *)
    any_failure=1
    printf '[FAIL] Bash must be at least version 4!\n'
    ;;
esac

if ! command -v jq > /dev/null; then
  printf '[FAIL] jq binary is not installed!\n'
  exit 1
fi

if ! command -v rclone > /dev/null; then
  printf '[FAIL] rclone binary is not installed!\n'
  exit 1
fi

if ! command -v dialog >/dev/null; then
  printf '[WARN] dialog binary not available which is required for the GUI interface!\n'
fi

if [ ! -f "${RETROSYNC[userCfg]}" ]; then
  any_failure=1
  printf "[FAIL] configuration file missing: %s\n" "${RETROSYNC[userCfg]}"
fi

if [ ! -d "${RETROSYNC[syncLocations]}" ]; then
  any_failure=1
  printf "[FAIL] sync directories directory is missing: %s\n" "${RETROSYNC[syncLocations]}"
fi

# TODO: Check each remote... "check if the remote mentioned before the ':' exists"

available_ids=( $(config::location_ids) )
total="${#available_ids[@]}"
if [ "${total}" -gt 0 ]; then
  for id in "${available_ids[@]}"; do
    while IFS=$'\t' read -r id from to filter on_conflict; do
      if [ ! -d "${from}" ]; then
        any_failure=1
        printf "[FAIL] %s: path1 directory missing: ${from}\n" "${id}" "${from}"
      fi

      if [ ! -f "${RETROSYNC[rcloneFilterDir]}/${filter}" ]; then
        any_failure=1
        printf "[FAIL] %s: filter missing: %s\n" "${id}" "${RETROSYNC[rcloneFilterDir]}/${filter}"
      fi

      case "${on_conflict}" in
        manual|most-recent|keep-left|keep-right|"")       ;;
        *)
          any_failure=1
          printf "[FAIL] %s: unrecognized conflict strategy: %s\n" "${id}" "${on_conflict}"
          ;;
      esac
    done <<< "$(config::location_config "${id}")"
  done
else
  printf "[WARN] No locations present at %s\n" "${RETROSYNC[syncLocations]}"
fi

if [[ "${any_failure}" == 0 ]]; then
  printf "[OK] Everything is ok!\n"
fi
