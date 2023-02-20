#!/bin/bash

set -e

echo "Sorry, not supported, so not advisable yet."
exit 0

readonly PROJECT_NAME=RetroSync
readonly REPO_NAME=RetroSync
readonly GITHUB_BASE="https://github.com/bphenriques/${REPO_NAME}"
readonly VERSION=development
readonly GITHUB_ZIP_URL="${GITHUB_BASE}/archive/refs/heads/${VERSION}.zip"

build_dir="$(mktemp -d)"

if [ ! -d "${INSTALL_DIR}" ]; then
  println "Error: the installation directory does not exit: %s\n" "${INSTALL_DIR}"
  exit 1
fi

if [ ! -d "${INSTALL_DIR}/${PROJECT_NAME}" ]; then
  printf "Installing .. (src=%s build_dir=%s install_dir=%s)\n" "${GITHUB_ZIP_URL}" "${build_dir}" "${INSTALL_DIR}"
  wget --tries 3 --timeout 60 --quiet --show-progress "${GITHUB_ZIP_URL}" -O "${build_dir}/retrosync.zip"
  unzip -o "${build_dir}/retrosync.zip" -d "${build_dir}"
  cp -r "${build_dir}/${REPO_NAME}-${VERSION}/src" "${INSTALL_DIR}/${PROJECT_NAME}"
else
  # TODO: We may want to consider an update here...
  printf "Already installed! Aborting"
  exit 1
fi

"${INSTALL_DIR}"/RetroSync/setup.sh

rm "${build_dir}"

printf "\n"
printf "Installation complete!\n"
