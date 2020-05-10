#!/usr/bin/env bash
# shellcheck disable=2016

STATUS_HEADER='
  Selection        Stage         UNStage        !! DANGER !!
┎────────────────┬─────────────┬─────────────┰┰───────────────┒
┃ M-D = deselect │ M-S = file  │ M-R = file  ┃┃ M-C = commit  ┃
┃ M-A = select   │ C-S = patch │ C-R = patch ┃┃ M-U = restore ┃
┖────────────────┴─────────────┴─────────────┸┸───────────────┚
  -- editor is `'"${EDITOR}"'` --
  '

gf_fzf_status() {
  RELOAD="reload:git fuzzy helper status_menu_content"
  # shellcheck disable=2046,2016
  gf_fzf -m --header "$STATUS_HEADER" \
    --header-lines=2 \
    --preview "git fuzzy helper status_diff_content {1} {2}" \
    --bind "alt-c:execute(git commit)+$RELOAD" \
    --bind "alt-s:execute-silent(git fuzzy helper status_add {+2})+down+$RELOAD" \
    --bind "alt-r:execute-silent(git fuzzy helper status_reset {+2})+down+$RELOAD" \
    --bind "alt-u:execute-silent(git fuzzy helper status_checkout_head {2})+down+$RELOAD" \
    --bind "enter:execute-silent(git fuzzy helper status_edit {+2})+down+$RELOAD
      "
}

gf_status() {
  if [ -n "$(git status -s)" ]; then
    # shellcheck disable=2086
    git fuzzy helper status_menu_content | gf_fzf_status
  else
    gf_log_debug "nothing to commit, working tree clean"
    exit 1
  fi
}
