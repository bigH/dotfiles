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
    QUERY="$(git fuzzy helper reflogdiff_log_query "$1")"
    # shellcheck disable=2086
    gf_git_command_with_header reflog $QUERY
  else
    gf_git_command_with_header reflog
  fi
}

gf_helper_reflogdiff_preview_content() {
  if [ -z "$1" ]; then
    echo "nothing to show"
  else
    REF="$1"
    QUERY="$(git fuzzy helper reflogdiff_diff_query "$2")"

    gf_git_command_with_header diff --stat="$FZF_PREVIEW_COLUMNS" "$(git merge-base "$GF_BASE_BRANCH" "$REF")" "$REF"
    echo

    # shellcheck disable=2086
    gf_git_command_with_header diff "$(git merge-base "$GF_BASE_BRANCH" "$REF")" "$REF" $QUERY | diff-so-fancy
  fi
}
