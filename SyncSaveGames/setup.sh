#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

CONFIG_DIR=${SCRIPT_PATH}/config
source "${CONFIG_DIR}"/config.env
source "${SCRIPT_PATH}"/util.sh

MARKERS_DIR=${SCRIPT_PATH}/.markers

if [ ! -f "$RCLONE_BIN" ]; then
  info "rclone is not installed! Downloading and installing..."
  install_dir=${SCRIPT_PATH}/install
  mkdir -p "$install_dir"
  wget --tries 3 --timeout 60 --quiet --show-progress "$RCLONE_URL" -O "$install_dir/rclone.zip"
  unzip -o "$install_dir/rclone.zip" -d "$install_dir"
  mv "$install_dir"/$(basename $RCLONE_URL .zip)/rclone "$RCLONE_BIN"
  rm -rf "$install_dir"
  success "rclone is now installed!"
else
  success "rclone is already installed!"
fi

mkdir -p ${MARKERS_DIR}
