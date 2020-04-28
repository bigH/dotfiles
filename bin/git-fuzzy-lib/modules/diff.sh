#!/usr/bin/env bash

gf_diff_menu_content() {
  printf "%s.%s %s%s%s%s\n" "$GRAY" "$NORMAL" "$MAGENTA" "$BOLD" "compare against working copy" "$NORMAL"
  echo
  # shellcheck disable=2016
  git --no-pager branch --list | cut -c3- | xargs -I '{}' bash -c \
    'printf "%sL%s %s%s%s%s %s%s%s\n" "$GRAY" "$NORMAL" "$GREEN" "$BOLD" "{}" "$NORMAL" "$GRAY" "$(git log -1 --pretty=format:%s "{}" 2> /dev/null)" "$NORMAL"'
  echo
  # shellcheck disable=2016
  git --no-pager branch --list --remote | cut -c3- | xargs -I '{}' bash -c \
    'printf "%sR%s %s%s%s%s\n" "$GRAY" "$NORMAL" "$YELLOW" "$BOLD" "{}" "$NORMAL"'
  echo
  git log "--pretty=format:%C(Gray)C%Creset %C(Red)%h%Creset %C(Gray)%s%Creset"
}

# shellcheck disable=2016
GF_DIFF_PREVIEW_COMMAND='
  REF={2}
  TYPE={1}
  { [ -z "$TYPE" ] &&
      echo "nothing to show" } ||
  { [ "." = "$TYPE" ] &&
      git diff HEAD | diff-so-fancy } ||
  { [ "L" = "$TYPE" ] || [ "R" = "$TYPE" ] &&
      git diff "$(git merge-base "$REF" "$(git merge-base-absolute)")" "$REF" |
        diff-so-fancy } ||
  { [ "C" = "$TYPE" ] &&
      git show "$REF" | diff-so-fancy } ||
  echo
'

gf_fzf_diff_select() {
  # shellcheck disable=2046,2016
  gf_fzf -m 2 --preview "$GF_DIFF_PREVIEW_COMMAND"
}

gf_fzf_display_diff() {
  gf_log 'diff preview: git diff '"$PARAMETERS_QUOTED"' -- {} | diff-so-fancy'
  gf_fzf -m --preview 'git diff '"$PARAMETERS_QUOTED"' -- {} | diff-so-fancy'
}

gf_diff_direct() {
  PARAMETERS_QUOTED="$(quote_params "$@")"
  # TODO support fail on empty
  gf_log "diff file-list: git diff --name-only $PARAMETERS_QUOTED"
  git diff --name-only "$@" | gf_fzf_display_diff
}

gf_diff() {
  if [ $# -gt 0 ]; then
    gf_diff_direct "$@"
  else
    TARGET="$(gf_diff_menu_content | gf_fzf_diff_select)"
    if [ -z "$TARGET" ]; then
      log_error "no diff target chosen"
    else
      if [ "$(echo "$TARGET" | wc -l)" -eq 1 ]; then
        TYPE="$(echo "$TARGET" | awk '{print $1;}')"
        if [ "$TYPE" = '.' ]; then
          gf_diff_direct HEAD
        else
          REF="$(echo "$TARGET" | awk '{print $2;}')"
          gf_diff_direct "$REF"
        fi
      else
        FIRST="$(echo "$TARGET" | head -1)"
        FIRST_TYPE="$(echo "$FIRST" | awk '{print $1;}')"
        FIRST_REF="$(echo "$FIRST" | awk '{print $2;}')"
        SECOND="$(echo "$TARGET" | tail -1)"
        SECOND_TYPE="$(echo "$SECOND" | awk '{print $1;}')"
        SECOND_REF="$(echo "$SECOND" | awk '{print $2;}')"

        if [ "$FIRST_TYPE" = '.' ]; then
          gf_diff_direct "$SECOND_REF"
        elif [ "$SECOND_TYPE" = '.' ]; then
          gf_diff_direct "$FIRST_REF"
        else
          gf_diff_direct "$FIRST_REF" "$SECOND_REF"
        fi
      fi
    fi
  fi
}
