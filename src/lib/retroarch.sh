#!/usr/bin/env bash

if [ -n "$__RETRO_SYNC_RETROARCH_SOURCED" ]; then return; fi
__RETRO_SYNC_RETROARCH_SOURCED=1

retroarch::possible_locations() {
  if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/retroarch/retroarch.cfg ]; then
    echo "${XDG_CONFIG_HOME:-$HOME/.config}"/retroarch/retroarch.cfg
  fi

  if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/retroarch32/retroarch.cfg ]; then
    echo "${XDG_CONFIG_HOME:-$HOME/.config}"/retroarch32/retroarch.cfg
  fi

  if [ -f "${HOME}"/.retroarch.cfg ]; then
    echo "${HOME}"/.retroarch.cfg
  fi

  if [ -f "${HOME}"/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg ]; then
    echo "${HOME}"/.var/app/org.libretro.RetroArch/config/retroarch/retroarch.cfg
  fi
}

retroarch::backup() {
  local target_file="$1"

  local timestamp
  timestamp="$(date -r "${target_file}" '+%Y-%m-%d_%H-%M-%S')"
  local backup="${target_file}.before_retro_sync.${timestamp}"

  printf "Backing up %s...\n" "${target_file}"
  cp "${target_file}" "${backup}"
}

retroarch::set() {
    local key="${1}"
    local value="${2}"
    local file="${3}"
    local keyValue="${key}=${value}"

    printf "Setting %s=%s\n" "${key}" "${value}"
    if grep -E "^[[:space:]]*${key}[[:space:]]*=.*$" "${file}" >/dev/null; then
      sed -iE "s/^[[:space:]]*${key}[[:space:]]*=.*$/${keyValue}/" "${file}"
    else
      echo "${keyValue}" >> "${file}"
    fi
}

retroarch::setup() {
  local file="${1}"

  # Create backup
  retroarch::backup "${file}"

  # Savefiles
  retroarch::set "savefiles_in_content_dir" "true" "${file}"
  retroarch::set "sort_savefiles_by_content_enable" "false" "${file}"
  retroarch::set "sort_savefiles_enable" "true" "${file}"

  # Savestates
  retroarch::set "savestates_in_content_dir" "true" "${file}"
  retroarch::set "sort_savestates_by_content_enable" "false" "${file}"
  retroarch::set "sort_savestates_enable" "true" "${file}"
}
