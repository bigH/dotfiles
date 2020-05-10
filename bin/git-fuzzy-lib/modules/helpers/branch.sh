#!/usr/bin/env bash

GF_BRANCH_CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

gf_helper_branch_menu_content() {
  echo "${RED}${GF_BRANCH_CURRENT_BRANCH}${NORMAL}"

  # locals sorted by last commit
  GF_BRANCH_LOCAL_BRANCHES="$(git for-each-ref --sort='-committerdate' \
    --format="$GREEN$BOLD%(refname:short)$NORMAL|$MAGENTA%(committerdate:relative)$NORMAL|$CYAN%(committername)$NORMAL" \
    refs/heads | \
    column -t -s'|' \
  )"

  if [ -n "$GF_BRANCH_LOCAL_BRANCHES" ]; then
    echo
    echo "$GREEN$GF_BRANCH_LOCAL_BRANCHES$NORMAL"
  fi

  # locals sorted by last commit
  GF_BRANCH_REMOTE_BRANCHES="$(git for-each-ref --sort='-committerdate' \
    --format="$YELLOW$BOLD%(refname:short)$NORMAL|$MAGENTA%(committerdate:relative)$NORMAL|$CYAN%(committername)$NORMAL" \
    refs/remotes | \
    column -t -s'|' \
  )"

  if [ -n "$GF_BRANCH_REMOTE_BRANCHES" ]; then
    echo
    echo "$GF_BRANCH_REMOTE_BRANCHES"
  fi
}

gf_helper_branch_diff_content() {
  if [ -z "$1" ]; then
    echo "nothing to show"
  else
    REF="$1"
    # shellcheck disable=2086
    gf_command_with_header git diff "$(git merge-base "$GF_BASE_BRANCH" "$REF")" "$REF" | diff-so-fancy
  fi
}

gf_helper_branch_is_local() {
  BRANCH_IF_LOCAL="$(git for-each-ref --format='%(refname:short)' "refs/heads/$1")"
  test -n "$BRANCH_IF_LOCAL"
}

gf_helper_branch_checkout() {
  if [ -n "$(git status --short)" ]; then
    gf_command_logged git stash
  fi
  if git fuzzy helper branch_is_local "$1"; then
    gf_command_logged git checkout "$1"
  else
    STRIPPED_REMOTE="${1#*/}"
    gf_command_logged git checkout -b "$STRIPPED_REMOTE" "$1"
  fi
}

gf_helper_branch_delete() {
  if git fuzzy helper branch_is_local "$1"; then
    gf_command_logged git branch -D "$1"
  else
    STRIPPED_REMOTE="${1#*/}"
    REMOTE="${1%%/*}"
    gf_command_logged git push "$REMOTE" --delete "$STRIPPED_REMOTE"
  fi
}
