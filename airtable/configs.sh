if [ -d "$HOME/h" ]; then
  export HYPERBASE_ROOT="$HOME/h"
  source "$HYPERBASE_ROOT/config/envrc"
  BUNYAN_LOG_LEVEL=warn
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
