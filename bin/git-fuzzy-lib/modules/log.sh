#!/usr/bin/env bash

GF_LOG_HEADER='
  Patch                Commit
┎────────────────────┬───────────┒
┃ M-P = merge-base   │ CR = diff ┃
┃ C-P = working copy │           ┃
┖────────────────────┴───────────┚

'

gf_fzf_log() {
  # shellcheck disable=2016
  gf_fzf_one -m \
    --header "$GF_LOG_HEADER" \
    --header-lines=2 \
    --preview 'git fuzzy helper log_preview_content {1}' \
    --bind 'enter:execute(git fuzzy diff {1}^ {1})' \
    --bind 'ctrl-p:execute(git fuzzy diff {1})' \
    --bind 'alt-p:execute(git fuzzy diff "$(git merge-base "'"$GF_BASE_BRANCH"'" {1})" {1})'
  }

gf_log() {
  git fuzzy helper log_menu_content | gf_fzf_log
}
