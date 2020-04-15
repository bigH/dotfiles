#!/usr/bin/env bash

gf_menu_content() {
  gf_menu_item "status" "manage current status"
  echo
  gf_menu_item "diff" "compare content across revisions"
  gf_menu_item "browse" "browse files at a given commit"
  gf_menu_item "branches" "manage and possibly browse branches"
  gf_menu_item "history" "browse history of a given file"
  echo
  gf_menu_exit
}

gf_fzf_main() {
  gf_fzf_one "$NO_FZF_PREVIEW"
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
