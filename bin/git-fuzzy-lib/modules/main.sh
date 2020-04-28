#!/usr/bin/env bash

gf_menu_content() {
  gf_menu_item "status" "manage current status"
  echo
  gf_menu_item "diff" "compare content across revisions"
  gf_menu_item "branch" "manage and possibly browse branches"
  gf_menu_item "history" "browse history of a given file"
  gf_menu_item "reflog" "browse history of a given file"
  gf_menu_item "browse" "browse files at a given commit"
  echo
  gf_menu_exit
}

gf_fzf_main() {
  gf_fzf_one "$(hidden_preview_window_settings)"
}

gf_menu() {
  SELECTED_COMMAND="$(gf_menu_content | gf_fzf_main | cut -d':' -f1)"
  if [ -n "$SELECTED_COMMAND" ]; then
    COMMAND_FUNC="gf_${SELECTED_COMMAND}"
    if type "$COMMAND_FUNC" >/dev/null 2>&1; then
      eval "$COMMAND_FUNC"
    else
      log_error "\`$SELECTED_COMMAND\` not found."
    fi
  else
    log_error "no command chosen"
  fi
}
