#!/usr/bin/env bash

GF_REFLOG_HEADER='
  Patch                Commit
┎────────────────────┬────────────┒
┃ CR = merge-base    │ M-P = diff ┃
┃ C-P = working copy │            ┃
┖────────────────────┴────────────┚

'

gf_fzf_reflog() {
  # shellcheck disable=2016
  gf_fzf_one -m \
    --header "$GF_REFLOG_HEADER" \
    --header-lines=2 \
    --preview 'git fuzzy helper reflog_diff_content {1}' \
    --bind 'enter:execute(git fuzzy diff "$(git merge-base "'"$GF_BASE_BRANCH"'" {1})" {1})' \
    --bind 'ctrl-p:execute(git fuzzy diff {1})' \
    --bind 'alt-p:execute(git fuzzy diff {1}^ {1})'
}

gf_reflog() {
  git fuzzy helper reflog_menu_content | gf_fzf_reflog
}
