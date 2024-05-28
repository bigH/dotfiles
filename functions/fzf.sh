#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  COMPLETEABLE_SHELL_TYPE='zsh'
elif [[ "$SHELL" == *'bash' ]]; then
  COMPLETEABLE_SHELL_TYPE='bash'
else
  COMPLETEABLE_SHELL_TYPE=''
fi

# only configure these things if you're in `bash` or `zsh`
[[ $- == *i* ]] && \
  [ -n "$COMPLETEABLE_SHELL_TYPE" ] && \
  [ -e "$HOME/.fzf.$COMPLETEABLE_SHELL_TYPE" ] && \
  source "$HOME/.fzf.$COMPLETEABLE_SHELL_TYPE" 2> /dev/null

source "$DOT_FILES_DIR/auto-sized-fzf/auto-sized-fzf.sh" 2> /dev/null

export FZF_HISTORY_DIR="$HOME/.local/share/fzf-history"
FZF_HISTORY_FOR_FILES="$FZF_HISTORY_DIR/sh_files"
FZF_HISTORY_FOR_DIRECTORIES="$FZF_HISTORY_DIR/sh_directories"
FZF_HISTORY_FOR_RIPGREP="$FZF_HISTORY_DIR/sh_ripgrep"

touch "$FZF_HISTORY_FOR_FILES"
touch "$FZF_HISTORY_FOR_DIRECTORIES"
touch "$FZF_HISTORY_FOR_DIRECTORIES"

DIRECTORY_PREVIEW_COMMAND='ls -l --color=always {}'
if command_exists eza; then
  DIRECTORY_PREVIEW_COMMAND='eza -l --color=always --git {}'
fi

build_fzf_defaults() {
  FZF_DEFAULT_OPTS="\
    $FZF_DEFAULTS_BASIC \
    --preview '[ -f {} ] && bat --style=numbers,changes --color=always {} || eza --color=always -l {}' \
    --preview-window=$(fzf_sizer_preview_window_settings)"
  # shellcheck disable=2090
  export FZF_DEFAULT_OPTS
}

fzf-directory-selector() {
  eval "fd --color=always --strip-cwd-prefix --type d --hidden --follow . | \
          fzf +m --ansi --no-height \
                 --history \"$FZF_HISTORY_FOR_DIRECTORIES\" \
                 $FZF_DEFAULT_OPTS \
                 --preview \"$DIRECTORY_PREVIEW_COMMAND\""
}

FILE_PREVIEW_COMMAND='bat {}'

fzf-file-selector() {
  eval "fd --color=always --strip-cwd-prefix --type f --hidden --follow . | \
          fzf -m --ansi --no-height \
              --history \"$FZF_HISTORY_FOR_FILES\" \
              $FZF_DEFAULT_OPTS_MULTI \
              --preview \"$FILE_PREVIEW_COMMAND\" | \
          join_lines"
}

fzf-ripgrep-selector() {
  SEARCH_PREFIX="RIPGREP_CONFIG_PATH=$RIPGREP_CONFIG_PATH $(command -v rg) --line-number --no-heading --color=always "

  # shellcheck disable=2016
  PREVIEW_COMMAND="$DOT_FILES_DIR/bin/helpers/preview-file \"\$FZF_PREVIEW_LINES\""

  RIPGREP_STORAGE="$(mktemp -t ripgrep-storage)"

  eval "echo '' | \
          fzf -m --ansi --no-height --phony \
              --history \"$FZF_HISTORY_FOR_RIPGREP\" \
              $FZF_DEFAULT_OPTS_MULTI \
              --print-query \
              --bind 'change:reload($SEARCH_PREFIX {q} 2>/dev/null || true)' \
              --preview '$PREVIEW_COMMAND {}'" > "$RIPGREP_STORAGE"

  if [ "$(wc -l "$RIPGREP_STORAGE" | awk '{ print $1 }')" -le "1" ]; then
    echo ''
  else
    FILE_NAMES="$(tail -n +2 "$RIPGREP_STORAGE" | \
                    sed -E 's/([^:]+):.*/\1/' | \
                    sort -u | \
                    sed -E "s/^(.*)$/'\\1'/" | \
                    join_lines)"

    if [ "$1" = "vim" ] || [ "$1" = "vim " ]; then
      QUERY="$(head -n1 "$RIPGREP_STORAGE")"
      CFILE="$(mktemp -t "ripgrep-fzf")"
      tail -n +2 "$RIPGREP_STORAGE" > "$CFILE"
      QUERY_ITEM="'+/$QUERY'"
      if [ "$1" = 'vim' ]; then
        QUERY_ITEM=" '+/$QUERY'"
      fi
      echo "$QUERY_ITEM '+cfile $CFILE' $FILE_NAMES"
    else
      echo "$FILE_NAMES"
    fi
  fi
}

if [ -z "$DISABLE_GIT_THINGS" ]; then
  # Create useful gitignore files
  gitignore() {
    api="curl -L -s https://www.gitignore.io/api"

    if [ $# -eq 0 ]; then
      result="$(eval "$api/list" | tr ',' '\n' | fzf --no-height --multi --preview "$api/{} | bat -p --color always -l gitignore" | paste -s -d "," -)"
      [ -n "$result" ] && eval "$api/$result"
    else
      eval "$api/$*"
    fi
  }
fi
