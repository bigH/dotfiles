#!/usr/bin/env bash

CONFIGS="$DOT_FILES_DIR/configs"

# utility just for this script
function source_configs_for_expected_command() {
  if [ ! -z "$1" ]; then
    if command -v "$1" >/dev/null 2>&1; then
      auto_source "$CONFIGS/$1.sh"
    else
      echo "${YELLOW}WARN${NORMAL}: Skipping '$CONFIGS/$1.sh' as '$1' not found"
    fi
  fi
}

# expect this one to be there
auto_source "$CONFIGS/core.sh"

# source these only if they're "visible" commands
source_configs_for_expected_command ctags
source_configs_for_expected_command fd
source_configs_for_expected_command fzf
source_configs_for_expected_command kubectl
source_configs_for_expected_command rg

unset -f source_configs_for_expected_command
unset CONFIGS

if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/configs.sh" ]; then
    auto_source "$DOT_FILES_DIR/$DOT_FILES_ENV/configs.sh"
  elif [ -f "$CONFIGS/no-env-context.sh" ]; then
    auto_source "$CONFIGS/no-env-context.sh"
  fi
fi
