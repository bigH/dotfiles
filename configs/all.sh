#!/usr/bin/env bash

# just for this script (unset below)
CONFIGS_DIR="$DOT_FILES_DIR/configs"

# just for this script (unset below)
source_configs_for_expected_command() {
  FILENAME="$CONFIGS_DIR/$1.sh"
  if one_command_exists "$@"; then
    auto_source "$FILENAME"
  else
    echo "${YELLOW}WARN${NORMAL}: Skipping '$FILENAME'; couldn't find $(quote_params "$@"))"
  fi
}

# expect this one to be there
auto_source "$CONFIGS_DIR/core.sh"

# journal command is provided from `JOURNAL_PATH` - set in this file, so can't command check
auto_source "$CONFIGS_DIR/journal.sh"

# source these only if they're "visible" commands
source_configs_for_expected_command bat
source_configs_for_expected_command ctags
source_configs_for_expected_command fd fdfind
source_configs_for_expected_command fzf
source_configs_for_expected_command kubectl
source_configs_for_expected_command helm
source_configs_for_expected_command rg

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/configs.sh" ]; then
    auto_source "$DOT_FILES_DIR/$DOT_FILES_ENV/configs.sh"
  fi
fi

unset -f source_configs_for_expected_command
unset CONFIGS_DIR
