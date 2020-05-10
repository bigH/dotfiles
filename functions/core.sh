#!/usr/bin/env bash

# jj - list autojump directories
if type autojump >/dev/null 2>&1; then
  jj() {
    autojump -s
  }
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

# every
every () {
  if [ -z "$1" ]; then
    # shellcheck disable=2016
    echo 'ERROR: specify the `n` in `nth`.'
    exit 1
  else
    re='^[0-9]+$'
    if ! [[ $1 =~ $re ]] ; then
      echo 'ERROR: argument must be a number.'
      exit 2
    else
      NUM=$1
      shift
      if [ $# -eq 0 ]; then
        perl -ne 'print ((0 == $. % '"$NUM"') ? $_ : "")'
      else
        while [ $# -ne 0 ]; do
          perl -ne 'print ((0 == $. % '"$NUM"') ? $_ : "")' "$1"
          shift
        done
      fi
    fi
  fi
}

# horizontal rule [hr]
hr() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

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
      indent --header ls -ld "$1"
    elif [ -d "$1" ]; then
      echo "${CYAN} -- found a directory -- ${NORMAL}"
      indent --header ls -ld "$1"
      indent --header ls -l "$1"
    else
      indent --header which "$1"
      PATH_TO_COMMAND="$(which "$1")"
      if [ -e "$PATH_TO_COMMAND" ]; then
        wh "$PATH_TO_COMMAND"
      fi
    fi
  fi
}


if type displayplacer >/dev/null 2>&1; then
  home-desk() {
    displayplacer "id:D5A39D6E-30E2-D1AB-B31A-5E31ACBD7D25 res:2560x1440 hz:60 color_depth:8 scaling:on origin:(0,0) degree:0" "id:02CFC729-D850-0CD0-0951-2778E645261C res:1080x1920 hz:60 color_depth:8 scaling:off origin:(2560,-204) degree:270" "id:DA616E30-0BB3-172D-A6C5-0222DA352979 res:1080x1920 hz:60 color_depth:8 scaling:off origin:(-1080,-225) degree:90"
  }
fi
