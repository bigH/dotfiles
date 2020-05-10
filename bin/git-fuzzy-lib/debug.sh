#!/usr/bin/env bash

gf_log_error() {
  >&2 printf "[%s%sERR%s]" "$RED" "$BOLD" "$NORMAL"
  >&2 printf " %s" "$@"
  >&2 echo
}

gf_log_debug() {
  if [ -n "$GF_DEBUG_MODE" ]; then
    >&2 printf "[%s%sDBG%s]" "$GRAY" "$BOLD" "$NORMAL"
    >&2 printf " %s" "$@"
    >&2 echo
  fi
}

# TODO make it possible to log all commands
gf_log_command() {
  if [ -n "$GF_COMMAND_DEBUG_MODE" ]; then
    if [ "$#" -gt 0 ]; then
      >&2 printf "[%s%sCMD%s]" "$GREEN" "$BOLD" "$NORMAL"
      >&2 printf '%s%s%s%s' "$GRAY" "$BOLD" ' $ ' "$NORMAL"
      >&2 printf '%s%s%s%s' "$CYAN" "$BOLD" "$(quote_single_param "$1")" "$NORMAL"
      >&2 shift
      >&2 printf '%s' "$GREEN"
      >&2 printf ' %s' "$(quote_params "$@")"
      >&2 printf '%s' "$NORMAL"
      >&2 echo
    else
      # shellcheck disable=2016
      error_exit '`gf_log_command` requires an actual command'
    fi
  fi
}

# TODO make it possible to log all commands
gf_log_internal() {
  if [ -n "$GF_INTERNAL_COMMAND_DEBUG_MODE" ]; then
    if [ "$#" -gt 0 ]; then
      >&2 printf "[%s%sCMD%s] (internal)" "$GRAY" "$BOLD" "$NORMAL"
      >&2 printf '%s%s%s%s' "$GRAY" "$BOLD" ' $ ' "$NORMAL"
      >&2 printf '%s%s%s%s' "$CYAN" "$BOLD" "$(quote_single_param "$1")" "$NORMAL"
      >&2 shift
      >&2 printf '%s' "$GREEN"
      >&2 printf ' %s' "$(quote_params "$@")"
      >&2 echo
    else
      # shellcheck disable=2016
      error_exit '`gf_log_internal` requires an actual command'
    fi
  fi
}
