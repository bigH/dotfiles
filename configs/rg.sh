#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  fpath+="$DOT_FILES_DIR/ripgrep/complete"
elif [[ "$SHELL" == *'bash' ]]; then
  echo "TODO: rg completion"
fi

export RIPGREP_CONFIG_PATH="$DOT_FILES_DIR/ripgreprc"
