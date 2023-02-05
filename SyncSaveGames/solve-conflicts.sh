#!/bin/bash
set -ef
SCRIPT_PATH="$(dirname "$0")"

# shellcheck source=util.sh
source "${SCRIPT_PATH}"/util.sh

function backup_and_restore() {
  local file_to_backup="$1"
  local file_to_keep="$2"
  local target_file="$3"

  local timestamp
  timestamp="$(date -r "${file_to_backup}" '+%Y-%m-%d_%H-%M-%S')"
  local backup="${target_file}.backup.${timestamp}"

  info "Backing up ${file_to_backup} to ${backup} .."
  mv "${file_to_backup}" "${backup}"
  info "Moving up ${file_to_keep} to ${target_file} .."
  mv "${file_to_keep}" "${target_file}"
}

if [ "$#" -ne 2 ]; then
  error "Illegal number of parameters: ./solve-conflicts.sh <file_path1> [manual|most-recent|keep-right|keep-left]"
  exit 1
fi

file_path1="$1"
strategy="$2"

file_path2="$(echo -n "$file_path1" | sed 's/\.\.path1/\.\.path2/g')"
final_file="$(echo -n "$file_path1" | sed 's/\.\.path1//g')"

if [ ! -f "${file_path2}" ]; then
  warn "Can't find counter-part of ${file_path1} - ${file_path2} not found!"
  exit 2
fi

info "Found conflict with ${final_file}!"
case ${strategy} in
  manual)
    warn "Manually solve conflict"
    ;;
  most-recent)
    info "Keeping the most recent file .."
    date_path1="$(date -r "${file_path1}" '+%Y-%m-%d %H:%M:%S')"
    date_path2="$(date -r "${file_path2}" '+%Y-%m-%d %H:%M:%S')"
    printf '\n%s: %s' "${file_path1}" "${date_path1}"
    printf '\n%s: %s' "${file_path2}" "${date_path2}"

    if [ "${file_path1}" -nt "${file_path2}" ]; then
      info "Keeping ${file_path1} .."
      backup_and_restore "${file_path2}" "${file_path1}" "${final_file}"
    else
      info "Keeping ${file_path2} .."
      backup_and_restore "${file_path1}" "${file_path2}" "${final_file}"
    fi
    ;;
  keep-left)
    backup_and_restore "${file_path2}" "${file_path1}" "${final_file}"
    ;;
  keep-right)
    backup_and_restore "${file_path1}" "${file_path2}" "${final_file}"
    ;;
  *)
    error "Unrecognized conflict resolution strategy ${strategy}!"
    ;;
esac
