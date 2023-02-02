#!/bin/sh

debug() {
  if [[ $DEBUG != 0 ]]; then
    printf '[ \033[00;35mDEBUG\033[0m ] %s\n' "$1"
  fi
}

info() {
  printf '[ \033[00;34m..\033[0m ] %s\n' "$1"
}

success() {
  printf '[ \033[00;32mOK\033[0m ] %s\n' "$1"
}

fail() {
  printf '[\033[0;31mFAIL\033[0m] %s\n' "$1" 1>&2 # Redirect to stderror
  exit 1
}

warn() {
  printf '[\033[1;33mWARN\033[0m] %s\n' "$1" 1>&2 # Redirect to stderror
}
