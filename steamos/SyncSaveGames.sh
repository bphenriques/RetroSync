#!/bin/bash
set -euf
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/SyncSaveGames/util.sh

GW=`ip route | awk '/default/ { print $3 }'`
if [ -z "$GW" ]; then
  error "Your network connection doesn't seem to be working."
  sleep 5
  return
fi

${SCRIPT_PATH}/SyncSaveGames/sync.sh
echo ""
success "Finished sync!"
sleep 5
