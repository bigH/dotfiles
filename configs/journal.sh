#!/usr/bin/env bash

# Add `journal` path
if [ -d "$HOME/.journal" ]; then
  export JOURNAL_PATH="$HOME/.journal"
  export PATH="$JOURNAL_PATH/bin:$PATH"
fi

