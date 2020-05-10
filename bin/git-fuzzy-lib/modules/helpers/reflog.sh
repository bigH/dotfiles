#!/usr/bin/env bash

gf_helper_reflog_menu_content() {
  gf_command_with_header git -c color.ui=always reflog
}

gf_helper_reflog_diff_content() {
  if [ -z "$1" ]; then
    echo "nothing to show"
  else
    REF="$1"
    # shellcheck disable=2086
    gf_command_with_header git diff "$(git merge-base "$GF_BASE_BRANCH" "$REF")" "$REF" | diff-so-fancy
  fi
}
