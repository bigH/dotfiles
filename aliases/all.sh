#!/usr/bin/env bash

ALIASES="$DOT_FILES_DIR/aliases"

# utility just for this script
function source_aliases_for_expected_command() {
  if [ -n "$1" ]; then
    if command -v "$1" >/dev/null 2>&1; then
      auto_source "$ALIASES/$1.sh"
    else
      echo "${YELLOW}WARN${NORMAL}: Skipping '$ALIASES/$1.sh' as '$1' not found"
    fi
  fi
}

# expect this one to be there
auto_source "$ALIASES/core.sh"

# source these only if they're "visible" commands
source_aliases_for_expected_command git
source_aliases_for_expected_command docker
source_aliases_for_expected_command docker-compose
source_aliases_for_expected_command kubectl
source_aliases_for_expected_command yarn

unset -f source_aliases_for_expected_command
unset ALIASES

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/aliases.sh" ]; then
    auto_source "$DOT_FILES_DIR/$DOT_FILES_ENV/aliases.sh"
  fi
fi
