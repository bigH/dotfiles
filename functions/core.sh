#!/usr/bin/env bash

# jj - list autojump directories
if command_exists autojump; then
  if command_exists fzf; then
    jj() {
      if command_exists exa; then
        PREVIEW="exa --sort=type --color=auto --group-directories-first --classify --time-style=long-iso --git --color-scale --long -a {1}"
      else
        PREVIEW="CLICOLOR_FORCE=yes ls -GFal {1}"
      fi

      # shellcheck disable=2046
      DIRECTORY="$(\
        autojump -s | \
        cut -f2 | \
        must -e -d | \
        sed "s:\(.*\):\1\t\1:" | \
        sed "s:\t$HOME:\t~:g ; s:\t$(pwd):\t.:g ; s:\t$TMPDIR:\t\$TMPDIR/:g" | \
        fzf +m -d $'\t' --nth 2 --with-nth 2 --query="$*" --preview="$PREVIEW" --preview-window=$(fzf_sizer_preview_window_settings) | \
        cut -d$'\t' -f1 \
      )"

      if [ -d "$DIRECTORY" ]; then
        cd "$DIRECTORY" || echo "ERROR: could not \`cd\` into '$DIRECTORY'"
      else
        echo "ERROR: no directory selected"
      fi
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

if command_exists bat; then
  WH_CAT_COMMAND='bat --color=always'
fi

if command_exists exa; then
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
        indent --header readlink-f "$1"
        PATH_TO_FILE="$(readlink-f "$1")"
      else
        indent --header readlink -f "$1"
        PATH_TO_FILE="$(readlink -f "$1")"
      fi
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

if command_exists jq; then
  jqc() {
    cat - | jq -C . "$@"
  }

  jqC() {
    cat - | jq -C . "$@" | less -REX
  }

  jqp() {
    pbpaste | jq -C . "$@"
  }

  jqP() {
    pbpaste | jq -C . "$@" | less -REX
  }

  if command_exists interactively; then
    ijqp() {
      interactively --name fx 'pbpaste | jq -C {q}'
    }
  fi
fi

if command_exists fx; then
  fxp() {
    pbpaste | fx "$@"
  }

  if command_exists interactively; then
    ifxp() {
      interactively --name fx 'pbpaste | fx {q} | jq -C .'
    }
  fi
fi

mkd() {
  if [ "$#" -ne 1 ]; then
    log_error "expect exactly 1 argument - directory to create" 1>&2
    return 1
  else
    mkdir -p "$1"
    echo "$1"
    return 0
  fi
}

watch_and_print_on_change() {
  if [ "$#" -lt 1 ]; then
    log_error "expect 1 or 2 args: optional interval followed by command" 1>&2
    return 1
  else
    local command_to_run
    local started_at
    local started_at_formatted
    local date_now

    if [ "$#" -eq 1 ]; then
      command_to_run="$1"
      interval="10"
    else
      command_to_run="$2"
      interval="${1#-}"
    fi

    started_at="$(date +%s)"
    started_at_formatted="$(date)"
    date_now="$started_at"

    while true; do
      clear
      echo "${YELLOW} Started at: ${WHITE}${BOLD}${started_at_formatted}${NORMAL}"
      echo "${YELLOW}${BOLD}Current run: ${WHITE}${BOLD}$(date)${NORMAL} +$((date_now - started_at))s"
      echo "${BOLD}${CYAN}$command_to_run${NORMAL} - every ${interval}s"
      echo
      eval "$command_to_run"
      sleep "${interval}"

      # this is to make first print have a '+0s' prefix
      date_now="$(date +%s)"
    done
  fi
}

text_me() {
  message="$1"
  my_phone_number="+1 (703) 595-9345"
  osascript -e "tell application \"Messages\" to send \"$message\" to buddy \"$my_phone_number\""
}

text_me_when() {
  action_when text_me "$@"
}

say_when() {
  action_when say "$@"
}

action_when() {
  action="$1"
  name="$2"
  command="$3"

  eval "$command" && "$action" "$name success" || "$action" "$name failure"
}

