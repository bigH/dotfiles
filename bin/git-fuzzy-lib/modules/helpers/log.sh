#!/usr/bin/env bash

gf_helper_log_menu_content() {
  gf_command_with_header git -c color.ui=always log --pretty=oneline --abbrev-commit
}

gf_helper_log_diff_content() {
  if [ -z "$1" ]; then
    echo "nothing to show"
  else
    REF="$1"
    # shellcheck disable=2086
    gf_command_with_header git diff "$REF^" "$REF" | diff-so-fancy
  fi
}

