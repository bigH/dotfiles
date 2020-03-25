if [ -z "$DISABLE_GIT_THINGS" ]; then
  # -- shared
  # NB: used by quite a few of the below aliases

  alias g=git
  alias gn='git --no-pager'
  alias gcn='git -c color.ui=always --no-pager'

  # merge-base
  alias gmb='g merge-base "$(g merge-base-remote)/$(g merge-base-branch)"'
  alias gmbh='gmb HEAD'
  alias gmbr='gmb "$(g merge-base-remote)/$(g branch-name)"'

  # misspellings
  alias gti=g
  alias igt=g
  alias itg=g

  # commit wip
  alias wip='g commit --no-verify -a -m WIP'

  # -- shortcuts
  # checkout
  alias gco='g checkout'
  alias gcob='g checkout -b'
  alias gcomb='g checkout $(gmbh) --'

  # branch
  alias gbd='g branch -D'

  # add
  alias ga='g add'
  alias gaa='g add .'
  alias gap='g add --patch'

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
  alias gsf='g st | cut -c4-'
  alias gst='ls -t $(g st | cut -c4-)'
  alias gstr='ls -tr $(g st | cut -c4-)'

  # show
  if type fzf >/dev/null 2>&1; then
    alias gsh='g show $(gh_one)'
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

  # reset
  alias gr='g reset'
  alias grh='g reset --hard'
  alias grs='g reset --soft'

  # reset & clean
  alias grhh='g reset --hard ; g clean -df'

  # cherry-pick
  alias gcp='g cherry-pick'

  # rebase
  alias greb='g rebase'
  alias grc='g rebase --continue'
  alias gra='g rebase --abort'
  alias gri='g rebase --interactive'
  alias grif='g rebase --interactive "$(gh_one)^"'
  alias grimb='g rebase --interactive "$(gmbh)^"'

  # push
  alias gp='g push origin $(g branch-name)'
  alias gpf='g push --force origin $(g branch-name)'
  alias gpu='g push -u origin $(g branch-name)'

  # diff variants
  alias gnd='gn diff'

  if type fzf >/dev/null 2>&1; then
    # prefer `fzf-diff` over `diff`
    alias gd='g fzf-diff'
    alias gdd='g diff'

    # TODO fzf pick a branch (and optionally a base) and see diff between them

    # fzf pick a commit - see diff of just that commit
    alias gdc='COMMIT="$(gh_one)"; test -n "${COMMIT}" && gd "${COMMIT}^" "${COMMIT}" || echo "ERROR: no commit selected'
    alias gddc='COMMIT="$(gh_one)"; test -n "${COMMIT}" && gdd "${COMMIT}^" "${COMMIT}" || echo "ERROR: no commit selected'
    alias gndc='COMMIT="$(gh_one)"; test -n "${COMMIT}" && gnd "${COMMIT}^" "${COMMIT}" || echo "ERROR: no commit selected'

    # fzf pick a commit - see diff against working copy
    alias gdh='COMMIT="$(gh_one)"; test -n "${COMMIT}" && gd "${COMMIT}" || echo "ERROR: no commit selected'
    alias gddh='COMMIT="$(gh_one)"; test -n "${COMMIT}" && gdd "${COMMIT}" || echo "ERROR: no commit selected'
    alias gndh='COMMIT="$(gh_one)"; test -n "${COMMIT}" && gnd "${COMMIT}" || echo "ERROR: no commit selected'
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
  alias vh='vim $(gfc $(gh_one))'
  # pick a commit then files
  alias vh='vim $(gfc $(gh_one))'
  # watch git status
  alias gsw='watch -c "git -c color.ui=always status --short"'
fi
