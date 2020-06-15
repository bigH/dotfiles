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

  # misspellings
  alias gti=git
  alias igt=git
  alias itg=git

  # commit wip
  alias wip='git commit --no-verify -a -m WIP'

  # -- shortcuts
  # fuzzy
  alias gf="git fuzzy"

  # clone
  alias gcl='git clone'

  # status
  alias gs="gf status"

  # branch
  alias gb="gf branch"

  # merge-base
  gmb() {
    if [ "$#" -gt 0 ]; then
      git merge-base "$(git merge-base-absolute)" "$1"
    else
      git merge-base "$(git merge-base-absolute)" "$(git fuzzy branch)"
    fi
  }
  alias gmbh='gmb HEAD'
  alias gmbr='gmb "$(git merge-base-remote)/$(git branch-name)"'

  # checkout
  alias gco='indent --header git checkout'

  # checkout a branch
  gcob() {
    if [ "$#" = 1 ]; then
      if git rev-parse --verify "$1" > /dev/null 2>&1 ; then
        gco "$1"
      else
        gco -b "$1"
      fi
    else
      gco "$(gb)"
    fi
  }

  # check out specific uses
  alias gcop='gco --patch '
  alias gcoh='gco HEAD --'
  alias gcoph='gco --patch HEAD --'
  alias gcomb='gco $(gmbh) --'

  # commit - interactive
  alias gc='git commit'
  alias gca='git commit -a'
  alias gcamend='git commit --amend'

  # commit - non-interactive
  alias gcm='indent --header git commit -m'
  alias gcam='indent --header git commit -a -m'
  alias gcane='indent --header git commit --amend --no-edit'

  # add
  alias ga='git add'
  alias gap='git add --patch'

  # stash list
  alias gst='indent --header git stash'
  alias gsls='gst list --stat'
  alias gssh='gst show --patch'
  alias gsd='gst drop'
  alias gsa='gst apply'
  alias gsp='gst pop'

  # diff
  alias gd='gf diff'
  alias gds='gf diff --staged'
  alias gdh='gf diff HEAD'
  alias gdmb='gf diff $(gmbh)'
  alias glm='gl $(gmbh)..HEAD'

  # original diff
  alias gdd='g diff'

  # show
  gsh() {
    if [ "$#" = 0 ]; then
      gf diff HEAD^ HEAD
    elif [ "$#" = 1 ]; then
      gf diff "$1^" "$1"
    else
      >&2 echo 'ERROR: `gsh` only supports 0 args or 1 arg (a commit)'
    fi
  }

  # log
  alias gl='gf log'
  alias glr='git fetch "$(git merge-base-remote)" && gl "$(git merge-base-remote)/$(git branch-name)"'
  alias glm='gl $(gmbh)..HEAD'

  # log - no pager
  alias gnl='git --no-pager log'

  # pull
  alias gpo='indent --header git pull $(git merge-base-remote)'
  alias gpom='indent --header git pull $(git merge-base-remote) $(git merge-base-branch)'
  alias gprom='indent --header git pull --rebase $(git merge-base-remote) $(git merge-base-branch)'
  alias gprob='indent --header git pull --rebase $(git merge-base-remote) $(git branch-name)'

  # pull - misspellings
  alias grpom='gprom'
  alias pgrom='gprom'

  # reset
  alias gr='git reset'
  alias grp='git reset --patch'
  alias grh='git reset --hard'
  alias grs='git reset --soft'

  # combined actions
  alias grhh='indent --header git status --short ;
              indent --header git reset --hard ;
              indent --header git clean -df ;
              indent --header git status --short'

  alias gacane='indent --header git add -A ;
                indent --header git commit --amend --no-edit'

  alias gacanepf='gacane ; gpf'

  # cherry-pick
  alias gcp='git cherry-pick'

  # rebase
  alias greb='git rebase'
  alias grc='git rebase --continue'
  alias gra='git rebase --abort'
  # some others in `functions/git.sh`

  # push
  alias gp='indent --header git push origin $(git branch-name)'
  alias gpf='indent --header git push --force-with-lease origin $(git branch-name)'
  alias gpff='indent --header git push --force origin $(git branch-name)'
  alias gpu='indent --header git push -u origin $(git branch-name)'

  # --- random higher-order things ---
  # toss the branch and make a new one
  alias gtoss='git toss-branch'

  # --- github things ---
  # this one technically clobbers gnu `pr` installed with `brew` on `macOS`
  alias gpr='git pull-request'
  alias gprl='gf pr'

  # --- vim things ---
  # watch status
  alias gsw='watch -c "git -c color.ui=always status --short"'
fi

unset -f fzf_present
