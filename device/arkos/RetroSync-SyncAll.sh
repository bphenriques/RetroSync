#!/bin/bash

# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/RetroSync/lib/util.sh

if [ -z "$(ip route | awk '/default/ { print $3 }')" ]; then
  warn "Your network connection doesn't seem to be working."
  sleep 5
  return
fi

"${SCRIPT_PATH}"/RetroSync/sync-all.sh
sleep 4
