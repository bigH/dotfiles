#!/usr/bin/env bash
# shellcheck disable=2016

REFLOG_COMMAND="git -c color.ui=always reflog"

gf_reflog_menu_content() {
  git reflog
}

GF_REFLOG_PREVIEW_COMMAND='git diff {1} | diff-so-fancy'

gf_fzf_reflog() {
  gf_fzf_one -m \
             --preview "$GF_REFLOG_PREVIEW_COMMAND" \
             --bind 'enter:execute(git fuzzy diff {1})'
}

gf_reflog() {
  gf_reflog_menu_content | gf_fzf_reflog
}
