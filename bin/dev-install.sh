#!/bin/bash

set -e

# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

if [ "$#" -ne 3 ]; then
  fail "Illegal number of parameters: ./dev-install <host> <os> <install_dir>"
fi

HOST="$1"
OS="$2"
INSTALL_DIR="$3"

if [[ ! -d "${SCRIPT_PATH}/../device/${OS}" ]]; then
  printf "The OS directory does not exist: %s" "${OS}"
  exit 1
fi

if ! ssh "$HOST" "test -d  ${INSTALL_DIR}"; then
  printf "The installation directory does not exist: %s" "${INSTALL_DIR}"
  exit 1
fi

echo "Performing remote installation.."
echo "   Deleting existing installation .."
ssh "${HOST}" "rm -r ${INSTALL_DIR}/RetroSync*"

echo "   Copying current version .."
scp -r "${SCRIPT_PATH}/../src" "${HOST}:${INSTALL_DIR}"/RetroSync

printf "   Copying custom %s files .." "${OS}"
find "./device/${OS}/" -type f -maxdepth 1 -name "*.sh" -print0 | xargs -0 -I{} scp "{}" "${HOST}:${INSTALL_DIR}"

echo "Remotely executing setup.."
ssh "${HOST}" "${INSTALL_DIR}/RetroSync/setup.sh"

echo "Done!"
