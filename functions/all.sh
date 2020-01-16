#!/usr/bin/env bash

FUNCTIONS_DIR="$DOT_FILES_DIR/functions"

# basic functions
source "$FUNCTIONS_DIR/core.sh"

# utility just for this script
function source_functions_for_expected_command() {
  if [ ! -z "$1" ]; then
    if command -v "$1" >/dev/null 2>&1; then
      source "$FUNCTIONS_DIR/$1.sh"
    else
      echo "${YELLOW}WARN${NORMAL}: Skipping '$FUNCTIONS_DIR/$1.sh' as '$1' not found"
    fi
  fi
}

# source or at least warn
source_functions_for_expected_command fzf
source_functions_for_expected_command rg

unset -f source_functions_for_expected_command

if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/functions.sh" ]; then
    source "$DOT_FILES_DIR/$DOT_FILES_ENV/functions.sh"
  fi
fi

