#!/usr/bin/env bash

# Defaults
if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors)
fi

if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
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

# Mispelling
export GREY="$GRAY"

# quotes mult-word parameters in order to make a command copy-paste with ease
bash_quote() {
  if [[ "$1" = *' '* ]]; then
    echo "'$1'"
  else
    echo "$1"
  fi
}

# nicely indents both stderr and stdout
indent() {
  if [ -n "$1" ] && [ "$1" = "--header" ]; then
    shift
    if [ -t 1 ]; then
      printf "%s" "$GRAY"
    fi
    printf "\$ "
    printf "%s" "$GREEN" "$BOLD"
    printf "%s" "$1"
    if [ -t 1 ]; then
      printf "%s" "$NORMAL" "$GREEN"
    fi
    REST=""
    for arg in "$@"; do
      if [ -n "$REST" ]; then
        printf " %s" "$(bash_quote "$arg")"
      fi
      REST="YES"
    done
    if [ -t 1 ]; then
      printf "%s" "$NORMAL"
    fi
    echo
  fi

  { "$@" 2>&3 | sed >&2 's/^/    /'; } 3>&1 1>&2 | sed 's/^/    /';
}

function print_symbol_for_status {
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

