#!/usr/bin/env bash
# shellcheck disable=2016

STATUS_COMMAND="git -c color.ui=always status --short"

STATUS_DIRECTORY_PREVIEW_COMMAND='ls -l --color=always "$FILEPATH"'
if type exa >/dev/null 2>&1; then
  STATUS_DIRECTORY_PREVIEW_COMMAND='exa -l --color=always "$FILEPATH"'
fi

STATUS_FILE_PREVIEW_COMMAND='cat "$FILEPATH"'
if type bat >/dev/null 2>&1; then
  STATUS_FILE_PREVIEW_COMMAND='bat "$FILEPATH"'
fi

GF_STATUS_PREVIEW_COMMAND='
{ [ ! -e {2} ] && echo Deleted. } || \
{ [ "??" = {1} ] && [ -d {2} ] && exa -l --color=always {2} } || \
{ [ "??" = {1} ] && [ -e {2} ] && bat -p --color=always {2} } || \
git diff HEAD -- {2} | diff-so-fancy
'

gf_fzf_status() {
  RELOAD="reload:$STATUS_COMMAND"
  HEADER="ALT-S = stage / ALT-R = unstage / ALT-U = restore"
  # shellcheck disable=2046,2016
  gf_fzf -m --header "$HEADER" \
    --preview "$GF_STATUS_PREVIEW_COMMAND" \
    --bind "alt-s:execute-silent(git add {2})+$RELOAD" \
    --bind "alt-r:execute-silent(git reset {2})+$RELOAD" \
    --bind "alt-u:execute-silent(git checkout HEAD -- {2})+$RELOAD"
}

gf_status() {
  if [ -n "$(git status -s)" ]; then
    $STATUS_COMMAND | gf_fzf_status
  else
    gf_log "nothing to commit, working tree clean"
    exit 1
  fi
}
