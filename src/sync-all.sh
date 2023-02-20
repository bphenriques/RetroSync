#!/usr/bin/env bash

# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/lib/config.sh
source "${SCRIPT_PATH}"/lib/util.sh

available_ids=( $(config::location_ids) )
total="${#available_ids[@]}"
if [ "${total}" -gt 0 ]; then
  current=1
  for id in "${available_ids[@]}"; do
    printf "Syncing %s (%d out of %d)\n" "${id}" "${current}" "${total}"
    "${SCRIPT_PATH}"/sync.sh "${id}"
    printf "\n"
    (( current++ )) || true
  done
  printf "\n"
  printf "Sync complete!\n"
else
  printf "No locations to sync. Have you checked %s?" "${RETROSYNC[syncLocations]}"
fi
