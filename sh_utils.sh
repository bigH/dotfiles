#!/usr/bin/env bash

if [ -n "$AUTO_SOURCING_FILE_CHANGED" ] || [ -z "$SOURCE_SH_UTILS" ]; then
  SOURCE_SH_UTILS="YES"

  if [ -z "$SH_UTILS_LOG_MODES" ]; then
    export SH_UTILS_LOG_MODES=":INFO:WARN:ERROR:DEBUG:"
  fi

  # Defaults
  if type tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
  fi

  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    export DARK_GRAY="$(tput setaf 0)"
    export RED="$(tput setaf 1)"
    export GREEN="$(tput setaf 2)"
    export YELLOW="$(tput setaf 3)"
    export BLUE="$(tput setaf 4)"
    export MAGENTA="$(tput setaf 5)"
    export CYAN="$(tput setaf 6)"
    export WHITE="$(tput setaf 7)"
    export GRAY="$(tput setaf 8)"
    export BOLD="$(tput bold)"
    export UNDERLINE="$(tput sgr 0 1)"
    export INVERT="$(tput sgr 1 0)"
    export NORMAL="$(tput sgr0)"
  else
    export DARK_GRAY=""
    export RED=""
    export GREEN=""
    export YELLOW=""
    export BLUE=""
    export MAGENTA=""
    export CYAN=""
    export WHITE=""
    export GRAY=""
    export BOLD=""
    export UNDERLINE=""
    export INVERT=""
    export NORMAL=""
  fi

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

  # returns first param with limited quoting support
  first_param() {
    if [ -n "$1" ]; then
      echo "$1"
    fi
  }

  # logging
  log_error() {
    if [[ "$SH_UTILS_LOG_MODES" == *':ERROR:'* ]]; then
      echo "[${RED}${BOLD}ERROR${NORMAL}] $1"
    fi
  }

  log_warning() {
    if [[ "$SH_UTILS_LOG_MODES" == *':WARNING:'* ]]; then
      echo "[${YELLOW}${BOLD}WARNING${NORMAL}] $1"
    fi
  }

  log_info() {
    if [[ "$SH_UTILS_LOG_MODES" == *':INFO:'* ]]; then
      echo "[${GREEN}${BOLD}INFO${NORMAL}] $1"
    fi
  }

  log_debug() {
    if [[ "$SH_UTILS_LOG_MODES" == *':DEBUG:'* ]]; then
      echo "[${GRAY}${BOLD}DEBUG${NORMAL}] $1"
    fi
  }

  # quotes mult-word parameters in order to make a command copy-paste with ease
  quote_single_param() {
    if [ -z "$1" ] || [[ "$1" = *' '* ]]; then
      if [[ "$1" = *"'"* ]]; then
        echo "\"$1\""
      else
        echo "'$1'"
      fi
    else
      echo "$1"
    fi
  }

  # quotes a list of params using `"$@"`
  # MISSING: support for anything escapable (`\n`, `\t`, etc.?)
  # MISSING: support quotes in params (e.g. quoting `'a' "b'd"`)
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
  ensure_no_conflicting_alias_or_function() {
    if [ -z "$1" ]; then
      # shellcheck disable=2016
      log_error 'expected at least one argument for `ensure_no_conflicting_alias_or_function`'
    fi

    if typeset -f "$1" > /dev/null 2>&1; then
      # shellcheck disable=2016
      log_error '`'"$1".'` function found.'
    fi

    if alias git > /dev/null 2>&1; then
      # shellcheck disable=2016
      log_error '`'"$1".'` function found.'
    fi
  }

  log_command() {
    printf '%s%s%s%s' "$GRAY" "$BOLD" '$ ' "$NORMAL"
    printf '%s%s%s%s' "$CYAN" "$BOLD" "$(quote_single_param "$1")" "$NORMAL"
    shift
    printf '%s' "$GREEN"
    printf ' %s' "$(quote_params "$@")"
    printf '%s' "$NORMAL"
    echo
  }

  # nicely indents both stderr and stdout
  indent() {
    HEADER=""
    if [ -n "$1" ] && [ "$1" = "--header" ]; then
      shift
      HEADER="yes"
      log_command "$@"
    fi

    # TODO figure out how to capture error code
    { "$@" 2>&3 | sed >&2 's/^/    /'; } 3>&1 1>&2 | sed 's/^/    /';

    if [ -n "$HEADER" ]; then
      echo
    fi
  }

  print_symbol_for_status() {
    PRINT_PREFIX=""
    if [ $# -eq 0 ]; then
      echo ""
      echo "${RED}${BOLD}ERROR${NORMAL}: \`print_symbol_for_status\` requires 1 or 2 parameters, 0 provided"
    elif [ $# -ge 3 ]; then
      echo ""
      echo "${RED}${BOLD}ERROR${NORMAL}: \`print_symbol_for_status\` requires 1 or 2 parameters, $# provided"
    else
      if [ $# -eq 1 ]; then
        COMMAND_TO_EXECUTE="$1"
      elif [ $# -eq 2 ]; then
        PRINT_PREFIX="$1: "
        COMMAND_TO_EXECUTE="$2"
      fi

      bash -c "$COMMAND_TO_EXECUTE" > /dev/null 2>&1
      STATUS="$?"

      if [ "$STATUS" -eq 0 ]; then
        printf " [${PRINT_PREFIX}${GREEN}${BOLD}\xE2\x9C\x94${NORMAL}]"
      else
        printf " [${RED}${BOLD}${PRINT_PREFIX}\xE2\x9C\x98${NORMAL}]"
      fi
    fi
  }
fi
