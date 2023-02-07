#!/bin/bash
SCRIPT_PATH="$(dirname "$0")"

# shellcheck disable=SC1091
source "${SCRIPT_PATH}"/lib/rclone.sh

rclone::install

# echo "   Setting 'savefiles_in_content_dir' 'savestates_in_content_dir' to true .. (${build_dir} to ${host}:${remote_dest})"
# "sed -i 's/^savefiles_in_content_dir.*$/savefiles_in_content_dir = \"true\"/g' $retroarch_config"
# "sed -i 's/^savestates_in_content_dir.*$/savestates_in_content_dir = \"true\"/g' $retroarch_config"
