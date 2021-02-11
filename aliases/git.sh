#!/usr/bin/env bash

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
  alias gbd="g branch -D"

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

  # checkout files "safely" aborts if no filenames provided (useful for command substitution)
  gcof() {
    FILES=""
    for arg in "$@"; do
      if [ -n "$FILES" ]; then
        ((FILES+=1))
      fi
      if [ "$arg" = "--" ]; then
        FILES=0
      fi
    done

    if [ -n "$FILES" ] && [ "$FILES" -gt 0 ]; then
      git checkout "$@"
    else
      log_warning "no files selected; using diff to select files"
      IFS=$'\r\n' eval 'FILES=($(git fuzzy diff "$@"))'
      if [ "${#FILES[@]}" -gt 0 ]; then
        gcof "$@" -- "${FILES[@]}"
      else
        log_error "no files selected; aborting"
      fi
    fi
  }

  # interactively select files in patch (against merge base) to apply
  gabmb() {
    if [ "$#" = 1 ]; then
      MERGE_BASE="$(git merge-base "$1" "$(git merge-base-remote)/$(git merge-base-branch)")"
      IFS=$'\r\n' eval 'FILES=($(git fuzzy diff "$MERGE_BASE" "$1"))'
      if [ "${#FILES[@]}" -gt 0 ]; then
        git apply <(git diff "$MERGE_BASE" "$1" -- "${FILES[@]}")
      else
        log_error "no files selected; aborting"
      fi
    else
      log_error "no commit or branch provided; aborting"
    fi
  }

  # checkout a branch or commit
  gcob() {
    if [ "$#" = 1 ]; then
      if git rev-parse --verify "$1" > /dev/null 2>&1 ; then
        indent --header git checkout "$1"
      else
        indent --header git checkout -b "$1"
      fi
    else
      BRANCH_NAME="$(gb)"
      if [ -n "$BRANCH_NAME" ]; then
        indent --header git checkout "$BRANCH_NAME"
      fi
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
  alias gaa='git add --all'
  alias gap='git add --patch'

  # stash list
  alias gfs='gf stash'
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
  alias gdo='gf diff "$(git merge-base-remote)/$(git branch-name)"'
  alias gdmb='gf diff $(gmbh)'
  alias glm='gl $(gmbh)..HEAD'

  # original diff
  alias ggd='g diff'
  alias ggds='g diff --staged'
  alias ggdh='g diff HEAD'
  alias ggdo='g diff "$(git merge-base-remote)/$(git branch-name)"'
  alias ggdmb='g diff $(gmbh)'
  alias gglm='g log $(gmbh)..HEAD'

  # show
  gsh() {
    if [ "$#" = 0 ]; then
      git fuzzy diff HEAD^ HEAD
    elif [ "$#" = 1 ]; then
      git fuzzy diff "$1^" "$1"
    else
      >&2 echo 'ERROR: `gsh` only supports 0 args or 1 arg (a commit)'
    fi
  }

  # original show
  alias ggsh='git show'

  # log
  alias gl='gf log'
  alias glr='git fetch "$(git merge-base-remote)" && gl "$(git merge-base-remote)/$(git branch-name)"'
  alias glm='gl $(gmbh)..HEAD'
  alias ggl='g log'
  alias gglr='git fetch "$(git merge-base-remote)" && ggl "$(git merge-base-remote)/$(git branch-name)"'
  alias gglm='ggl $(gmbh)..HEAD'

  # log - no pager
  alias gnl='git --no-pager log'

  # pull
  alias gpo='indent --header git pull $(git merge-base-remote)'
  alias gpom='indent --header git pull $(git merge-base-remote) $(git merge-base-branch)'
  alias gprom='indent --header git pull --rebase $(git merge-base-remote) $(git merge-base-branch)'
  alias gprob='indent --header git pull --rebase $(git merge-base-remote) $(git branch-name)'

  # pull - misspellings of most used ones
  alias grpom='gprom'
  alias pgrom='gprom'

  # reset
  alias gr='g reset'
  alias grp='gr --patch'
  alias grh='gr --hard'
  alias grs='gr --soft'

  # rebase
  alias gri='git rebase --interactive'
  alias grimb='gri $(gmbh)'

  grif() {
    COMMIT="$(git fuzzy log)"
    if [ -n "$COMMIT" ]; then
      git rebase --interactive "$COMMIT"
    fi
  }

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
