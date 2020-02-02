#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  fpath+="$DOT_FILES_DIR/ripgrep/complete"
elif [[ "$SHELL" == *'bash' ]]; then
  echo "TODO: rg completion"
fi

