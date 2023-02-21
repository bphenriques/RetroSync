#!/usr/bin/env bash

source /opt/system/Tools/RetroSync/lib/config.sh
source /opt/system/Tools/RetroSync/lib/rclone.sh

if command -v jq > /dev/null; then
  echo "jq is already installed!"
else
  sudo apt-get install jq
fi

if command -v dialog > /dev/null; then
  echo "dialog is already installed!"
else
  sudo apt-get install dialog
fi

if command -v rclone > /dev/null; then
  echo "rclone is already installed!"
else
  sudo apt-get install rclone
fi

rclone::install "/home/ark/.bin/rclone"
config::set rcloneBin "/home/ark/.bin/rclone"
