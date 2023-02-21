#!/usr/bin/env bash

# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

"${SCRIPT_PATH}"/RetroSync/gui.sh "50" "200" /dev/tty
