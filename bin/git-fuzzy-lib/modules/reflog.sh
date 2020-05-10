#!/usr/bin/env bash

# NB: only different from `log` in `CR` binding and preview diff
gf_reflog_menu_content() {
  gf_command_with_header git -c color.ui=always reflog
}

# shellcheck disable=2016
GF_REFLOG_PREVIEW_COMMAND='
REF={1}
{ [ -z "$REF" ] &&
  echo "nothing to show" } ||
  git diff "$(git merge-base "'"$GF_BASE_BRANCH"'" "$REF")" "$REF" | diff-so-fancy ||
  echo
'

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
    --preview "$GF_REFLOG_PREVIEW_COMMAND" \
    --bind 'enter:execute(git fuzzy diff "$(git merge-base "'"$GF_BASE_BRANCH"'" {1})" {1})' \
    --bind 'ctrl-p:execute(git fuzzy diff {1})' \
    --bind 'alt-p:execute(git fuzzy diff {1}^ {1})'
}

gf_reflog() {
  gf_reflog_menu_content | gf_fzf_reflog
}
