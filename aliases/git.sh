if [ -z "$DISABLE_GIT_THINGS" ]; then
  alias g=git
  alias gn='git --no-pager'

  # merge-base
  alias gmb='g merge-base "$(g merge-base-remote)/$(g merge-base-branch)"'
  alias gmbh='gmb HEAD'

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
  alias gsh='g show'

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

  # reset
  alias greb='g rebase'
  alias grc='g rebase --continue'
  alias gra='g rebase --abort'
  alias gri='g rebase --interactive'
  alias grif='g rebase --interactive "$(gh_one)^"'

  # push
  alias gp='g push origin $(g branch-name)'
  alias gpf='g push --force origin $(g branch-name)'
  alias gpu='g push -u origin $(g branch-name)'

  if type fzf >/dev/null 2>&1; then
    # prefer `fzf-diff` over `diff`
    alias gd='g fzf-diff'
    alias gds='g fzf-diff --staged'
    alias gdsh='g fzf-diff HEAD^'
    alias gdmb='g fzf-diff "$(gmbh)"'
    alias gdh='g fzf-diff "$(gh_one)"'

    alias gdd='g diff'
    alias gdds='g diff --staged'
    alias gddsh='g diff HEAD^'
    alias gddmb='g diff "$(gmbh)"'
    alias gddh='g diff "$(gh_one)"'
  else
    alias gd='g diff'
    alias gds='g diff --staged'
    alias gdsh='g diff HEAD^'
    alias gdmb='g diff "$(gmbh)"'
    alias gdh='g diff "$(gh_one)"'
  fi

  alias gnd='gn diff'
  alias gnds='gn diff --staged'
  alias gndsh='gn diff HEAD^'
  alias gndmb='gn diff "$(gmbh)"'
  alias gndh='gn diff "$(gh_one)"'

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
fi
