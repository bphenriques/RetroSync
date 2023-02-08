#!/usr/bin/env bash

# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/lib/util.sh

total="$(grep -cE '^[a-zA-Z]' "${SCRIPT_PATH}"/config/folders.txt)"
current=1
while read -r id from to filter conflict_strategy; do
  printf "Syncing %s (%d out of %d)\n" "$id" "${current}" "${total}"
  "${SCRIPT_PATH}"/sync.sh "$id" "${from}" "${to}" "${filter}" "${conflict_strategy:-RETROSYNC[defaultMergeStrategy]t}"
  (( current++ )) || true
  printf "\n"
done <<< "$(grep -E '^[a-zA-Z]' "${SCRIPT_PATH}"/config/folders.txt)"

printf "\n"
printf "Sync complete!\n"
