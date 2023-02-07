#!/bin/bash
set -efx
SCRIPT_PATH="$(dirname "$0")"
source "${SCRIPT_PATH}"/SyncSaveGames/util.sh

test_dir="$(mktemp -d /tmp/test.XXX)"
printf "Running tests on ${test_dir}\n"

####################
# TEST 1 - Most Recent
####################
echo "File Conflict - Testing most-recent"
oldest="${test_dir}/file-most-recent.extension..path1"
recent="${test_dir}/file-most-recent.extension..path2"
echo "Oldest" >> "${oldest}"
echo "Recent" >> "${recent}"
date_oldest="$(date -r ${oldest} '+%Y-%m-%d_%H-%M-%S')"

${SCRIPT_PATH}/SyncSaveGames/solve-conflicts.sh "${oldest}" "most-recent"
test -f "${test_dir}/file-most-recent.extension"
test -f "${test_dir}/file-most-recent.extension.backup.${date_oldest}"
grep -q "Oldest" "${test_dir}/file-most-recent.extension.backup.${date_oldest}"
grep -q "Recent" "${test_dir}/file-most-recent.extension"

####################
# TEST 2 - Manual
####################

echo "File Conflict - Testing manual"
path1="${test_dir}/file-manual.extension..path1"
path2="${test_dir}/file-manual.extension..path2"
echo "path1" >> "${path1}"
echo "path2" >> "${path2}"

${SCRIPT_PATH}/SyncSaveGames/solve-conflicts.sh "${path1}" "manual"
test -f "${path1}"
test -f "${path2}"
grep -q "path1" "${path1}"
grep -q "path2" "${path2}"

####################
# TEST 3 - Keep Left
####################

echo "File Conflict - Testing keep-left"
left="${test_dir}/file-keep-left.extension..path1"
right="${test_dir}/file-keep-left.extension..path2"
echo "left" >> "${left}"
echo "right" >> "${right}"
backup_date="$(date -r ${right} '+%Y-%m-%d_%H-%M-%S')"

${SCRIPT_PATH}/SyncSaveGames/solve-conflicts.sh "${left}" "keep-left"
test -f "${test_dir}/file-keep-left.extension"
test -f "${test_dir}/file-keep-left.extension.backup.${backup_date}"
grep -q "right" "${test_dir}/file-keep-left.extension.backup.${backup_date}"
grep -q "left" "${test_dir}/file-keep-left.extension"

####################
# TEST 4 - Keep Right
####################

echo "File Conflict - Testing keep-right"
left="${test_dir}/file-keep-right.extension..path1"
right="${test_dir}/file-keep-right.extension..path2"
echo "left" >> "${left}"
echo "right" >> "${right}"
backup_date="$(date -r ${left} '+%Y-%m-%d_%H-%M-%S')"

${SCRIPT_PATH}/SyncSaveGames/solve-conflicts.sh "${left}" "keep-right"
test -f "${test_dir}/file-keep-right.extension"
test -f "${test_dir}/file-keep-right.extension.backup.${backup_date}"
grep -q "left" "${test_dir}/file-keep-right.extension.backup.${backup_date}"
grep -q "right" "${test_dir}/file-keep-right.extension"

printf "Tests successful!\n"
rm -r ${test_dir}

# TODO: Test for directories


