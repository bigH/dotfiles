#!/usr/bin/env bash

gf_log_menu_content() {
  gf_command_with_header git -c color.ui=always log --pretty=oneline --abbrev-commit
}

# shellcheck disable=2016
GF_LOG_PREVIEW_COMMAND='
REF={1}
{ [ -z "$REF" ] &&
  echo "nothing to show" } ||
  git diff "$REF^" "$REF" | diff-so-fancy ||
  echo
'

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
    --preview "$GF_LOG_PREVIEW_COMMAND" \
    --bind 'enter:execute(git fuzzy diff {1}^ {1})' \
    --bind 'ctrl-p:execute(git fuzzy diff {1})' \
    --bind 'alt-p:execute(git fuzzy diff "$(git merge-base "'"$GF_BASE_BRANCH"'" {1})" {1})'
  }

gf_log() {
  gf_log_menu_content | gf_fzf_log
}
