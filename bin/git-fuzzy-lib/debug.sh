#!/usr/bin/env bash

gf_log() {
  if [ -n "$DEBUG_MODE" ]; then
    >&2 printf "[%s%sDEBUG%s]" "$GRAY" "$BOLD" "$NORMAL"
    >&2 printf " %s" "$@"
    >&2 echo
  fi
}

gf_log_error() {
  if [ -n "$DEBUG_MODE" ]; then
    >&2 printf "[%s%sERROR%s]" "$RED" "$BOLD" "$NORMAL"
    >&2 printf " %s" "$@"
    >&2 echo
  fi
}

# TODO make it possible to log all commands
gf_command_log() {
  if [ -n "$COMMAND_DEBUG_MODE" ]; then
    >&2 printf '%s%s%s%s' "$GRAY" "$BOLD" '$ ' "$NORMAL"
    >&2 printf '%s%s%s%s' "$CYAN" "$BOLD" "$(quote_single_param "$1")" "$NORMAL"
    >&2 shift
    >&2 printf '%s' "$GREEN"
    >&2 printf ' %s' "$(quote_params "$@")"
    >&2 printf '%s' "$NORMAL"
    >&2 echo
  fi
}

# NB: only logs if debug is turned on
gf_log "${BOLD}DEBUG${NORMAL} enabled"
