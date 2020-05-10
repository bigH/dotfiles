#!/usr/bin/env bash

gf_menu_content() {
  gf_menu_item "status" "manage current status"
  echo
  gf_menu_item "branch" "manage and possibly browse branches"

  # TODO no history yet
  # gf_menu_item "history" "browse history of a given file"

  # TODO diff needs work for interactive mode
  # gf_menu_item "diff" "compare content across revisions"

  # TODO no browse yet
  # gf_menu_item "browse" "browse files at a given commit"

  echo
  gf_menu_item "log" "browse the log"
  gf_menu_item "reflog" "browse the reflog"

  echo
  gf_menu_header '-- Combinations --'
  echo

  gf_menu_item "logdiff" "search the log and diff simultaneously"
  gf_menu_item "reflogdiff" "search the reflog and diff simultaneously"

  echo
  gf_menu_header '-- GitHub --'
  echo

  if [ -n "$HUB_AVAILABLE" ]; then
    gf_menu_item "pr" "work with pull requests"
  fi
}

gf_fzf_main() {
  gf_fzf_one \
    "$(hidden_preview_window_settings)" \
    --bind "enter:execute(git fuzzy interactive {1})"
}

gf_menu() {
  gf_menu_content | gf_fzf_main
}
