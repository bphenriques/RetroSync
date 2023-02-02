#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

SSH_PORT=22

function build() {
  local target_dir="$1"
  local os="$2"

  echo "Building .. (os=${os} build_dir=$build_dir)"
  cp -r "${SCRIPT_PATH}/SyncSaveGames" "${target_dir}"
  cp -r "${SCRIPT_PATH}/${os}/SyncSaveGames.sh" "${target_dir}"/SyncSaveGames.sh
  cp -r "${SCRIPT_PATH}/${os}/config.env" "${target_dir}"/SyncSaveGames/config/config.env
}

function deploy() {
  local build_dir="$1"
  local host="$2"
  local remote_dest="$3"

  echo "Deploying .. (build_dir=${build_dir} host=${host} remote_dest=${remote_dest})"
  echo ""
  echo "   Deleting previous installation .."
  ssh "${host}" "if [ -f ${remote_dest}/SyncSaveGames.sh ]; then rm ${remote_dest}/SyncSaveGames.sh && rm -r ${remote_dest}/SyncSaveGames; fi"
  echo ""
  echo "   Copying installation .. (${build_dir} to ${host}:${remote_dest})"

   # Glob doesnt work and I do not follow why... so.. two copies.
  scp -P ${SSH_PORT} -r -p ${build_dir}/SyncSaveGames "${host}":${remote_dest}
  scp -P ${SSH_PORT} -p ${build_dir}/SyncSaveGames.sh "${host}":${remote_dest}
}

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters: ./install.sh [arkos|steamdeck] <host> <remote_dest>"
    return
fi


os="$1"
host="$2"
remote_dest="$3"

build_dir="$(mktemp -d /tmp/syncer.XXX)"

build "${build_dir}" "${os}"
deploy "${build_dir}" "${host}" "${remote_dest}"

echo "Cleaning up .."
rm -rf {build_d}
