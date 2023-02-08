#!/usr/bin/env bash
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/../../src/lib/config.sh

test_file=$(mktemp)

cat <<EOF > "${test_file}"
key=value
key2=some other value with spaces
EOF

config::reload "${test_file}"
[[ $? = 0 ]] || exit $?

[[ "${RETROSYNC[key]}" == "value" ]] || printf "Wrong value in key" && exit 1
[[ "${RETROSYNC[key2]}" == "some other value with spaces" ]] || printf "Wrong value in key2" && exit 1

cat <<EOF > "${test_file}"
other=random
EOF

config::reload "${test_file}"
[[ "${RETROSYNC[key]}" == "" ]] || printf "key was not deleted after reloading" && exit 1
[[ "${RETROSYNC[other]}" == "random" ]] || printf "Wrong value in other" && exit 1

rm "${test_file}"
