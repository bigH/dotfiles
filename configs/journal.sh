#!/usr/bin/env bash

# Add `journal` path
if [ -d "$HOME/.journal" ]; then
  export JOURNAL_PATH="$HOME/.journal"

  if [ -e "$JOURNAL_PATH/system/journal.init" ]; then
    source "$JOURNAL_PATH/system/journal.init"
  fi
fi

