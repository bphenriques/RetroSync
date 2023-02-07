#!/bin/bash

# shellcheck source=util.sh
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/SyncSaveGames/util.sh

if [ -z "$(ip route | awk '/default/ { print $3 }')" ]; then
  warn "Your network connection doesn't seem to be working."
  sleep 5
  return
fi

total="$(grep -cE '^[a-zA-Z]' "${SCRIPT_PATH}"/SyncSaveGames/config/folders.txt)"
current=1
while read -r id from to filter conflict_strategy; do
  printf "Syncing %s (%d out of %d)\n" "$id" "${current}" "${total}"
  "${SCRIPT_PATH}"/SyncSaveGames/sync.sh "$id" "$from" "$to" "${SCRIPT_PATH}/SyncSaveGames/filters/${filter}" "${conflict_strategy:-most-recent}"
  (( current++ )) || true
  printf "\n"
done <<< "$(grep -E '^[a-zA-Z]' "${SCRIPT_PATH}"/SyncSaveGames/config/folders.txt)"

printf "\n"
printf "Sync complete!\n"
sleep 4
