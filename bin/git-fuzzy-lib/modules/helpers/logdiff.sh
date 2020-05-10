#!/usr/bin/env bash

# get the first token by `|`
gf_helper_logdiff_log_query() {
  echo "$1" | cut -d'|' -f1
}

# get the _last_ token by `|`
# NB: this supports using the same query for both chunks
gf_helper_logdiff_diff_query() {
  echo "$1" | rev | cut -d'|' -f1 | rev
}

gf_helper_logdiff_menu_content() {
  if [ -n "$1" ]; then
    QUERY="$(git fuzzy helper logdiff_log_query "$1")"
    # shellcheck disable=2086
    gf_git_command_with_header log $QUERY --pretty=oneline --abbrev-commit
  else
    gf_git_command_with_header log --pretty=oneline --abbrev-commit
  fi
}

gf_helper_logdiff_preview_content() {
  if [ -z "$1" ]; then
    echo "nothing to show"
  else
    REF="$1"
    QUERY="$(git fuzzy helper logdiff_diff_query "$2")"

    gf_git_command_with_header diff --stat="$FZF_PREVIEW_COLUMNS" "$REF^" "$REF"
    echo

    # shellcheck disable=2086
    gf_git_command_with_header diff "$REF^" "$REF" $QUERY | diff-so-fancy
  fi
}
