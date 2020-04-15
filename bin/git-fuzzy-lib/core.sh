#!/usr/bin/env bash

FZF_DEFAULT_OPTS=""

WIDTH="$(tput cols)"
HEIGHT="$(tput lines)"

RATIO_MATH="${WIDTH}0 / ${HEIGHT}"

RATIO="$(echo "$RATIO_MATH" | bc)"

if [ "$RATIO" -le "21" ] && [ "$HEIGHT" -ge "100" ]; then
  DEFAULT_FZF_PREVIEW_SIZE='--preview-window=down:70%'
elif [ "$RATIO" -le "21" ] && [ "$HEIGHT" -ge "70" ]; then
  DEFAULT_FZF_PREVIEW_SIZE='--preview-window=down:65%'
elif [ "$RATIO" -le "21" ]; then
  DEFAULT_FZF_PREVIEW_SIZE='--preview-window=down:60%'
elif [ "$WIDTH" -ge "250" ]; then
  DEFAULT_FZF_PREVIEW_SIZE='--preview-window=right:65%'
elif [ "$WIDTH" -ge "200" ]; then
  DEFAULT_FZF_PREVIEW_SIZE='--preview-window=right:60%'
else
  DEFAULT_FZF_PREVIEW_SIZE='--preview-window=right:55%'
fi

NO_FZF_PREVIEW="$DEFAULT_FZF_PREVIEW_SIZE:hidden"

gf_is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

gf_fzf() {
  eval "fzf --ansi --no-sort \
          $FZF_DEFAULTS_BASIC \
          $FZF_DEFAULT_OPTS_MULTI \
          $DEFAULT_FZF_PREVIEW_SIZE \
          $(quote_params "$@")"
}

gf_fzf_one() {
  eval "fzf +m --ansi --no-sort \
          $FZF_DEFAULTS_BASIC \
          $DEFAULT_FZF_PREVIEW_SIZE \
          $(quote_params "$@")"
}

gf_menu_item() {
  echo "${MAGENTA}${BOLD}${1}${NORMAL}: ${GRAY}${2}${NORMAL}"
}

gf_menu_exit() {
  gf_menu_item "quit" "exit without error"
}

gf_quit() {
  gf_log "exiting"
  exit 0
}
