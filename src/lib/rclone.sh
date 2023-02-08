#!/usr/bin/env bash

if [ -n "$__RETRO_SYNC_RCLONE_SOURCED" ]; then return; fi
__RETRO_SYNC_RCLONE_SOURCED=1

rclone::install() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    aarch64)  RCLONE_URL="https://downloads.rclone.org/v1.61.1/rclone-v1.61.1-linux-arm.zip"    ;;
    x86_64)   RCLONE_URL="https://downloads.rclone.org/v1.61.1/rclone-v1.61.1-linux-amd64.zip"  ;;
    *)
      printf "Failure: unsupported %s architecture" "${arch}"
      return 1
      ;;
  esac

  if [ ! -f "${RETROSYNC[rcloneBin]}" ]; then
    printf "rclone is not installed! Downloading and installing...\n"
    local install_dir
    install_dir=$(mktemp -d)
    mkdir -p "${install_dir}"
    wget --tries 3 --timeout 60 --quiet --show-progress "$RCLONE_URL" -O "${install_dir}/rclone.zip"
    unzip -o "${install_dir}/rclone.zip" -d "${install_dir}"

    mkdir -p "$(dirname "${RETROSYNC[rcloneBin]}")"
    mv "${install_dir}/$(basename "$RCLONE_URL" .zip)/rclone" "${RETROSYNC[rcloneBin]}"
    rm -rf "${install_dir}"
    printf "rclone is now available at %s!\n" "${RETROSYNC[rcloneBin]}"
  else
    printf "rclone is already installed at %s!\n" "${RETROSYNC[rcloneBin]}"
  fi

  return 0
}

rclone::bisync() {
  local from="$1"
  local to="$2"
  local filter_file="$3"
  local resync="$4"

  declare -a flags
  flags=(--max-delete "${RETROSYNC[maxDeleteProtectionPercent]}" --verbose --log-file "${RETROSYNC[logFile]}")
  if [[ "${resync}" != 0 ]]; then
    flags+=("--resync")
  fi
  if [[ "${RETROSYNC[debug]}" != 0 ]]; then
    flags+=("--verbose")
  fi

  "${RETROSYNC[rcloneBin]}" bisync "${from}" "${to}" --filter-from "${filter_file}" "${flags[@]}"
}

rclone::mkdir() {
  local dir="$1"
  "${RETROSYNC[rcloneBin]}" mkdir "${dir}" --log-file "${RETROSYNC[logFile]}"
}
