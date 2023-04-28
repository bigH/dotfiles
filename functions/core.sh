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
    log_error_to_stderr "expect exactly 1 argument - directory to create"
    return 1
  else
    mkdir -p "$1"
    echo "$1"
    return 0
  fi
}

shmon_usage() {
  echo "${BOLD}A watch program that supports bash functions by running via 'eval'.${NORMAL}"
  echo
  echo "  ${GREEN}shmon ${CYAN}[options...] ${YELLOW}'<command>'${NORMAL}"
  echo
  echo "    ${CYAN}--interval=...${NORMAL}"
  echo "        Set an interval for rerunning the command - default is 2 seconds."
  echo
  echo "    ${CYAN}--stop-on-status OR --stop-on-status=<exit status>${NORMAL}"
  echo "        When provided, use exit code to determine when to stop watching. When"
  echo "        no status provided ('--stop-on-status' without '=...'), we assume a"
  echo "          status of 0."
  echo
  echo "    ${CYAN}--help${NORMAL}"
  echo "        Show help text."
  echo
  echo "${BOLD}Examples${NORMAL}:"
  echo
  echo "  ${GRAY}# run a command using eval every 2 sec with no exit criteria${NORMAL}"
  echo "  ${GREEN}shmon ${YELLOW}'cat foo.txt | awk {}'${NORMAL}"
  echo
  echo "  ${GRAY}# run a command but stop the watch once it returns 0 - usually meaning success${NORMAL}"
  echo "  ${GREEN}shmon ${CYAN}--stop-on-status ${YELLOW}'curl ...'${NORMAL}"
  echo
  echo "  ${GRAY}# run a command but stop the watch once it returns 127${NORMAL}"
  echo "  ${GREEN}shmon ${CYAN}--stop-on-status=${MAGENTA}127 ${YELLOW}'...'${NORMAL}"
  echo
  echo "  ${GRAY}# run a command every 60 seconds${NORMAL}"
  echo "  ${GREEN}shmon ${CYAN}--interval=${MAGENTA}60 ${YELLOW}'...'${NORMAL}"
  echo
  echo "  ${GRAY}# this help text${NORMAL}"
  echo "  ${GREEN}shmon ${CYAN}--help${NORMAL}"
}

# watch that runs in the current shell
# - yes, a watched command can kill your shell
# - there are a lot commands that don't have good UX
shmon() {
  local params=()
  local options=()

  local stop_on_status=
  local interval=2

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --stop-on-status=*)
        stop_on_status="$(echo "$1" | sed -E "s/.*=(.*)/\1/")"
        shift
        ;;
      --stop-on-status)
        stop_on_status=0
        shift
        ;;
      --interval=*)
        interval="$(echo "$1" | sed -E "s/.*=(.*)/\1/")"
        shift
        ;;
      --interval)
        log_error_to_stderr "'--interval' must use the form '--interval=<seconds>'"
        return 1
        ;;
      --help)
        shmon_usage
        return 1
        ;;
      -*)
        log_error_to_stderr "'shmon' doesn't support '$1'"
        return 1
        ;;
      *)
        params+=("$1")
        shift
        ;;
    esac
  done

  if [ "${#params[@]}" -lt 1 ]; then
    log_error_to_stderr "'shmon' expects a command; only switches were provided"
    return 1
  else
    local command_to_run="${params[1]}"
    params=("${params[@]:1}")

    if [ "${#params[@]}" -gt 0 ]; then
      log_warning "'shmon' will ignore everything but the first parameter"
      while [ "${#params[@]}" -gt 0 ]; do
        log_debug "- ignoring: '${params[1]}'"
        params=("${params[@]:1}")
      done
    fi

    local last_status
    local started_at
    local started_at_formatted
    local date_now

    started_at="$(date +%s)"
    started_at_formatted="$(date)"
    date_now="$started_at"

    local addendum=""
    if [ -n "$stop_on_status" ]; then
      addendum=" ${NORMAL}${GRAY}stopping on exit status ${BOLD}${stop_on_status}${NORMAL}"
    fi

    local is_first=yes
    while [ -z "$stop_on_status" ] || [ -z "$last_status" ] || [ "$last_status" != "$stop_on_status" ]; do
      if [ "$is_first" = "no" ]; then
        sleep "${interval}"
      else
        is_first=no
      fi

      clear
      echo "${MAGENTA} Started at: ${YELLOW}${BOLD}${started_at_formatted}${NORMAL}"
      echo "${MAGENTA}${BOLD}Current run: ${YELLOW}${BOLD}$(date)${GRAY} +$((date_now - started_at))s${NORMAL}"
      echo "${BOLD}${WHITE}$command_to_run${GRAY} # every ${BOLD}${interval}s${NORMAL}$addendum"
      echo
      eval "$command_to_run"
      last_status=$?

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

