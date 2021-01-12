#!/usr/bin/env bash

# Add `RETOOL_DEV`
if [ -d "$HOME/dev/retool_development" ]; then
  export RETOOL_DEV="$HOME/dev/retool_development"
fi

# Add `RETOOL_DEV`
if [ -d "$HOME/.nvm" ]; then
  nvm use 12.18.3
fi
