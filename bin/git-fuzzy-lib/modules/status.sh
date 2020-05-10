#!/usr/bin/env bash
# shellcheck disable=2016

STATUS_COMMAND="git -c color.ui=always status --short"

# TODO Renames don't work rn
# { [[ {1} =~ "R" ]] && [ ! -e {2} ] && git diff -C HEAD -- {4} | diff-so-fancy } ||
GF_STATUS_PREVIEW_COMMAND='
  { [ "??" = {1} ] && [ -d {2} ] && exa -l --color=always {2} } ||
  { [ "??" = {1} ] && [ -f {2} ] && bat -p --color=always {2} } ||
  { [ ! -e {2} ] && echo Deleted. } ||
  git diff HEAD -- {2} | diff-so-fancy
'

STATUS_HEADER='
  Selection        Stage         UNStage        !! DANGER !!
┎────────────────┬─────────────┬─────────────┰┰───────────────┒
┃ M-D = deselect │ M-S = file  │ M-R = file  ┃┃ M-C = commit  ┃
┃ M-A = select   │ C-S = patch │ C-R = patch ┃┃ M-U = restore ┃
┖────────────────┴─────────────┴─────────────┸┸───────────────┚
  -- editor is `'"${EDITOR}"'` --
  '

gf_fzf_status() {
  RELOAD="reload:$STATUS_COMMAND"
  # shellcheck disable=2046,2016
  gf_fzf -m --header "$STATUS_HEADER" \
    --header-lines=2 \
    --preview "git fuzzy helper status_diff_content {1} {2}" \
    --bind "alt-c:execute(git commit)+$RELOAD" \
    --bind "alt-s:execute-silent(git fuzzy helper status_add {+2})+down+$RELOAD" \
    --bind "alt-r:execute-silent(git fuzzy helper status_reset {+2})+down+$RELOAD" \
    --bind "alt-u:execute-silent(git checkout HEAD -- {2})+down+$RELOAD" \
    --bind "enter:execute-silent($EDITOR {+2})+down+$RELOAD"
}

gf_status() {
  if [ -n "$(git status -s)" ]; then
    # shellcheck disable=2086
    gf_command_with_header $STATUS_COMMAND | gf_fzf_status
  else
    gf_log_debug "nothing to commit, working tree clean"
    exit 1
  fi
}
