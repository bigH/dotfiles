#!/usr/bin/env bash

export FZF_HISTORY_DIR="$HOME/.local/share/fzf-history"
FZF_HISTORY_FOR_FILES="$FZF_HISTORY_DIR/sh_files"
FZF_HISTORY_FOR_DIRECTORIES="$FZF_HISTORY_DIR/sh_directories"
FZF_HISTORY_FOR_RIPGREP="$FZF_HISTORY_DIR/sh_ripgrep"

touch "$FZF_HISTORY_FOR_FILES"
touch "$FZF_HISTORY_FOR_DIRECTORIES"
touch "$FZF_HISTORY_FOR_DIRECTORIES"

DIRECTORY_PREVIEW_COMMAND='ls -l --color=always {}'
if type exa >/dev/null 2>&1; then
  DIRECTORY_PREVIEW_COMMAND='exa -l --color=always --git {}'
fi

fzf-directory-selector() {
  eval "fd --type d --hidden --follow . | \
          fzf +m --ansi --no-height \
                 --history \"$FZF_HISTORY_FOR_DIRECTORIES\" \
                 $FZF_DEFAULT_OPTS \
                 --preview \"$DIRECTORY_PREVIEW_COMMAND\""
}

FILE_PREVIEW_COMMAND='bat {}'

fzf-file-selector() {
  eval "fd --type f --hidden --follow . | \
          fzf -m --ansi --no-height \
              --history \"$FZF_HISTORY_FOR_FILES\" \
              $FZF_DEFAULT_OPTS_MULTI \
              --preview \"$FILE_PREVIEW_COMMAND\" | \
          join_lines"
}

fzf-ripgrep-selector() {
  SEARCH_PREFIX="RIPGREP_CONFIG_PATH=$RIPGREP_CONFIG_PATH $(command -v rg) --line-number --no-heading --color=always "

  # shellcheck disable=2016
  PREVIEW_COMMAND="$DOT_FILES_DIR/bin/fzf-helpers/preview-file \"\$FZF_PREVIEW_LINES\""

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

if [ -z "$NON_LOCAL_ENVIRONMENT" ]; then
  # c - browse chrome history
  c() {
    local COLS SEP GOOGLE_HISTORY OPEN
    COLS=$(( COLUMNS / 3 ))
    SEP='{::}'

    if [ "$(uname)" = "Darwin" ]; then
      GOOGLE_HISTORY_DEFAULT="$HOME/Library/Application Support/Google/Chrome/Default/History"
      GOOGLE_HISTORY="${GOOGLE_CHROME_HISTORY_LOCATION:-$GOOGLE_HISTORY_DEFAULT}"
      OPEN=open
    else
      GOOGLE_HISTORY="$HOME/.config/google-chrome/Default/History"
      OPEN=xdg-open
    fi

    command cp -f "$GOOGLE_HISTORY" /tmp/h

    sqlite3 -separator $SEP /tmp/h \
      "select substr(title, 1, $COLS), url
          from urls order by last_visit_time desc" |
            awk -F $SEP '{printf "%-'$COLS's  \x1b[36m%s\x1b[m\n", $1, $2}' |
            fzf --ansi --multi | sed 's#.*\(https*://\)#\1#' | xargs $OPEN > /dev/null 2> /dev/null
  }
fi

if [ -z "$DISABLE_GIT_THINGS" ]; then
  # Create useful gitignore files
  gitignore() {
    api="curl -L -s https://www.gitignore.io/api"

    if [ $# -eq 0 ]; then
      result="$(eval "$api/list" | tr ',' '\n' | fzf --no-height --multi --preview "$api/{} | bat -p --color always -l gitignore" | paste -s -d "," -)"
      [ -n "$result" ] && eval "$api/$result"
    else
      $api/$*
    fi
  }
fi
