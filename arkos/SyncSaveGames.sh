#!/bin/bash
set -euf
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/SyncSaveGames/util.sh

GW=`ip route | awk '/default/ { print $3 }'`
if [ -z "$GW" ]; then
  warn "Your network connection doesn't seem to be working."
  sleep 5
  return
fi

total="$(grep -E '^[a-zA-Z]' "${SCRIPT_PATH}"/SyncSaveGames/config/folders.txt | wc -l)"
current=1
while read -r id from to filter conflict_strategy; do
  info "Syncing %s (%d out of %d)" "$id" "${current}" "${total}"
  ${SCRIPT_PATH}/SyncSaveGames/sync.sh "$id" "$from" "$to" "${SCRIPT_PATH}"/SyncSaveGames/filters/${filter} "${conflict_strategy:-most-recent}"
  (( current++ )) || true
  printf "\n"
done <<< "$(grep -E '^[a-zA-Z]' "${SCRIPT_PATH}"/SyncSaveGames/config/folders.txt)"

printf "\n"
success "Sync complete!"
sleep 4
