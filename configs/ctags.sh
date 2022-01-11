#!/usr/bin/env bash

# find ctags directory using brew
if [[ "$OSTYPE" == "darwin"* ]]; then
  CTAGS_HOME=`brew info universal-ctags | grep /opt/homebrew/Cellar | cut -d' ' -f1`

  if [ -d "$CTAGS_HOME" ]; then
    export PATH="$CTAGS_HOME/bin:$PATH"
  else
    echo "ERROR: can't find \$CTAGS_HOME; got '$CTAGS_HOME'"
  fi
fi
