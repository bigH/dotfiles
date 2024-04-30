#!/usr/bin/env bash

# just for this script (unset below)
ALIASES_DIR="$DOT_FILES_DIR/aliases"

# just for this script (unset below)
source_aliases_for_expected_command() {
  FILENAME="$ALIASES_DIR/$1.sh"
  if one_command_exists "$@"; then
    auto_source "$FILENAME"
  else
    echo "${YELLOW}WARN${NORMAL}: Skipping '$FILENAME'; couldn't find $(quote_params "$@"))"
  fi
}

# expect this one to be there
auto_source "$ALIASES_DIR/core.sh"

# source any local-specific/private things
if [ -f "$ALIASES_DIR/local.sh" ]; then
  auto_source "$ALIASES_DIR/local.sh"
fi


# source these only if they're "visible" commands
source_aliases_for_expected_command git
source_aliases_for_expected_command docker
source_aliases_for_expected_command docker-compose
source_aliases_for_expected_command yarn

unset -f source_aliases_for_expected_command
unset ALIASES_DIR

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/aliases.sh" ]; then
    auto_source "$DOT_FILES_DIR/$DOT_FILES_ENV/aliases.sh"
  fi
fi
