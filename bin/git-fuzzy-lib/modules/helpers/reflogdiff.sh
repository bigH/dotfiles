#!/usr/bin/env bash

# get the first token by `|`
gf_helper_reflogdiff_log_query() {
  echo "$1" | cut -d'|' -f1
}

# get the _last_ token by `|`
# NB: this supports using the same query for both chunks
gf_helper_reflogdiff_diff_query() {
  echo "$1" | rev | cut -d'|' -f1 | rev
}

gf_helper_reflogdiff_menu_content() {
  if [ -n "$1" ]; then
    QUERY="$(gf_helper_reflogdiff_log_query "$1")"
    # shellcheck disable=2086
    gf_command_with_header git -c color.ui=always reflog $QUERY
  else
    gf_command_with_header git -c color.ui=always reflog
  fi
}

gf_helper_reflogdiff_diff_content() {
  if [ -z "$1" ]; then
    echo "nothing to show"
  else
    REF="$1"
    QUERY="$(gf_helper_reflogdiff_diff_query "$2")"
    # shellcheck disable=2086
    gf_command_with_header git diff "$REF" "$(git merge-base "$GF_BASE_BRANCH" "$REF")" $QUERY | diff-so-fancy
  fi
}
