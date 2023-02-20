#!/usr/bin/env bash
# shellcheck disable=SC1091
SCRIPT_PATH="$(dirname "$0")"

source "${SCRIPT_PATH}"/lib/util.sh
source "${SCRIPT_PATH}"/lib/merge_strategies.sh

if [ "$#" -ne 2 ]; then
  error "Illegal number of parameters: ./fix-conflicts.sh <file_path1> [manual|most-recent|keep-right|keep-left]"
  exit 1
fi

file_path1="$1"
strategy="$2"

file_path2="$(echo -n "$file_path1" | sed 's/\.\.path1/\.\.path2/g')"
if [ ! -f "${file_path2}" ]; then
  warn "Can't find '..path2' counter-part of ${file_path1}!"
  exit 2
fi

final_file="$(echo -n "$file_path1" | sed 's/\.\.path1//g')"
printf "Found conflict with %s!\n" "${final_file}"
case ${strategy} in
  manual)       debug "Manually solve conflict" ;;
  most-recent)  merge::most_recent "${file_path1}" "${file_path2}" "${final_file}"  ;;
  keep-left)    merge::keep_left "${file_path1}" "${file_path2}" "${final_file}"    ;;
  keep-right)   merge::keep_right "${file_path1}" "${file_path2}" "${final_file}"   ;;
  *)            error "Unrecognized conflict resolution strategy ${strategy}!"      ;;
esac
