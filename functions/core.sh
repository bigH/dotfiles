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
  if [ -t 1 ]; then
    LS_COMMAND='ls --color=always'
  else
    LS_COMMAND='ls'
  fi
  if [ -z "$1" ]; then
    echo 'ERROR: specify the command.'
  else
    if [ -L "$1" ]; then
      echo "${CYAN} -- found a symlink -- ${NORMAL}"
      if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "${GRAY}(using \`readlink-f\` to support OS X)${NORMAL}"
      fi
      indent --header 'readlink-f' "$1"
      echo ""
      wh "$PATH_TO_FILE"
    elif [ -f "$1" ]; then
      echo "${CYAN} -- found a file -- ${NORMAL}"
      indent --header $LS_COMMAND -ld "$1"
      echo ""
    elif [ -d "$1" ]; then
      echo "${CYAN} -- found a directory -- ${NORMAL}"
      indent --header $LS_COMMAND -ld "$1"
      echo ""
      indent --header $LS_COMMAND -l "$1"
      echo ""
    else
      indent --header which "$1"
      echo ""
      PATH_TO_COMMAND="$(which "$1")"
      if [ -e "$PATH_TO_COMMAND" ]; then
        indent wh "$PATH_TO_COMMAND"
      fi
    fi
  fi
}

