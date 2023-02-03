#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

CONFIG_DIR=${SCRIPT_PATH}/config
source "${SCRIPT_PATH}"/util.sh

arch="$(uname -m)"
case "$arch" in
  aarch64)
    RCLONE_URL="https://downloads.rclone.org/v1.61.1/rclone-v1.61.1-linux-arm.zip"
    ;;
  x86_64)
    RCLONE_URL="https://downloads.rclone.org/v1.61.1/rclone-v1.61.1-linux-amd64.zip"
    ;;
  *)
    fail "Unsupported $arch architecture"
    ;;
esac

if [ ! -f "$RCLONE_BIN" ]; then
  info "rclone is not installed! Downloading and installing..."
  install_dir=$(mktemp -d)
  mkdir -p "$install_dir"
  wget --tries 3 --timeout 60 --quiet --show-progress "$RCLONE_URL" -O "$install_dir/rclone.zip"
  unzip -o "$install_dir/rclone.zip" -d "$install_dir"

  mkdir -p $(dirname $RCLONE_BIN)
  mv "$install_dir"/$(basename $RCLONE_URL .zip)/rclone "$RCLONE_BIN"
  rm -rf "$install_dir"
  success "rclone is now available at $RCLONE_BIN!"
else
  success "rclone is already installed!"
fi
