#!/usr/bin/env bash

export BUNYAN_LOG_LEVEL=warn

# if command_exists pyenv; then
#   eval "$(pyenv init -)"
# fi

if [ -d "$HOME/h" ]; then
  export HYPERBASE_ROOT="$HOME/h"
fi

if [ -d "$HYPERBASE_ROOT/source/hyperbase" ]; then
  export HYPERBASE_DEV_PATH="$HYPERBASE_ROOT/source/hyperbase"
  export HYPER_ETL_PATH="$HYPERBASE_DEV_PATH/analytics"
fi

if [ -d "$HYPERBASE_ROOT/source/a-cli" ]; then
  export A_CLI_DEV_PATH="$HYPERBASE_ROOT/source/a-cli"
fi

if [ -d "/usr/local/mysql/bin" ]; then
  export PATH="/usr/local/mysql/bin:$PATH"
fi

if [ -d "$HOME/Library/Android/sdk/platform-tools" ]; then
  export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
fi

if [ -d "$HYPERBASE_ROOT" ] && [ -z "${NODE_VIRTUAL_ENV+1}" ]; then
  # NOTE: if this is sourced more than once, it'll cause subsequent path updates to disappear
  # shellcheck disable=1091
  source "$HYPERBASE_ROOT/config/envrc"
fi

if [ -f "$HYPERBASE_ROOT/cargo/env" ]; then
  # shellcheck disable=1091
  source "$HYPERBASE_ROOT/cargo/env"
fi
