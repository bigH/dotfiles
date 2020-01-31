#!/usr/bin/env bash

CONFIGS_DIR="$DOT_FILES_DIR/configs"

# basic configs
source "$CONFIGS_DIR/core.sh"
source "$CONFIGS_DIR/journal.sh"

# utility just for this script
function source_configs_for_expected_command() {
  if [ ! -z "$1" ]; then
    if command -v "$1" >/dev/null 2>&1; then
      source "$CONFIGS_DIR/$1.sh"
    else
      echo "${YELLOW}WARN${NORMAL}: Skipping '$CONFIGS_DIR/$1.sh' as '$1' not found"
    fi
  fi
}

# source these only if they're "visible" commands
source_configs_for_expected_command fzf
source_configs_for_expected_command kubectl
source_configs_for_expected_command ctags

unset -f source_configs_for_expected_command

if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/configs.sh" ]; then
    source "$DOT_FILES_DIR/$DOT_FILES_ENV/configs.sh"
  else
    source "$CONFIGS_DIR/no-env-context.sh"
  fi
fi
