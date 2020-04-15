# shellcheck disable=2016

# fzf pick a commit - see diff of just that commit
fzf_present() {
  type fzf >/dev/null 2>&1
}

alias_gh_one() {
  # shellcheck disable=2139
  # $1 = alias name
  # $2 = command (using `$COMMIT`)
  # choose commit -> `$2`
  alias "$1"="$(echo '
                COMMIT="$(gh_one)";
                test -n "${COMMIT}"
                  && '"$2"'
                  || echo "ERROR: no commit selected"
              ' | join-lines)"
}

alias_gb_gco() {
  # shellcheck disable=2139
  # $1 = alias name
  # $2 = extra `checkout` options
  # choose branch -> choose files -> `checkout $2`
  alias "$1"="$(echo '
                SOURCE_BRANCH="$(g branch | fzf +m --preview "git diff {2} | diff-so-fancy" | cut -c3-)" ;
                test -n "${SOURCE_BRANCH}"
                  && { FILES="$(gdmb "$SOURCE_BRANCH")" ;
                      test -n "${FILES}"
                        && g checkout '"$2"' "$SOURCE_BRANCH" -- $(echo $FILES | join-lines)
                        || echo "WARNING: no files selected" }
                  || echo "ERROR: no commit selected"
              ' | join-lines)"
}

if [ -z "$DISABLE_GIT_THINGS" ]; then
  # -- shared
  # NB: used by quite a few of the below aliases

  alias g=git
  alias gn='git --no-pager'
  alias gcn='git -c color.ui=always --no-pager'

  # merge-base
  alias gmb='g merge-base "$(g merge-base-absolute)"'
  alias gmbh='gmb HEAD'
  alias gmbr='gmb "$(g merge-base-remote)/$(g branch-name)"'

  # misspellings
  alias gti=g
  alias igt=g
  alias itg=g

  # commit wip
  alias wip='g commit --no-verify -a -m WIP'

  # -- shortcuts
  # clone
  alias gcl='g clone'

  # checkout
  alias gco='g checkout'
  alias gcop='g checkout --patch'
  alias gcoh='g checkout HEAD --'
  alias gcoph='g checkout --patch HEAD --'
  alias gcomb='g checkout $(gmbh) --'
  alias gcob='g checkout -b'

  # checkout defaults to use fzf for file selection
  if fzf_present; then
    alias_gb_gco gcof
    alias_gb_gco gcopf '--patch'
  fi

  # checkout

  # branch
  alias gbd='g branch -D'

  # add
  alias ga='g add'
  alias gap='g add --patch'
  alias gaa='g add .'

  # add defaults to use fzf for file selection
  if fzf_present; then
    alias gaf='g add -- $(gd)'
    alias gapf='g add --patch -- $(gd)'
  fi

  # commit
  alias gc='g commit'
  alias gca='g commit -a'
  alias gcm='g commit -m'
  alias gcam='g commit -am'
  alias gcamend='g commit --amend'
  alias gcane='g commit --amend --no-edit'
  alias gacane='g add --all ; g commit --amend --no-edit'

  # status
  alias gs='g st'
  alias gsf='g fuzzy status'

  # show
  if fzf_present; then
    alias gsh='g show $(gh_one || echo HEAD)'
  else
    alias gsh='g show'
  fi

  # stash list
  alias gsl='g stash list'
  alias gsls='g stash list --stat'
  alias gssh='g stash show --patch'
  alias gsd='g stash drop'
  alias gsa='g stash apply'
  alias gsp='g stash pop'

  # log
  alias gl='g log'
  alias gll='g log --stat'
  alias glr='g fetch "$(g merge-base-remote)" && g log "$(g merge-base-remote)/$(g branch-name)"'
  alias gllr='g log --stat "$(g merge-base-remote)/$(g branch-name)"'
  alias glm='gn log $(gmbh)..HEAD'
  alias gllm='gn log --stat $(gmbh)..HEAD'

  # pull
  alias gpo='g pull $(g merge-base-remote)'
  alias gpom='g pull $(g merge-base-remote) $(g merge-base-branch)'
  alias gprom='g pull --rebase $(g merge-base-remote) $(g merge-base-branch)'
  alias grpom='gprom'
  alias pgrom='gprom'

  # reset
  alias gr='g reset'
  alias grp='g reset --patch'
  alias grh='g reset --hard'
  alias grs='g reset --soft'

  # reset - use fzf for file selection
  if fzf_present; then
    alias grf='g reset -- $(gds)'
    alias grpf='g reset --patch -- $(gds)'
  fi

  # reset & clean
  alias grhh='indent --header git reset --hard ; indent --header git clean -df ; indent --header git status --short'

  # cherry-pick
  alias gcp='g cherry-pick'

  # rebase
  alias greb='g rebase'
  alias grc='g rebase --continue'
  alias gra='g rebase --abort'
  alias gri='g rebase --interactive'
  alias grimb='g rebase --interactive "$(gmbh)"'

  if fzf_present; then
    # assumes parent of commit because you may want to modify the commit you selected
    alias_gh_one 'grif' 'g rebase --interactive "${COMMIT}^"'
  fi
  # push
  alias gp='g push origin $(g branch-name)'
  alias gpf='g push --force-with-lease origin $(g branch-name)'
  alias gpff='g push --force origin $(g branch-name)'
  alias gpu='g push -u origin $(g branch-name)'

  # diff variants
  alias gnd='gn diff'

  if fzf_present; then
    # prefer `git fuzzy` over `diff`
    alias gd='g fuzzy diff'
    alias gdd='g diff'

    # fzf pick a commit - see its patch
    alias_gh_one 'gdc' 'gd "${COMMIT}^" "${COMMIT}"'
    alias_gh_one 'gddc' 'gdd "${COMMIT}^" "${COMMIT}"'
    alias_gh_one 'gndc' 'gnd "${COMMIT}^" "${COMMIT}"'

    # fzf pick a commit - see diff against working copy
    alias_gh_one 'gdh' 'gd "${COMMIT}"'
    alias_gh_one 'gddh' 'gdd "${COMMIT}"'
    alias_gh_one 'gndh' 'gnd "${COMMIT}"'
  else
    alias gd='g diff'
  fi

  alias gds='gd --staged'
  alias gdsh='gd HEAD^'
  alias gdmb='gd "$(gmbh)"'

  alias gnds='gnd --staged'
  alias gndsh='gnd HEAD^'
  alias gndmb='gnd "$(gmbh)"'

  if alias gdd >/dev/null 2>&1; then
    alias gdds='gdd --staged'
    alias gddsh='gdd HEAD^'
    alias gddmb='gdd "$(gmbh)"'
  fi

  # --- random higher-order things ---
  # toss the branch and make a new one
  alias gtoss='g toss-branch'

  # --- github things ---
  # this one technically clobbers gnu `pr` installed with `brew` on `macOS`
  alias gpr='g pr'

  # --- vim things ---
  # `gs` || `gdmb`
  alias vg='vim $(gfs)'
  # pick a commit then files
  alias vh='vim $(gfc $(gh_one || gmbh))'
  # watch status
  alias gsw='watch -c "git -c color.ui=always status --short"'
fi

unset -f fzf_present
unset -f alias_gh_one
unset -f alias_gb_gco
