#!/usr/bin/env bash

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
      printf "%s" "$(tput setaf 8)"
    fi
    printf "\$ "
    printf "%s" "$(tput setaf 2)" "$(tput bold)"
    printf "%s" "$1"
    if [ -t 1 ]; then
      printf "%s" "$(tput sgr0)" "$(tput setaf 2)"
    fi
    REST=""
    for arg in "$@"; do
      if [ -n "$REST" ]; then
        printf " %s" "$(bash_quote "$arg")"
      fi
      REST="YES"
    done
    if [ -t 1 ]; then
      printf "%s" "$(tput sgr0)"
    fi
    echo
  fi

  { "$@" 2>&3 | sed >&2 's/^/    /'; } 3>&1 1>&2 | sed 's/^/    /';
  }

