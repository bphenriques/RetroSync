#!/usr/bin/env bash

if ! command -v jq > /dev/null || ! command -v rclone > /dev/null || ! command -v dialog > /dev/null; then
  if command -v jq > /dev/null; then
    echo "jq is already installed!"
  else
    pacman -S jq
  fi

  if command -v rclone > /dev/null; then
    echo "rclone is already installed!"
  else
    pacman -S rclone
  fi

  if command -v dialog > /dev/null; then
    echo "dialog is already installed!"
  else
    pacman -S dialog
  fi
fi

rm -f "${HOME}"/Desktop/RetroSync.desktop
tee -a "${HOME}"/Desktop/RetroSync.desktop > /dev/null << END
#!/usr/bin/env xdg-open
[Desktop Entry]
Name=RetroSync
Comment=RetroSync
Exec=LD_PRELOAD=${LD_PRELOAD/_32/_64} QT_SCALE_FACTOR=1.25 bash -c '/home/deck/.bin/RetroSync-GUI.sh;$SHELL' %command% --fullscreen --notransparency --new-tab --hide-menubar --qwindowgeometry 1024x640
Icon=utilities-terminal
Terminal=true
Type=Application
Categories=Application;System;
END
