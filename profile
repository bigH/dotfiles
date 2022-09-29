#!/usr/bin/env bash

export DOT_FILES_DIR="$HOME/.hiren"

source "$DOT_FILES_DIR/sh_utils.sh"

DOT_FILES_ENV="$(cat "$DOT_FILES_DIR/env-context")"
export DOT_FILES_ENV

if type nvim >/dev/null 2>&1; then
  EDITOR="$(which nvim)"
else
  EDITOR="$(which vim)"
fi
export EDITOR

source "$DOT_FILES_DIR/configs/all.sh"

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -d "$DOT_FILES_DIR/$DOT_FILES_ENV/bin" ]; then
    export PATH="$DOT_FILES_DIR/$DOT_FILES_ENV/bin:$PATH"
  fi
fi

export HIREN_PROFILE_SOURCED=true
