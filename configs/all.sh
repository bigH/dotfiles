#!/usr/bin/env bash

# just for this script (unset below)
CONFIGS_DIR="$DOT_FILES_DIR/configs"

if command_exists auto_source; then
  SOURCE_COMMAND="auto_source"
else
  SOURCE_COMMAND="source"
fi

# expect this one to be there
$SOURCE_COMMAND "$CONFIGS_DIR/core.sh"
$SOURCE_COMMAND "$CONFIGS_DIR/github.sh"

# journal command is provided from `JOURNAL_PATH` - set in this file, so can't command check
$SOURCE_COMMAND "$CONFIGS_DIR/journal.sh"

# just for this script (unset below)
source_configs_for_expected_command() {
  FILENAME="$CONFIGS_DIR/$1.sh"
  if one_command_exists "$@"; then
    $SOURCE_COMMAND "$FILENAME"
  fi
}

# $SOURCE_COMMAND these only if they're "visible" commands
source_configs_for_expected_command bat
source_configs_for_expected_command fd fdfind
source_configs_for_expected_command fzf
source_configs_for_expected_command kubectl
source_configs_for_expected_command helm
source_configs_for_expected_command rg

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/configs.sh" ]; then
    $SOURCE_COMMAND "$DOT_FILES_DIR/$DOT_FILES_ENV/configs.sh"
  fi
fi

unset -f source_configs_for_expected_command
unset CONFIGS_DIR
unset SOURCE_COMMAND
