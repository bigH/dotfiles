#!/usr/bin/env bash

export DOT_FILES_DIR="$HOME/.hiren"

source "$DOT_FILES_DIR/sh_utils.sh"

DOT_FILES_ENV="$(cat "$DOT_FILES_DIR/env-context")"
export DOT_FILES_ENV

if [ -x '/opt/homebrew/bin/brew' ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x '/usr/local/bin/brew' ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

source "$DOT_FILES_DIR/configs/all.sh"

if type nvim >/dev/null 2>&1; then
  EDITOR="$(which nvim)"
elif [ -x '/usr/local/bin/nvim' ]; then
  EDITOR='/usr/local/bin/nvim'
elif [ -x '/opt/homebrew/bin/nvim' ]; then
  EDITOR='/opt/homebrew/bin/nvim'
else
  EDITOR="$(which vim)"
fi
export EDITOR

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -d "$DOT_FILES_DIR/$DOT_FILES_ENV/bin" ]; then
    export PATH="$DOT_FILES_DIR/$DOT_FILES_ENV/bin:$PATH"
  fi
fi

export HIREN_PROFILE_SOURCED=true
