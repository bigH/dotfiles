#!/usr/bin/env bash

# shellcheck disable=2016

heroku_remote() {
  git remote | grep heroku >/dev/null 2>&1
}

define_fzf_completion_for() {
  if [ "$#" -lt 2 ]; then
    log_error "expected at least 2 arguments for \`define_fzf_completion_for\`"
    return 1
  fi
  while [ "$#" -gt 1 ]; do
    # shellcheck disable=2082
    eval "_fzf_complete_$1() { eval $(printf '%q' "${$((#))}") }"
    shift
  done
}

if command_exists lazygit; then
  alias lg=lazygit
fi

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

  # print sha
  alias gsha='git rev-parse HEAD'

  # commit wip
  wip() {
    if [ $# -gt 0 ]; then
      indent --header git commit --no-verify -a -m "WIP $*"
    else
      indent --header git commit --no-verify -a -m "WIP"
    fi
  }

  unwip() {
    if ! is-in-git-repo; then
      log_error 'could not `unwip`: must be a `git` repository'
    elif [ "$(git log -1 --format='%an:%s')" != 'Hiren Hiranandani:WIP' ]; then
      log_error 'could not `unwip`: last commit is not `wip`'
    elif [ -n "$(git status -s)" ]; then
      log_error 'could not `unwip`: uncommited/unstaged changes'
    else
      indent --header git reset --soft HEAD^
    fi
  }

  # -- shortcuts
  # fuzzy
  alias gf='git fuzzy'

  # clone
  alias gcl='git clone'

  # status
  alias gs='gf status'
  alias gss='g status --short'

  # branch
  alias gb='gf branch'
  alias gbd='g branch -D'

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
    if [ "$#" -eq 1 ]; then
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
    if [ "$#" -eq 1 ]; then
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
  alias gcop='git checkout --patch'
  alias gcomb='gcof $(gmbh)'

  # commit - interactive
  alias gc='git commit'
  alias gca='git commit -a'
  alias gcamend='git commit --amend'

  # commit - non-interactive
  alias gcane='indent --header git commit --amend --no-edit'

  gcm() {
    if [ "$#" -gt 1 ]; then
      indent --header git commit -m "$*"
    elif [ "$#" -eq 1 ]; then
      indent --header git commit -m "$1"
    else
      log_error "expect arguments for commit message"
    fi
  }

  gcam() {
    if [ "$#" -gt 1 ]; then
      indent --header git commit -a -m "$*"
    elif [ "$#" -eq 1 ]; then
      indent --header git commit -a -m "$1"
    else
      log_error "expect arguments for commit message"
    fi
  }

  # add
  alias ga='indent --header git add'
  alias gaa='indent --header git add --all'
  alias gap='git add --patch'

  # stash list
  alias gfs='gf stash'
  alias gst='indent --header git stash'
  alias gsls='gst list --stat'

  gssh() {
    if [ "$#" -ge 1 ]; then
      re='^[0-9]+$'
      if [ "$#" -eq 1 ] && [[ "$1" =~ $re ]]; then
        indent --header git -c color.ui=always stash show --patch "stash@{$1}"
      else
        indent --header git -c color.ui=always stash show --patch "$@"
      fi
    else
      selection="$(git fuzzy stash)"
      if [ -n "$selection" ]; then
        indent --header git -c color.ui=always stash show --patch "${selection%%:*}"
      else
        log_error "no selection made"
      fi
    fi
  }

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

  # git fuzzy log
  alias gl='gf log'
  alias glr='indent --header git fetch "$(git merge-base-remote)" && git fuzzy log "$(git merge-base-remote)/$(git branch-name)"'
  alias glm='gl $(gmbh)..HEAD'

  # git log
  alias ggl='g log'
  alias gglr='indent --header git fetch "$(git merge-base-remote)" && git log "$(git merge-base-remote)/$(git branch-name)"'
  alias gglm='ggl $(gmbh)..HEAD'

  # log - no pager
  alias gnl='git --no-pager log'

  # merge
  alias gmm='indent --header git fetch $(git merge-base-remote) && indent --header git merge "$(git merge-base-remote)/$(git merge-base-branch)"'

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
  alias grH='gr --hard'
  alias grs='gr --soft'
  alias grsh='gr --soft HEAD^'

  grh() {
    if [ "$#" -eq 0 ]; then
      log_error 'requires parameters for safety use `grH` instead if you want to clobber working-copy'
    else
      indent --header git reset --hard "$@"
    fi
  }

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

  alias wiprom='wip &&
                gprom &&
                unwip'

  alias gacane='indent --header git add -A ;
                indent --header git commit --amend --no-edit'

  alias gcanepf='gcane; gpf'
  alias gacanepf='gaa; gcane ; gpf'

  # cherry-pick
  alias gcp='git cherry-pick'

  # rebase
  alias greb='git rebase'
  alias grc='git rebase --continue'
  alias gra='git rebase --abort'
  # some others in `functions/git.sh`

  # push
  alias gp='block-on-merge-base && indent --header git push origin $(git branch-name)'
  alias gpf='block-on-merge-base && indent --header git push --force-with-lease origin $(git branch-name)'
  alias gpff='block-on-merge-base && indent --header git push --force origin $(git branch-name)'
  alias gpu='block-on-merge-base && indent --header git push -u origin $(git branch-name)'

  gph() {
    if command_exists 'heroku'; then
      if heroku_remote; then
        git push heroku "$(git branch-name):main"
      else
        log_error '`heroku` remote not found in `git remote`; ignoring command'
      fi
    else
      log_error '`heroku` command not found; ignoring command'
    fi
  }

  # remotes
  alias grv='git remote -v'

  # --- random higher-order ---
  # toss the branch and make a new one
  alias gtoss='git toss-branch'

  # --- github ---
  # this one technically clobbers gnu `pr` installed with `brew` on `macOS`
  alias gpr='git pull-request'
  alias gfpr='gf pr'
  alias gw='git web'

  # --- watch ---
  # watch status
  alias gsw='watch -c "git -c color.ui=always status --short"'

  # --- vim ---
  vd() {
    if ! is-in-git-repo; then
      log_error 'could not `vd`: must be a `git` repository'
    else
      BASE_COMMIT="$(git merge-base "$(git merge-base-absolute)" HEAD)"
      vim $(git diff --name-only $BASE_COMMIT | xargs -1 printf '%q')
    fi
  }
fi

unset -f heroku_remote
