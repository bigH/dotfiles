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
  alias wip='g commit -a -m WIP'

  # -- shortcuts

  # checkout
  alias gco='g checkout'
  alias gcob='g checkout -b'
  alias gcomb='g checkout $(gmbh) --'

  # add
  alias ga='g add'
  alias gap='g add --patch'

  # commit
  alias gc='g commit'
  alias gca='g commit -a'
  alias gcm='g commit -m'
  alias gcam='g commit -am'
  alias gcamend='g commit --amend'
  alias gcane='g commit --amend --no-edit'

  # push
  alias gs='g st'
  alias gsf='g st | cut -c4-'
  alias gst='ls -t $(g st | cut -c4-)'
  alias gstr='ls -tr $(g st | cut -c4-)'

  # show
  alias gsh='g show'

  # stash list
  alias gsl='g stash list'
  alias gsls='g stash list --stat'
  alias gsd='g stash drop'

  # log
  alias gl='g log'
  alias gll='g log --stat'
  alias glm='gn log $(gmbh)..HEAD'
  alias gllm='gn log --stat $(gmbh)..HEAD'

  # pull
  alias gpo='g pull $(g merge-base-remote) $(g merge-base-branch)'
  alias gprom='g pull --rebase $(g merge-base-remote) $(g merge-base-branch)'
  alias grpom='gprom'

  # push
  alias gp='g push origin $(g branch-name)'
  alias gpf='g push --force origin $(g branch-name)'
  alias gpu='g push -u origin $(g branch-name)'

  # diff
  alias gd='g diff HEAD'
  alias gdm='g diff HEAD "$(g merge-base-remote)/$(g merge-base-branch)"'
  alias gdo='g diff HEAD "$(g merge-base-remote)/$(g branch-name)"'
  alias gnd='gn diff HEAD'
  alias gndm='gn diff HEAD "$(g merge-base-remote)/$(g merge-base-branch)"'
  alias gds='g diff --staged'
  alias gnds='gn diff --staged'

  # --- random higher-order things ---
  # toss the branch and make a new one
  alias gtoss='g toss-branch'

  # --- github things ---
  # this one technically clobbers gnu `pr` installed with `brew` on `macOS`
  alias gpr='g pr'
fi
