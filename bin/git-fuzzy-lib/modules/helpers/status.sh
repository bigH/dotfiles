#!/usr/bin/env bash

GF_STATUS_DIRECTORY_PREVIEW_COMMAND='ls -l --color=always'
if type exa >/dev/null 2>&1; then
  GF_STATUS_DIRECTORY_PREVIEW_COMMAND='exa -l --color=always'
fi

GF_STATUS_FILE_PREVIEW_COMMAND='cat'
if type bat >/dev/null 2>&1; then
  GF_STATUS_FILE_PREVIEW_COMMAND='bat --color=always'
fi

gf_helper_status_diff_content() {
  STATUS_CODE="$1"
  FILE_PATH="$2"

  if [ "??" = "$STATUS_CODE" ]; then
    if [ -d "$FILE_PATH" ]; then
      # shellcheck disable=2086
      gf_command_with_header $GF_STATUS_DIRECTORY_PREVIEW_COMMAND "$FILE_PATH"
    else
      # shellcheck disable=2086
      gf_command_with_header $GF_STATUS_FILE_PREVIEW_COMMAND "$FILE_PATH"
    fi
  elif [ ! -e "$FILE_PATH" ]; then
    echo "\`$CYAN$FILE_PATH$NORMAL\` ${RED}${BOLD}Deleted${NORMAL}"
  else
    # TODO this doesn't work for renames
    gf_command_with_header git diff HEAD -- "$FILE_PATH" | diff-so-fancy
  fi
}

gf_helper_status_add() {
  gf_command_logged git add -- "$@"
}

gf_helper_status_reset() {
  gf_command_logged git reset -- "$@"
}

gf_helper_status_checkout_head() {
  if [ "$#" = 0 ]; then
    gf_log_error 'tried to checkout in status with no file(s)'
  else
    gf_command_logged git checkout HEAD -- "$@"
  fi
}

gf_helper_status_add_patch_menu() {
  PATCH_CONTENTS="$(git diff -- "$@")"
  echo
}

gf_helper_status_add_patch() {
  echo
}
