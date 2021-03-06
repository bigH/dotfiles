#!/usr/bin/env bash

FUNCTIONS_DIR="$DOT_FILES_DIR/functions"

# basic functions
auto_source "$FUNCTIONS_DIR/core.sh"

# utility just for this script
function source_functions_for_expected_command() {
  if [ -n "$1" ]; then
    if command -v "$1" >/dev/null 2>&1; then
      auto_source "$FUNCTIONS_DIR/$1.sh"
    else
      echo "${YELLOW}WARN${NORMAL}: Skipping '$FUNCTIONS_DIR/$1.sh' as '$1' not found"
    fi
  fi
}

# source or at least warn
source_functions_for_expected_command fzf
source_functions_for_expected_command rg
source_functions_for_expected_command kubectl

unset -f source_functions_for_expected_command
unset ALIASES

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/functions.sh" ]; then
    auto_source "$DOT_FILES_DIR/$DOT_FILES_ENV/functions.sh"
  fi
fi
