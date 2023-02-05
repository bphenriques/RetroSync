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

while read -r id from to filter conflict_strategy; do
  ${SCRIPT_PATH}/SyncSaveGames/sync.sh "$id" "$from" "$to" "${SCRIPT_PATH}"/SyncSaveGames/filters/${filter} "${conflict_strategy:-most-recent}"
done <<< $(grep -E '^[a-zA-Z]' "${SCRIPT_PATH}"/SyncSaveGames/config/folders.txt)

echo ""
success "Finished sync!"
sleep 4
