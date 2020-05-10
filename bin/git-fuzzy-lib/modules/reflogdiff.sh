#!/usr/bin/env bash

GF_REFLOGDIFF_HEADER='
  Use `|` to separate CLI args for `git reflog` vs `git diff`.

  Examples:
   -G "Table"                      -- same cli params for both
   -G "Table" | --compact-summary  -- separate cli params

  Patch                Commit
┎────────────────────┬───────────┒
┃ M-P = merge-base   │ CR = diff ┃
┃ C-P = working copy │           ┃
┖────────────────────┴───────────┚

'

gf_fzf_reflogdiff() {
  # shellcheck disable=2016
  gf_fzf_one -m \
    --phony \
    --header-lines=2 \
    --header "$GF_REFLOGDIFF_HEADER" \
    --preview 'git fuzzy helper reflogdiff_diff_content {1} {q}' \
    --bind 'change:reload(git fuzzy helper reflogdiff_menu_content {q})' \
    --bind 'enter:execute(git fuzzy diff {1}^ {1})' \
    --bind 'ctrl-p:execute(git fuzzy diff {1})' \
    --bind 'alt-p:execute(git fuzzy diff "$(git merge-base "'"$GF_BASE_BRANCH"'" {1})" {1})'
}

gf_reflogdiff() {
  git fuzzy helper reflogdiff_menu_content | gf_fzf_reflogdiff
}
