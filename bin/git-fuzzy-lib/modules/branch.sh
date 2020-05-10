#!/usr/bin/env bash

GF_BRANCH_HEADER='
  Checkout                Patch                 !! DANGER !!
┎───────────────────────┬────────────────────┰┰──────────────┒
┃ CR = checkout         │ M-P = merge-base   ┃┃ M-D = delete ┃
┃ (stashes any changes) │ C-P = working copy ┃┃ (local only) ┃
┖───────────────────────┴────────────────────┸┸──────────────┚

'

GF_BRANCH_RELOAD="reload(git fuzzy helper branch_menu_content)"

GF_ATTEMPT_CHECKOUT="git fuzzy helper branch_checkout {1}"
GF_BRANCH_ENTER_BINDING="execute-silent($GF_ATTEMPT_CHECKOUT)+$GF_BRANCH_RELOAD"

GF_ATTEMPT_DELETE="git fuzzy helper branch_delete {1}"
GF_BRANCH_DELETE_BINDING="execute-silent($GF_ATTEMPT_DELETE)+$GF_BRANCH_RELOAD"

gf_fzf_branch() {
  # shellcheck disable=2046,2016
  gf_fzf_one -m \
    --header "$GF_BRANCH_HEADER" \
    --bind "enter:$GF_BRANCH_ENTER_BINDING" \
    --bind "alt-d:$GF_BRANCH_DELETE_BINDING" \
    --bind "ctrl-p:execute(git fuzzy diff {1})" \
    --bind 'alt-p:execute(git fuzzy diff "$(git merge-base "'"$GF_BASE_BRANCH"'" {1})" {1})' \
    --preview 'git fuzzy helper branch_preview_content {1}'
}

gf_branch() {
  git fuzzy helper branch_menu_content | gf_fzf_branch
}
