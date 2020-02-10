#!/usr/bin/env bash

## FZF Helpers

# fzfe - echo's to stderr all files selected
fzfe() {
  fzf "$@" | tee /dev/stderr
}

## CD

# fcd - including hidden directories
fcd() {
  local DIR
  DIR=$(find ${1:-.} -type d 2> /dev/null | fzf +m --preview="ls -l {}") &&
    echo cd "$DIR" &&
    cd "$DIR"
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
  # View the history of a file interactively [-d|--diff] for diff only
  ghist() {
    is-in-git-repo || return

    DIFF=no
    CHECK_PATHS="$@"
    if [ "$1" = "-p" ] || [ "$1" = "--patch" ]; then
      DIFF=patch
      shift
      CHECK_PATHS="$@"
    elif [ "$1" = "-d" ] || [ "$1" = "--diff" ]; then
      DIFF=diff
      shift
      CHECK_PATHS="$@"
    fi

    if [ "$DIFF" = "patch" ]; then
      # For some reason, eval makes this work. otherwise, the `fzf` list never populates
      eval "git log --date=short --format=\"%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)\" --color=always -- $CHECK_PATHS |\
        fzf --multi --ansi --no-height --preview \"git diff {2}~ {2} -- $CHECK_PATHS | diff-so-fancy\" |\
        true"
    elif [ "$DIFF" = "diff" ]; then
      # For some reason, eval makes this work. otherwise, the `fzf` list never populates
      eval "git log --date=short --format=\"%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)\" --color=always -- $CHECK_PATHS |\
            fzf --multi --ansi --no-height --preview \"git diff {2} -- $CHECK_PATHS | diff-so-fancy\" |\
            true"
    else
      # Using eval only for consistency
      eval "git log --date=short --format=\"%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)\" --color=always -- \"$CHECK_PATHS\" |\
            fzf --multi --ansi --no-height --preview \"git show {2}:\"$CHECK_PATHS\" | bat -p --color always -l \"\${\$(basename $CHECK_PATHS)##*.}\"\" |\
            true"
    fi
  }

  # Select file from git status
  gfi() {
    is-in-git-repo || return

    MERGE_BASE=$(g merge-base "$(g merge-base-remote)/$(g merge-base-branch)" HEAD)
    REF="${1:-$MERGE_BASE}"

    git diff $REF --name-only |
    fzf --no-height --reverse -m --ansi --nth 2..,.. \
      --preview "(git diff $REF -- {-1} | diff-so-fancy)"
  }

  # Select commit from git history
  gh() {
    is-in-git-repo || return

    REF="${1:-HEAD}"
    MERGE_BASE=$(g merge-base "$(g merge-base-remote)/$(g merge-base-branch)" HEAD)

    git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always $REF |
    fzf --no-height --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
      --header 'Press CTRL-S to toggle sort' \
      --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show -p | diff-so-fancy' |
    grep -o "[a-f0-9]\{7,\}"
  }

  # Create useful gitignore files
  gitignore() {
    api="curl -L -s https://www.gitignore.io/api"

    if [ "$#" -eq 0 ]; then
      result="$(eval "$api/list" | tr ',' '\n' | fzf --no-height --reverse --multi --preview "$api/{} | bat -p --color always -l gitignore" | paste -s -d "," -)"
      [ -n "$result" ] && eval "$api/$result"
    else
      $api/$*
    fi
  }
fi
