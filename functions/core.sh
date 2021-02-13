#!/usr/bin/env bash

# jj - list autojump directories
if type autojump >/dev/null 2>&1; then
  if type fzf >/dev/null 2>&1; then
    jj() {
      autojump -s | cut -f2 | file-must-exist
    }
  else
    jj() {
      autojump -s
    }
  fi
fi

# portcheck - check if a port is available
portcheck() {
  if [ -z "$1" ]
  then
    echo "ERROR: specify port number."
  else
    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ; then
      echo "ERROR: argument must be a port number."
    else
      lsof -n "-i4TCP:$1" | grep LISTEN
    fi
  fi
}

# listen - check all listening ports
listen() {
  netstat -an | grep LISTEN | sort
}

# first_line [file]
first_line() {
  head -n 1
}

# last_line [file]
last_line() {
  tail -n 1
}

# lines [from] [to] - for piping only
line() {
  lines "$1" "$1"
}

# line [number] - for piping only
lines() {
  head -n "$2" | tail -n "+$1"
}

# numbers - for piping only
numbers() {
  cat -n -
}

# shuf - for piping only
shuf() {
  perl -MList::Util=shuffle -e 'print shuffle<STDIN>'
}

# horizontal rule [hr]
hr() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

WH_LS_COMMAND='ls --color=always'
WH_CAT_COMMAND='cat'

if type bat >/dev/null 2>&1; then
  WH_CAT_COMMAND='bat --color=always'
fi

if type exa >/dev/null 2>&1; then
  WH_LS_COMMAND='exa --color=always'
fi

# `which` with `ls -l $(which)`
wh() {
  if [ -z "$1" ]; then
    echo 'ERROR: specify the command.'
  else
    if [ -L "$1" ]; then
      echo "${CYAN} -- found a symlink -- ${NORMAL}"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "${GRAY}(using \`readlink-f\` to support OS X)${NORMAL}"
      fi
      indent --header 'readlink-f' "$1"
      PATH_TO_FILE="$('readlink-f' "$1")"
      wh "$PATH_TO_FILE"
    elif [ -f "$1" ]; then
      echo "${CYAN} -- found a file -- ${NORMAL}"
      # shellcheck disable=2086
      eval "indent --header $WH_LS_COMMAND -ld \"$1\""
    elif [ -d "$1" ]; then
      echo "${CYAN} -- found a directory -- ${NORMAL}"
      # shellcheck disable=2086
      eval "indent --header $WH_LS_COMMAND -ld \"$1\""
      # shellcheck disable=2086
      eval "indent --header $WH_CAT_COMMAND -l \"$1\""
    else
      indent --header which "$1"
      PATH_TO_COMMAND="$(which "$1")"
      if [ -e "$PATH_TO_COMMAND" ]; then
        wh "$PATH_TO_COMMAND"
      fi
    fi
  fi
}

if type jq >/dev/null 2>&1; then
  jqc() {
    cat - | jq -C .
  }

  jqcp() {
    cat - | jq -C . | less -REX
  }
fi
