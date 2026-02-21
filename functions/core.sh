#!/usr/bin/env bash

DOTFILES_LS_COMMAND='ls --color=always'
DOTFILES_LS_SORTED_BY_TIMESTAMP_COMMAND='ls --color=always -t'
DOTFILES_CAT_COMMAND='cat'
DOTFILES_GREP_COMMAND='grep'

if command_exists bat; then
  DOTFILES_CAT_COMMAND='bat --color=always'
fi

if command_exists eza; then
  DOTFILES_LS_COMMAND='eza --color=always'
  DOTFILES_LS_SORTED_BY_TIMESTAMP_COMMAND='eza --color=always --sort=created'
fi

if command_exists rg; then
  DOTFILES_GREP_COMMAND='rg'
fi

export DOTFILES_LS_COMMAND
export DOTFILES_LS_SORTED_BY_TIMESTAMP_COMMAND
export DOTFILES_CAT_COMMAND
export DOTFILES_GREP_COMMAND


# jj - list autojump directories
if command_exists autojump; then
  if command_exists fzf; then
    jj() {
      if command_exists eza; then
        PREVIEW="eza --sort=type --color=auto --group-directories-first --classify --time-style=long-iso --git --color-scale --long -a {1}"
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

# line [number] - for piping only
line() {
  lines "$1" "$1"
}

# lines [from] [to] - for piping only
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
      eval "indent --header $DOTFILES_LS_COMMAND -ld \"$1\""
    elif [ -d "$1" ]; then
      echo "${CYAN} -- found a directory -- ${NORMAL}"
      # shellcheck disable=2086
      eval "indent --header $DOTFILES_LS_COMMAND -ld \"$1\""
      # shellcheck disable=2086
      eval "indent --header $DOTFILES_CAT_COMMAND -l \"$1\""
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
  command_as_string="$3"

  if eval "$command_as_string"; then
    "$action" "$name success"
  else
    "$action" "$name failure"
  fi
}

scratch() {
  vim "$HOME/dev/random/scratch.$1"
}

cdd() {
  # shellcheck disable=2164
  cd "$(pwd)"
}

try() {
  if [ "$#" -lt 3 ]; then
    log_error "expect at least 2 arguments: try [until|while] <e-regex> <command>"
    return 1
  fi

  type="$1"
  shift

  local content="$1"
  shift

  local log_of_command="$(log_command "$@")"

  local command="$(printf "%q" "$1")"
  shift

  if [ "$#" -gt 0 ]; then
    command="${command} $(printf " %q" "$@")"
  fi

  while true; do
    echo "$log_of_command"
    if [ "$type" = "until" ]; then
      if eval "$command" 2>&1 | tee /dev/tty | grep -E "$content" >/dev/null; then
        break
      fi
    else
      if ! eval "$command" 2>&1 | tee /dev/tty | grep -E "$content" >/dev/null; then
        break
      fi
    fi
    echo
    sleep 0.5
  done

  return 0
}

# shellcheck disable=2155
try_until() {
  if [ "$#" -lt 2 ]; then
    log_error "expect at least 2 arguments: try_until <e-regex> <command>"
    return 1
  fi

  try 'until' "$@"
}

# shellcheck disable=2155
try_while() {
  if [ "$#" -lt 2 ]; then
    log_error "expect at least 2 arguments: try_while <e-regex> <command>"
    return 1
  fi

  try 'while' "$@"
}

mkt() {
  if [ "$#" -lt 1 ]; then
    log_error "expect at least 1 argument: mkt <file>"
    return 1
  fi

  mkdir -p "$(dirname "$1")"
  touch "$1"
}

swap() {
  if [ "$#" -ne 2 ]; then
    log_error "expect exactly 2 arguments: swap <file1> <file2>"
    return 1
  elif [ ! -w "$1" ]; then
    log_error "expect first argument to be a file: swap <file1> <file2>"
    return 1
  elif [ ! -w "$2" ]; then
    log_error "expect second argument to be a file: swap <file1> <file2>"
    return 1
  fi
  
  local temp_file="$(mktemp)"

  mv "$1" "$temp_file"
  mv "$2" "$1"
  mv "$temp_file" "$2"
  return 0
}

echo_lines() {
  if [ "$#" -eq 0 ]; then
    echo "ERROR: expect at least 1 argument"
    return 1
  fi
  for line in "$@"; do
    echo "$line"
  done
}

timestamp() {
  if [ "$1" = "-p" ] || [ "$1" = '--punctuation' ]; then
    date +%Y-%m-%dT%H:%M:%S
  else
    date +%Y%m%d%H%M%S
  fi
}

viewtf() {
  if [ "$(command ls -1 ~/Downloads/run-*)" -eq 0 ]; then
    echo "no files found matching '~/Downloads/run-*'"
  elif [ "$(command ls -1 ~/Downloads/run-*)" -eq 1 ]; then
    less -REX ~/Downloads/run-*
  else
    selections="$(eval "$DOTFILES_LS_SORTED_BY_TIMESTAMP_COMMAND -1 ~/Downloads/run-*" | \
      fzf +m \
          --ansi \
          --preview-window=wrap \
          --preview=" \
            [ -n \"{q}\" ] && ( \
              echo \"$DOTFILES_CAT_COMMAND {..} \| $DOTFILES_GREP_COMMAND {q}\" ; \
              $DOTFILES_CAT_COMMAND {..} | $DOTFILES_GREP_COMMAND {q} ; \
              true ; \
            ) || ( \
              echo \"$DOTFILES_CAT_COMMAND {..}\" ; \
              $DOTFILES_CAT_COMMAND {..} ; \
              true ; \
            )" \
          --phony \
    )"
    less -REX $selections
  fi
}

if [ -x "$CLAUDE_LOCAL_EXPECTED_LOCATION" ]; then
  export CLAUDE_PLUGINS_DIR="$HOME/dev/claude-plugins"

  claude_plugin_install() {
    if [ "$#" -ne 1 ]; then
      log_error "usage: claude_plugin_install <owner>/<repo>"
      return 1
    fi

    local repo_slug="$1"
    local repo_name="${repo_slug##*/}"

    if [ -z "$repo_name" ]; then
      log_error "could not parse repo name from '$repo_slug'"
      return 1
    fi

    local dest="$CLAUDE_PLUGINS_DIR/$repo_name"

    if [ -d "$dest" ]; then
      log_error "already exists: $dest"
      return 1
    fi

    mkdir -p "$CLAUDE_PLUGINS_DIR"
    git clone "git@github.com:${repo_slug}.git" "$dest"
  }

  claude_with_plugin() {
    if ! command_exists fzf; then
      log_error "fzf is required"
      return 1
    fi

    if [ ! -d "$CLAUDE_PLUGINS_DIR" ]; then
      log_error "no plugins directory found at $CLAUDE_PLUGINS_DIR"
      return 1
    fi

    local selected
    selected="$( \
      for repo_dir in "$CLAUDE_PLUGINS_DIR"/*/; do
        local repo_name
        repo_name="$(basename "$repo_dir")"
        if [ -d "$repo_dir/plugins" ]; then
          for plugin_dir in "$repo_dir"/plugins/*/; do
            [ -d "$plugin_dir" ] || continue
            local plugin_name
            plugin_name="$(basename "$plugin_dir")"
            printf '%s\t%s // %s\n' "$plugin_dir" "$repo_name" "$plugin_name"
          done
        elif [ -d "$repo_dir/.claude-plugin" ]; then
          printf '%s\t%s\n' "$repo_dir" "$repo_name"
        fi
      done | \
      fzf -m -d $'\t' --with-nth 2 \
          --preview="$DOTFILES_LS_COMMAND -la {1}" \
          --preview-window=wrap | \
      cut -d$'\t' -f1 \
    )"

    if [ -z "$selected" ]; then
      echo "no plugins selected"
      return 1
    fi

    local plugin_args=()
    while IFS= read -r dir; do
      # strip trailing slash
      dir="${dir%/}"
      plugin_args+=(--plugin-dir "$dir")
    done <<< "$selected"

    echo "claude ${plugin_args[*]} --dangerously-skip-permissions $*"
    claude "${plugin_args[@]}" --dangerously-skip-permissions "$@"
  }
fi # claude exists

