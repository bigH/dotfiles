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
      lsof -n -i4TCP:$1 | grep LISTEN
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
  lines $1 $1
}

# line [number] - for piping only
lines() {
  head -n $2 | tail -n +$1
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
      if [ "$#" -eq 0 ]; then
        perl -ne 'print ((0 == $. % '"$NUM"') ? $_ : "")'
      else
        while [ "$#" -ne 0 ]; do
          perl -ne 'print ((0 == $. % '"$NUM"') ? $_ : "")' $1
          shift
        done
      fi
    fi
  fi
}

# a
a() {
  is-in-git-repo && g st || ll
}

# horizontal rule [hr]
hr() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# join lines into one, with provided separator character
join-lines() {
  SEP="$1"

  # length includes new-line so off-by-one
  LENGTH_OF_SEP="$(echo "$SEP" | wc -c)"

  if [ $LENGTH_OF_SEP -eq 1 ]; then
    paste -s -d' ' -
  elif [ $LENGTH_OF_SEP -eq 2 ]; then
    paste -s -d"$SEP" -
  else
    paste -s -d"%" - | sed "s/%/$SEP/g"
  fi
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
      echo "${MAGENTA}readlink -f '$1'${NORMAL}:"
      echo ""
      PATH_TO_FILE="$(readlink-f "$1")"
      "$DOT_FILES_DIR/bin/indent" echo "$PATH_TO_FILE"
      echo ""
      wh "$PATH_TO_FILE"
    elif [ -f "$1" ]; then
      echo "${CYAN} -- found a file -- ${NORMAL}"
      echo "${MAGENTA}ls -l '$1'${NORMAL}:"
      echo ""
      "$DOT_FILES_DIR/bin/indent" ls -l "$1"
    elif [ -d "$1" ]; then
      echo "${CYAN} -- found a directory -- ${NORMAL}"
      echo "${MAGENTA}ls -ld '$1'${NORMAL}:"
      echo ""
      "$DOT_FILES_DIR/bin/indent" ls -ld "$1"
      echo ""
      echo "${GRAY}(directory listing)${NORMAL}"
      echo "${MAGENTA}ls '$1'${NORMAL}:"
      echo ""
      ls "$1"
    else
      echo "${MAGENTA}which '$1'${NORMAL}:"
      "$DOT_FILES_DIR/bin/indent" "which" "$1"
      PATH_TO_COMMAND="$(which "$1")"
      if [ -e "$PATH_TO_COMMAND" ]; then
        echo ""
        wh "$PATH_TO_COMMAND"
      fi
    fi
  fi
}

