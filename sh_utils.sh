#!/usr/bin/env bash

command_exists() {
  [ -n "$1" ] && type "$1" >/dev/null 2>&1
}

one_command_exists() {
  if [ $# -gt 0 ]; then
    type "$1" >/dev/null 2>&1 || (shift && one_command_exists "$@")
  else
    return 1
  fi
}

is_tput_possible() {
  if ! command_exists tput; then
    return 1
  fi

  if [ -z "$TERM" ]; then
    return 2
  fi

  return 0
}

if [ -z "$SH_UTILS_LOG_MODES" ]; then
  # export SH_UTILS_LOG_MODES=":INFO:WARNING:ERROR:DEBUG:"
  export SH_UTILS_LOG_MODES=":INFO:WARNING:ERROR:"
fi

# Defaults
if is_tput_possible; then
  ncolors=$(tput colors)
fi

if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  DARK_GRAY="$(tput setaf 0)"
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  MAGENTA="$(tput setaf 5)"
  CYAN="$(tput setaf 6)"
  WHITE="$(tput setaf 7)"
  GRAY="$(tput setaf 8)"
  BOLD="$(tput bold)"
  UNDERLINE="$(tput sgr 0 1)"
  INVERT="$(tput sgr 1 0)"
  NORMAL="$(tput sgr0)"
fi

export DARK_GRAY
export RED
export GREEN
export YELLOW
export BLUE
export MAGENTA
export CYAN
export WHITE
export GRAY
export BOLD
export UNDERLINE
export INVERT
export NORMAL

# Mispellings
export DARKGRAY="$DARK_GRAY"
export DARK_GREY="$DARK_GRAY"
export DARKGREY="$DARK_GRAY"
export GREY="$GRAY"

# join lines into one, with provided separator character
# NB: assumes '%' is not present in the input
join_lines() {
  DEFAULT_SEP=' '
  SEP="${1:-$DEFAULT_SEP}"

  LENGTH_OF_SEP="${#SEP}"

  if [ "$LENGTH_OF_SEP" -eq 0 ]; then
    paste -s -d' ' -
  elif [ "$LENGTH_OF_SEP" -eq 1 ]; then
    paste -s -d"$SEP" -
  else
    paste -s -d"%" - | sed "s/%/$SEP/g"
  fi
}

file_per_line_as_args() {
  # shellcheck disable=2016
  tr '\n' '\0' | xargs -0 -n1 bash -c 'printf " %q" "$0"'
}

# returns first param with limited quoting support
first_param() {
  if [ -n "$1" ]; then
    echo "$1"
  fi
}

# logging
log_error() {
  if [[ "$SH_UTILS_LOG_MODES" == *':ERROR:'* ]]; then
    echo "[${RED}${BOLD}ERROR${NORMAL}] $*"
  fi
}

log_error_to_stderr() {
  log_error "$@" 1>&2
}

log_warning() {
  if [[ "$SH_UTILS_LOG_MODES" == *':WARNING:'* ]]; then
    echo "[${YELLOW}${BOLD}WARNING${NORMAL}] $*"
  fi
}

log_info() {
  if [[ "$SH_UTILS_LOG_MODES" == *':INFO:'* ]]; then
    echo "[${GREEN}${BOLD}INFO${NORMAL}] $*"
  fi
}

log_debug() {
  if [[ "$SH_UTILS_LOG_MODES" == *':DEBUG:'* ]]; then
    echo "[${GRAY}${BOLD}DEBUG${NORMAL}] $*"
  fi
}

# quotes mult-word parameters in order to make a command copy-paste with ease
# NB: this could be much nicer using some sort of `eval` based checking, but
# that's risky as the strings provided could be dangerous and use `$()`
quote_single_param() {
  # shellcheck disable=2116
  if [[ "$(printf '%q' "$1")" = "$(echo "$1")" ]]; then
    # quoted is same as original (means it has no special chars or spaces)
    echo "$1"
  elif [[ "$1" = *'"'* ]] && [[ "$1" != *"'"* ]]; then
    # has only double quotes
    echo "'$1'"
  elif [[ "$1" != *'"'* ]] && [[ "$1" = *"'"* ]]; then
    # has only single quotes
    echo '"'"$1"'"'
  else
    # has some mixture of quotes, so use bash quoting
    printf '%q\n' "$1"
  fi
}

# quotes a list of params using `"$@"`
quote_params() {
  REST=""
  for arg in "$@"; do
    if [ -z "$REST" ]; then
      printf "%s" "$(quote_single_param "$arg")"
      REST=true
    else
      printf " %s" "$(quote_single_param "$arg")"
    fi
  done
}

# filter out switches
remove_switches() {
  REST=""
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --*) shift ;;
      -*) shift ;;
      *)
        if [ -z "$REST" ]; then
          printf '%s' "$(quote_single_param "$1")"
          REST=true
        else
          printf ' %s' "$(quote_single_param "$1")"
        fi
        shift
        ;;
    esac
  done
}

# check for an alias/function
log_if_conflicting_alias_or_function() {
  if [ -z "$1" ]; then
    # shellcheck disable=2016
    log_error 'expected at least one argument for `log_if_conflicting_alias_or_function`'
  fi

  if typeset -f "$1" > /dev/null 2>&1; then
    # shellcheck disable=2016
    log_error '`'"$1".'` function found.'
  fi

  if alias "$1" > /dev/null 2>&1; then
    # shellcheck disable=2016
    log_error '`'"$1".'` alias found.'
  fi
}

log_command_oneline() {
  printf '%s%s%s%s' "$GRAY" "$BOLD" '$ ' "$NORMAL"
  printf '%s%s%s%s' "$CYAN" "$BOLD" "$(quote_single_param "$1")" "$NORMAL"
  shift
  printf '%s' "$GREEN"
  printf ' %s' "$(quote_params "$@")"
  printf '%s' "$NORMAL"
}

log_command() {
  log_command_oneline "$@"
  echo
}

# nicely indents both stderr and stdout
indent() {
  local header=""
  if [ -n "$1" ] && [ "$1" = "--header" ]; then
    shift
    header="yes"
    log_command "$@"
  fi

  "$@"
  local exit_code="$?"

  if [ -n "$header" ]; then
    echo
  fi

  return $exit_code
}

run_and_print_status_symbol() {
  PRINT_PREFIX=""
  if [ $# -eq 0 ]; then
    echo ""
    echo "${RED}${BOLD}ERROR${NORMAL}: \`run_and_print_status_symbol\` requires 1 or 2 parameters, 0 provided"
  elif [ $# -ge 3 ]; then
    echo ""
    echo "${RED}${BOLD}ERROR${NORMAL}: \`run_and_print_status_symbol\` requires 1 or 2 parameters, $# provided"
  else
    if [ $# -eq 1 ]; then
      COMMAND_TO_EXECUTE="$1"
    elif [ $# -eq 2 ]; then
      PRINT_PREFIX="$1"
      COMMAND_TO_EXECUTE="$2"
    fi

    bash -c "$COMMAND_TO_EXECUTE" > /dev/null 2>&1

    STATUS=$?
    print_status_symbol "$STATUS" "$PRINT_PREFIX"
    return "$STATUS"
  fi
}

silently_run_and_report() {
  PRINT_PREFIX=""
  if [ $# -eq 0 ]; then
    echo ""
    echo "${RED}${BOLD}ERROR${NORMAL}: \`silently_run_and_report\` requires an un-quoted command"
    return 0
  else
    log_command_oneline "$@"

    LOG_FILE="$(mktemp)"

    touch "$LOG_FILE"
    touch "$LOG_FILE.error"

    eval "$(printf '%q ' "$@")" > "$LOG_FILE" 2> "$LOG_FILE.error"
    STATUS="$?"

    print_status_symbol "$STATUS"
    echo

    if [ "$STATUS" -ne 0 ]; then
      echo " - \`stdout\` was preserved in '$LOG_FILE'"
      echo " - \`stderr\` was preserved in '$LOG_FILE.error'"
      return $STATUS
    else
      return 0
    fi
  fi
}

print_status_symbol() {
  PRINT_PREFIX=""
  if [ "$#" -ge 1 ]; then
    if [ "$#" -gt 1 ] && [ -n "$2" ]; then
      if [ "$1" -eq 0 ]; then
        # shellcheck disable=2059
        printf " [${GREEN}$2${NORMAL}: ${GREEN}${BOLD}\xE2\x9C\x94${NORMAL}]"
      else
        # shellcheck disable=2059
        printf " [${RED}${BOLD}$2${NORMAL}: ${RED}${BOLD}\xE2\x9C\x98${NORMAL}]"
      fi
    else
      if [ "$1" -eq 0 ]; then
        # shellcheck disable=2059
        printf " [${GREEN}${BOLD}\xE2\x9C\x94${NORMAL}]"
      else
        # shellcheck disable=2059
        printf " [${RED}${BOLD}\xE2\x9C\x98${NORMAL}]"
      fi
    fi
  else
    # shellcheck disable=2016
    log_error '`print_status_symbol` called incorrectly: no args'
  fi
}

awk_with_color_codes() {
  awk \
    -v DARK_GRAY="$DARK_GRAY" \
    -v RED="$RED" \
    -v GREEN="$GREEN" \
    -v YELLOW="$YELLOW" \
    -v BLUE="$BLUE" \
    -v MAGENTA="$MAGENTA" \
    -v CYAN="$CYAN" \
    -v WHITE="$WHITE" \
    -v GRAY="$GRAY" \
    -v BOLD="$BOLD" \
    -v UNDERLINE="$UNDERLINE" \
    -v INVERT="$INVERT" \
    -v NORMAL="$NORMAL" \
    -v DARKGRAY="$DARKGRAY" \
    -v DARK_GREY="$DARK_GREY" \
    -v DARKGREY="$DARKGREY" \
    -v GREY="$GREY" \
    "$@"
}
