#!/usr/bin/env bash

# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

sudo chmod 666 /dev/tty1
printf "\033c" >/dev/tty1

# hide cursor
printf "\e[?25l" >/dev/tty1
dialog --clear

height="15"
width="55"
if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RG503 | tr -d '\0')"; then
  height="20"
  width="60"
fi

export TERM=linux
export XDG_RUNTIME_DIR=/run/user/$UID/

printf "\033c" >/dev/tty1

#
# Joystick controls
#
# only one instance
CONTROLS="/opt/wifi/oga_controls"
sudo $CONTROLS test-ui.sh rg552 &

if ! "${SCRIPT_PATH}"/RetroSync/gui.sh "${height}" "${width}" /dev/tty1; then
  printf "Failed to run the GUI!"
fi

printf "\033c" >/dev/tty1

# Ensure we release the input regardless of the outcome
pgrep -f oga_controls | sudo xargs kill -9
