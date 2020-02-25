#!/usr/bin/env bash

FZF_HISTORY_DIR="$HOME/.local/share/fzf-history"
FZF_HISTORY_FOR_FILES="$FZF_HISTORY_DIR/sh_files"
FZF_HISTORY_FOR_DIRECTORIES="$FZF_HISTORY_DIR/sh_directories"

touch "$FZF_HISTORY_FOR_FILES"
touch "$FZF_HISTORY_FOR_DIRECTORIES"

DIRECTORY_PREVIEW_COMMAND='ls -l --color=always {}'
if type exa >/dev/null 2>&1; then
  DIRECTORY_PREVIEW_COMMAND='exa -l --color=always --git {}'
fi

FZF_DEFAULT_OPTS_MULTI='--bind alt-d:deselect-all --bind alt-a:select-all'

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
          join-lines"
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
            fzf --multi --ansi --no-height $FZF_DEFAULT_OPTS_MULTI --preview \"git diff {2}~ {2} -- $CHECK_PATHS | diff-so-fancy\" |\
            true"
    elif [ "$DIFF" = "diff" ]; then
      # For some reason, eval makes this work. otherwise, the `fzf` list never populates
      eval "git log --date=short --format=\"%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)\" --color=always -- $CHECK_PATHS |\
            fzf --multi --ansi --no-height $FZF_DEFAULT_OPTS_MULTI --preview \"git diff {2} -- $CHECK_PATHS | diff-so-fancy\" |\
            true"
    else
      # Using eval only for consistency
      eval "git log --date=short --format=\"%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)\" --color=always -- \"$CHECK_PATHS\" |\
            fzf --multi --ansi --no-height $FZF_DEFAULT_OPTS_MULTI --preview \"git show {2}:\"$CHECK_PATHS\" | bat -p --color always -l \"\${\$(basename $CHECK_PATHS)##*.}\"\" |\
            true"
    fi
  }

  # TODO fix this
  # TODO it'd be nice if this fell back on diffing with `gmbh`
  # TODO if this works the fzf config below should be everywhere (or the parts that matter)
  # Select file from git status, fall back to `gfc`
  gfs() {
    is-in-git-repo || return

    local FILES
    FILES="$(eval "git -c color.ui=always status --short | \
                   fzf --no-height --no-sort --multi --ansi --nth '2..,..' \
                       $FZF_DEFAULT_OPTS_MULTI \
                       --preview 'git diff HEAD -- {2} | diff-so-fancy' | \
                   cut -c4-")"

    if [ -z "$FILES" ]; then
      fzf-file-selector
    else
      echo $FILES
    fi
  }

  # Select file from git diff with commit (or merge-base)
  gfc() {
    is-in-git-repo || return

    MERGE_BASE=$(g merge-base "$(g merge-base-remote)/$(g merge-base-branch)" HEAD)
    REF="${1:-$MERGE_BASE}"

    eval "git diff $REF --name-only |
            fzf --no-height --reverse -m --ansi --nth '2..,..' \
                $FZF_DEFAULT_OPTS_MULTI \
                --preview \"(git diff $REF -- {-1} | diff-so-fancy)\""
  }

  # Select file from git range
  gfr() {
    is-in-git-repo || return
    test -n "$1" || return

    REF="$1"

    eval "git diff $REF --name-only |
            fzf --no-height --reverse -m --ansi --nth '2..,..' \
                $FZF_DEFAULT_OPTS_MULTI \
                --preview \"(git diff $REF -- {-1} | diff-so-fancy)\""
  }

  # Select commit from git history
  gh() {
    is-in-git-repo || return

    REF="${1:-HEAD}"
    MERGE_BASE=$(g merge-base "$(g merge-base-remote)/$(g merge-base-branch)" HEAD)

    eval "git log --date=short --format='%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)' --graph --color=always $REF |
            fzf --no-height --ansi --no-sort --reverse --multi \
                $FZF_DEFAULT_OPTS_MULTI \
                --preview 'grep -o \"[a-f0-9]\{7,\}\" <<< {} | xargs git show -p | diff-so-fancy' |
            grep -o \"[a-f0-9]\{7,\}\""
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
