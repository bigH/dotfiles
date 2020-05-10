#!/usr/bin/env bash

gf_helper_log_menu_content() {
  gf_git_command_with_header log --pretty=oneline --abbrev-commit
}

gf_helper_log_preview_content() {
  if [ -z "$1" ]; then
    echo "nothing to show"
  else
    REF="$1"
    # shellcheck disable=2086
    gf_git_command_with_header diff "$REF^" "$REF" | diff-so-fancy
  fi
}

