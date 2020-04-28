#!/usr/bin/env bash
# shellcheck disable=2016

gf_branch_menu_content() {
  git for-each-ref --sort='-committerdate' \
                   --format='%(refname)' \
                   refs/heads | \
    sed -e 's-refs/heads/--'
}

# shellcheck disable=2016
GF_BRANCH_PREVIEW_COMMAND='
  ref_focused={}
  ref_base="$(git merge-base "$ref_focused" "$(git merge-base-absolute)")"
  git diff "$ref_base" "$ref_focused" |
    diff-so-fancy
'

gf_fzf_branch() {
  # shellcheck disable=2046,2016
  gf_fzf_one -m --preview "$GF_BRANCH_PREVIEW_COMMAND"
}

gf_branch_direct() {
  ref_provided="$(remove_switches "$@")"
  if [ -z "$ref_provided" ]; then
    ref_selected="$(gf_branch_menu_content | gf_fzf_branch)"
    if [ -z "$ref_selected" ]; then
      gf_log "no branch selected"
    else
      gf_log "git branch $(quote_params "$@") '$ref_selected'"
      git branch "$@" "$ref_selected"
    fi
  else
    git branch "$@"
  fi
}

gf_branch() {
  ref_selected="$(gf_branch_menu_content | gf_fzf_branch)"
  # TODO: gotta implement something here.
}
