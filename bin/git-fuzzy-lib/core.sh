#!/usr/bin/env bash

export FZF_DEFAULT_OPTS="\
  --border \
  --layout=reverse \
  --bind 'ctrl-space:toggle-preview' \
  --bind 'ctrl-d:half-page-down' \
  --bind 'ctrl-u:half-page-up' \
  --bind 'ctrl-s:toggle-sort' \
  --bind 'ctrl-e:preview-down' \
  --bind 'ctrl-y:preview-up' \
  --bind 'change:top' \
  --no-height"

# shellcheck disable=2034
GF_BASE_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"

preview_window_settings() {
  WIDTH="$(tput cols)"
  HEIGHT="$(tput lines)"

  # NB: scaling this up so integer math is fine
  RATIO_MATH="${WIDTH}0 / ${HEIGHT}"

  RATIO="$(echo "$RATIO_MATH" | bc)"

  if [ "$RATIO" -le "21" ] && [ "$HEIGHT" -ge "100" ]; then
    echo '--preview-window=down:70%'
  elif [ "$RATIO" -le "21" ] && [ "$HEIGHT" -ge "70" ]; then
    echo '--preview-window=down:65%'
  elif [ "$RATIO" -le "21" ]; then
    echo '--preview-window=down:60%'
  elif [ "$WIDTH" -ge "250" ]; then
    echo '--preview-window=right:65%'
  elif [ "$WIDTH" -ge "200" ]; then
    echo '--preview-window=right:60%'
  else
    echo '--preview-window=right:55%'
  fi
}

hidden_preview_window_settings() {
  echo "$(preview_window_settings):hidden"
}

gf_is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

gf_command_logged() {
  gf_log_command "$@"
  if [ -n "$GF_COMMAND_LOG_OUTPUT" ]; then
    "$@" 1>&2
  else
    "$@" >/dev/null 2>&1
  fi
}

gf_fzf() {
  eval "fzf --ansi --no-sort \
          $FZF_DEFAULT_OPTS_MULTI \
          $(preview_window_settings) \
          $(quote_params "$@")"
}

gf_fzf_one() {
  eval "fzf +m --ansi --no-sort \
          $(preview_window_settings) \
          $(quote_params "$@")"
}

gf_menu_item() {
  printf '%s%s%-10s%s %s%s%s' "$MAGENTA" "$BOLD" "$1" "$NORMAL" "$GRAY" "$2" "$NORMAL"
  echo
}

gf_menu_header() {
  printf '%s%s%s%s' "$CYAN" "$BOLD" "$1" "$NORMAL"
  echo
}

gf_command_with_header() {
  printf "%s" "$GRAY" "$BOLD" '$ ' "$CYAN" "$BOLD"
  # shellcheck disable=2046
  printf "%s " $(quote_params "$@")
  printf "%s" "$NORMAL"
  echo
  echo
  "$@"
}

gf_quit() {
  gf_log_debug "exiting"
  exit 0
}
