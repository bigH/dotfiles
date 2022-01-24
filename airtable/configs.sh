#!/usr/bin/env bash

if [ -d "$HOME/h" ]; then
  export HYPERBASE_ROOT="$HOME/h"
  # NOTE: if this is sourced more than once, it'll cause subsequent path updates to disappear
  source "$HYPERBASE_ROOT/config/envrc"
  BUNYAN_LOG_LEVEL=info
  export BUNYAN_LOG_LEVEL
fi

if [ -d "$HYPERBASE_ROOT/source/hyperbase" ]; then
  export HYPERBASE_DEV_PATH="$HYPERBASE_ROOT/source/hyperbase"
fi

if [ -d "$DOT_FILES_DIR/arcanist" ]; then
  export PATH="$DOT_FILES_DIR/arcanist/bin:$PATH"
fi

if [ -d "/usr/local/mysql/bin" ]; then
  export PATH="/usr/local/mysql/bin:$PATH"
fi
