#!/bin/bash
SCRIPT_PATH="$(dirname "$0")"

if [ -f "${SCRIPT_PATH}"/config/folders.txt ]; then
  printf "[OK] configuration file exists\n" "${id}"
else
  printf "[FAIL] configuration file missing: %s\n" "${id}" "${SCRIPT_PATH}"/config/folders.txt
fi

while read -r id from to filter conflict_strategy; do
  if [ -d "${from}" ]; then
    printf "[OK] %s: path1 directory\n" "${id}"
  else
    printf "[FAIL] %s: path1 directory missing: ${from}\n" "${id}" "${from}"
  fi

  if [ -f "${SCRIPT_PATH}/filters/${filter}" ]; then
    printf "[OK] %s: filter\n" "${id}"
  else
    printf "[FAIL] %s: filter missing: %s\n" "${id}" "${filter}"
  fi

  case "${conflict_strategy}" in
    manual)       printf "[OK] %s: conflict strategy\n" "${id}" ;;
    most-recent)  printf "[OK] %s: conflict strategy\n" "${id}" ;;
    keep-left)    printf "[OK] %s: conflict strategy\n" "${id}" ;;
    keep-right)   printf "[OK] %s: conflict strategy\n" "${id}" ;;
    "")           printf "[OK] %s: conflict strategy. Using default.\n" "${id}" ;;
    *)            printf "[FAIL] %s: unrecognized conflict strategy: %s\n" "${id}" "${conflict_strategy}";;
  esac
done <<< "$(grep -E '^[a-zA-Z]' "${SCRIPT_PATH}"/config/folders.txt)"

# Check retroarch settings..
# echo "   Setting 'savefiles_in_content_dir' 'savestates_in_content_dir' to true .. (${build_dir} to ${host}:${remote_dest})"
# "sed -i 's/^savefiles_in_content_dir.*$/savefiles_in_content_dir = \"true\"/g' $retroarch_config"
# "sed -i 's/^savestates_in_content_dir.*$/savestates_in_content_dir = \"true\"/g' $retroarch_config"
