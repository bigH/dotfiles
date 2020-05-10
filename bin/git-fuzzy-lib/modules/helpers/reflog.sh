#!/usr/bin/env bash

gf_helper_reflog_menu_content() {
  gf_git_command_with_header reflog
}

gf_helper_reflog_preview_content() {
  if [ -z "$1" ]; then
    echo "nothing to show"
  else
    REF="$1"
    # shellcheck disable=2086
    gf_git_command_with_header diff "$(git merge-base "$GF_BASE_BRANCH" "$REF")" "$REF" | diff-so-fancy
  fi
}
