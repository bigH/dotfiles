#!/usr/bin/env bash

gf_menu_item() {
  printf 'choice %s%s%-10s%s %s%s%s' "$MAGENTA" "$BOLD" "$1" "$NORMAL" "$GRAY" "$2" "$NORMAL"
  echo
}

gf_menu_header() {
  printf 'header %s%s%s%s' "$CYAN" "$BOLD" "$1" "$NORMAL"
  echo
}

gf_menu_content() {
  gf_menu_item "status" "manage current status"
  echo
  gf_menu_item "branch" "manage and possibly browse branches"
  gf_menu_item "log" "browse the log"
  gf_menu_item "reflog" "browse the reflog"
  gf_menu_item "diff" "compare content across revisions"

  # TODO: coming soon
  # gf_menu_item "history" "browse history of a given file"
  # gf_menu_item "browse" "browse files at a given commit"

  echo
  gf_menu_header '-- Combinations --'
  echo
  gf_menu_item "logdiff" "search the log and diff simultaneously"
  gf_menu_item "reflogdiff" "search the reflog and diff simultaneously"

  if [ -n "$HUB_AVAILABLE" ]; then
    echo
    gf_menu_header '-- GitHub --'
    echo
    gf_menu_item "pr" "work with pull requests"
  fi
}

gf_fzf_main() {
  gf_fzf_one \
    "$(hidden_preview_window_settings)" \
    --with-nth=2.. \
    --bind "enter:execute([ {1} = 'choice' ] && git fuzzy interactive {2})"
}

gf_menu() {
  gf_menu_content | gf_fzf_main
}
