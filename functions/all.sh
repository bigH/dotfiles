#!/usr/bin/env bash

# just for this script (unset below)
FUNCTIONS_DIR="$DOT_FILES_DIR/functions"

# just for this script (unset below)
source_functions_for_expected_command() {
  FILENAME="$FUNCTIONS_DIR/$1.sh"
  if one_command_exists "$@"; then
    auto_source "$FILENAME"
  else
    echo "${YELLOW}WARN${NORMAL}: Skipping '$FILENAME'; couldn't find $(quote_params "$@"))"
  fi
}

# basic functions
auto_source "$FUNCTIONS_DIR/core.sh"

# source or at least warn
source_functions_for_expected_command fzf
source_functions_for_expected_command rg
source_functions_for_expected_command kubectl
source_functions_for_expected_command docker

unset -f source_functions_for_expected_command
unset ALIASES

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/functions.sh" ]; then
    auto_source "$DOT_FILES_DIR/$DOT_FILES_ENV/functions.sh"
  fi
fi
