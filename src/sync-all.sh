#!/usr/bin/env bash

# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/lib/config.sh
source "${SCRIPT_PATH}"/lib/util.sh

total="$(grep -cE '^[a-zA-Z]' "${RETROSYNC[locationsCfg]}")"
if [ "${total}" -gt 0 ]; then
  current=1
  while read -r id from to filter conflict_strategy; do
    printf "Syncing %s (%d out of %d)\n" "$id" "${current}" "${total}"
    "${SCRIPT_PATH}"/sync.sh "$id" "${from}" "${to}" "${filter}" "${conflict_strategy:-"${RETROSYNC[defaultMergeStrategy]}"}"
    (( current++ )) || true
    printf "\n"
  done <<< "$(config::locations)"
  printf "\n"
  printf "Sync complete!\n"
else
  printf "No locations to sync. Have you checked %s?" "${RETROSYNC[locationsCfg]}"
fi




