#!/bin/bash

set -e

# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

readonly PROJECT_NAME=RetroSync
readonly REPO_NAME=RetroSync
readonly GITHUB_BASE="https://github.com/bphenriques/${REPO_NAME}"
readonly VERSION=development
readonly GITHUB_ZIP_URL="${GITHUB_BASE}/archive/refs/heads/${VERSION}.zip"

if [ ! -d "${INSTALL_DIR}" ]; then
  println "Error: the installation directory does not exit: %s\n" "${INSTALL_DIR}"
  exit 1
fi

#
# Binaries
#
build_dir="$(mktemp -d)"
mkdir -p "${INSTALL_DIR}"

if [ ! -d "${INSTALL_DIR}/${PROJECT_NAME}" ]; then
  printf "Installing .. (src=%s build_dir=%s install_dir=%s)\n" "${GITHUB_ZIP_URL}" "${build_dir}" "${INSTALL_DIR}"
  wget --tries 3 --timeout 60 --quiet --show-progress "${GITHUB_ZIP_URL}" -O "${build_dir}/retrosync.zip"
  unzip -o "${build_dir}/retrosync.zip" -d "${build_dir}"
  cp -r "${build_dir}/${REPO_NAME}-${VERSION}/src" "${INSTALL_DIR}/${PROJECT_NAME}"
else
  printf "Already installed! Aborting"
  exit 1
fi

source "${INSTALL_DIR}/${PROJECT_NAME}"/lib/config.sh

# Create user config directory if missing
[[ ! -d "${RETROSYNC[userCfgDir]}" ]] && mkdir -p "${RETROSYNC[userCfgDir]}"

cp -r "${build_dir}/${REPO_NAME}-${VERSION}/device/arkos/locations.txt" "${RETROSYNC[userCfgDir]}"
cp -r "${build_dir}/${REPO_NAME}-${VERSION}/device/arkos/RetroSync-SyncAll.sh" "${INSTALL_DIR}"

#
# Rclone
#
if command -v rclone >/dev/null; then
  println 'rclone binary already present!\n'
else
  case "$(uname -m)" in
    aarch64 | arm64)  RCLONE_URL="https://downloads.rclone.org/v1.61.1/rclone-v1.61.1-linux-arm.zip"    ;;
    x86_64)           RCLONE_URL="https://downloads.rclone.org/v1.61.1/rclone-v1.61.1-linux-amd64.zip"  ;;
    *)
      printf "Incompatible architecture"
      exit 1
      ;;
  esac

  if [ ! -f "${RETROSYNC[rcloneBin]}" ]; then
    printf "rclone is not installed! Downloading and installing...\n"
    wget --tries 3 --timeout 60 --quiet --show-progress "${RCLONE_URL}" -O "${build_dir}/rclone.zip"
    unzip -o "${build_dir}/rclone.zip" -d "${build_dir}"

    mkdir -p "$(dirname "${RETROSYNC[rcloneBin]}")"
    mv "${build_dir}/$(basename "${RCLONE_URL}" .zip)/rclone" "${RETROSYNC[rcloneBin]}"
    printf "rclone is now available: %s\n" "${RETROSYNC[rcloneBin]}"
  else
    printf "rclone is already installed: %s\n" "${RETROSYNC[rcloneBin]}"
  fi
fi

if [ -f "${retroarch_config}" != 0 ]; then
  println "Updating retroarch to organize save games .."
  sed -i 's/^savefiles_in_content_dir.*$/savefiles_in_content_dir = \"true\"/g' $retroarch_config
  sed -i 's/^savestates_in_content_dir.*$/savestates_in_content_dir = \"true\"/g' $retroarch_config
fi

rm "${build_dir}"

printf "\n"
printf "Installation complete!\n"
