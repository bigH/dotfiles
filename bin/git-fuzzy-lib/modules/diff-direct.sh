#!/usr/bin/env bash

# shellcheck disable=2016
GF_DIFF_DIRECT_HEADER='
-- RegEx above is used with `-G` --

'

gf_fzf_diff_direct() {
  PARAMETERS_QUOTED="$(quote_params "$@")"

  # shellcheck disable=2016
  RELOAD_COMMAND='git fuzzy helper diff_direct_menu_content {q} '"$PARAMETERS_QUOTED"
  PREVIEW_COMMAND='git fuzzy helper diff_direct_preview_content {q} {1} '"$PARAMETERS_QUOTED"

  gf_fzf -m --phony \
    --header-lines=2 \
    --header "$GF_DIFF_DIRECT_HEADER" \
    --preview "$PREVIEW_COMMAND" \
    --bind "change:reload($RELOAD_COMMAND)"
}

gf_diff_direct() {
  git fuzzy helper diff_direct_menu_content '' "$@" | gf_fzf_diff_direct "$@"
}
