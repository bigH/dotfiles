# shellcheck disable=2016

fzf_present() {
  type fzf >/dev/null 2>&1
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

  # commit
  alias gc='g commit'
  alias gca='g commit -a'
  alias gcm='g commit -m'
  alias gcam='g commit -am'
  alias gcamend='g commit --amend'
  alias gcane='g commit --amend --no-edit'

  # add
  alias ga='g add'
  alias gap='g add --patch'

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
  alias gprob='g pull --rebase $(g merge-base-remote) $(g branch-name)'
  # misspellings
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
  alias grhh='indent --header git status --short ; indent --header git reset --hard ; indent --header git clean -df ; indent --header git status --short'

  # ga + gcane (+ gpf)?
  alias gacane='ga --all ; gcane'
  alias gacanepf='ga --all ; gcane ; gpf'

  # cherry-pick
  alias gcp='g cherry-pick'

  # rebase
  alias greb='g rebase'
  alias grc='g rebase --continue'
  alias gra='g rebase --abort'
  # some others in `functions/git.sh`

  # push
  alias gp='g push origin $(g branch-name)'
  alias gpf='g push --force-with-lease origin $(g branch-name)'
  alias gpff='g push --force origin $(g branch-name)'
  alias gpu='g push -u origin $(g branch-name)'

  # --- random higher-order things ---
  # toss the branch and make a new one
  alias gtoss='g toss-branch'

  # --- github things ---
  # this one technically clobbers gnu `pr` installed with `brew` on `macOS`
  alias gpr='g pr'

  # --- vim things ---
  # watch status
  alias gsw='watch -c "git -c color.ui=always status --short"'

  # --- fuzzy things ---
  # `git fuzzy (status|diff|...)`
  alias gf='g fuzzy'
fi

unset -f fzf_present
