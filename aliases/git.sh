#!/usr/bin/env bash

# shellcheck disable=2016

# shellcheck disable=2317
heroku_remote() {
  git remote | grep heroku >/dev/null 2>&1
}

# TODO this fzf completion stuff
# define_fzf_completion_for() {
#   if [ "$#" -lt 2 ]; then
#     log_error "expected at least 2 arguments for \`define_fzf_completion_for\`"
#     return 1
#   fi
#   while [ "$#" -gt 1 ]; do
#     # shellcheck disable=2082
#     eval "_fzf_complete_$1() { eval $(printf '%q' "${$((#))}") }"
#     shift
#   done
# }

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
  # shellcheck disable=2120
  wip() {
    if [ $# -gt 0 ]; then
      indent --header git commit --no-verify -a -m "WIP: $*"
    else
      indent --header git commit --no-verify -a -m "WIP"
    fi
  }

  unwip() {
    if ! is-in-git-repo; then
      log_error 'could not `unwip`: must be a `git` repository'
    elif [[ "$(git log -1 --format='%an:%s')" != 'Hiren Hiranandani:wip'* ]] && \
         [[ "$(git log -1 --format='%an:%s')" != 'Hiren Hiranandani:WIP'* ]]; then
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
  gcl() {
    if [ "$#" -eq 0 ]; then
      log_error "gcl needs args"
    fi

    case "$1" in
      git@* | http:* | https:*)
        git clone "$@"
        ;;
      *)
        repo_path="git@github.com:$1"
        shift
        git clone "$repo_path" "$@"
        ;;
    esac
  }

  ccl() {
    if [ "$#" -eq 0 ]; then
      log_error "ccl needs 1debit repo-name only"
    fi

    (cd "$WORK_DIR_PATH" && gcl "1debit/$1")
  }

  # status
  alias gs='gf status'
  alias gss='g status --short'
  alias gcon='g status --short | grep "^UU"'

  # branch
  alias gcb='g branch-name'
  gbd() {
    if [ "$#" -gt 0 ]; then
      git branch -D "$@"
    else
      local branch="$(git fuzzy branch)"
      if [ -n "$branch" ]; then
        git branch -D "$branch"
      else
        log_error "no branch selected"
      fi
    fi
  }
  
  # shellcheck disable=2262
  alias gb='gf branch'

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

  # interactively select files in patch between $1 and merge-base to apply to working copy
  gcofmb() {
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
    if [ "$#" -gt 1 ]; then
      log_error 'could not `gcob`: >1 arguments'
    elif [ "$#" -eq 1 ]; then
      if [[ "$1" =~ ^-+$ ]]; then
        num_dashes="${#1}"
        indent --header git checkout "@{-${num_dashes}}"
      elif git rev-parse --verify "$1" > /dev/null 2>&1 ; then
        indent --header git checkout "$1"
      else
        indent --header git checkout -b "$1"
      fi
    else
      BRANCH_NAME="$(git fuzzy branch)"
      if [ -n "$BRANCH_NAME" ]; then
        indent --header git checkout "$BRANCH_NAME"
      fi
    fi
  }

  # check out specific uses
  gcop() {
    if [ "$#" -ge 1 ]; then
      git checkout --patch "$@"
    else
      git checkout --patch HEAD
    fi
  }

  # check out files as they are in merge-base (effectively undoing changes in this branch)
  alias gcomb='gcof "$(gmbh)"'

  # commit - interactive
  alias gc='git commit -v'
  alias gca='git commit -a -v'
  alias gcamend='git commit --amend -v'

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

  gcnm() {
    if [ "$#" -gt 1 ]; then
      indent --header git commit --no-verify -m "$*"
    elif [ "$#" -eq 1 ]; then
      indent --header git commit --no-verify -m "$1"
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
  alias gaa='ga --all'
  alias gaas='gaa; gs'
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
  alias gdo='g fetch ; gf diff "$(git merge-base-remote)/$(git branch-name)"'
  alias gdmb='gf diff "$(gmbh)"'
  alias glm='gl "$(gmbh)"..HEAD'

  gbdmb() {
    if [ "$#" -eq 0 ]; then
      branch="$(git fuzzy branch)"
    elif [ "$#" -eq 1 ]; then
      branch="$1"
    else
      log_error 'too many arguments provided; `gbdmb` or `gbdmb <branch>`'
    fi

    if [ -z "$branch" ]; then
      log_error 'no branch selected'
    elif git rev-parse --verify "$branch" > /dev/null 2>&1; then
      git fuzzy diff "$(git merge-base "$(git merge-base-remote)/$(git merge-base-branch)" "$branch")" "$branch"
    else
      log_error "branch '$branch' not found"
    fi
  }

  gdhh() {
    if [ "$#" -eq 0 ]; then
      gdhh 1
    elif [ "$#" -eq 1 ]; then
      # shellcheck disable=2046
      git fuzzy diff HEAD"$(printf -- '^%.0s' $(eval "echo {1..$1}"))"
    else
      log_error 'too many arguments provided; `gdhh` or `gdhh <N>`'
    fi
  }

  # original diff
  alias ggd='g diff'
  alias ggds='g diff --staged'
  alias ggdh='g diff HEAD'
  alias ggdo='g diff "$(git merge-base-remote)/$(git branch-name)"'
  alias ggdmb='g diff "$(gmbh)"'
  alias gglm='g log "$(gmbh)"..HEAD'

  ggdhh() {
    if [ "$#" -eq 0 ]; then
      ggdhh 1
    elif [ "$#" -eq 1 ]; then
      # shellcheck disable=2046
      git diff HEAD"$(printf -- '^%.0s' $(eval "echo {1..$1}"))"
    else
      log_error 'too many arguments provided; `ggdhh` or `ggdhh <N>`'
    fi
  }

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
  alias glm='gl "$(gmbh)"..HEAD'

  # git log
  alias ggl='g log'
  alias gglr='indent --header git fetch "$(git merge-base-remote)" && git log "$(git merge-base-remote)/$(git branch-name)"'
  alias gglm='ggl "$(gmbh)"..HEAD'

  # log - no pager
  alias gnl='git --no-pager log'

  # merge
  alias gm='indent --header git merge'
  alias gm-='indent --header git merge "@{-1}"'
  alias gmm='indent --header git fetch "$(git merge-base-remote)" && indent --header git merge "$(git merge-base-remote)/$(git merge-base-branch)"'

  # pull
  alias gpo='indent --header git pull "$(git merge-base-remote)" "$(git branch-name)"'
  alias gpom='indent --header git pull "$(git merge-base-remote)" "$(git merge-base-branch)"'
  alias gprom='indent --header git pull --rebase "$(git merge-base-remote)" "$(git merge-base-branch)"'
  alias gprob='indent --header git pull --rebase "$(git merge-base-remote)" "$(git branch-name)"'

  # pull - misspellings of most used ones
  alias grpom='gprom'
  alias pgrom='gprom'

  # reset
  alias gr='g reset'
  alias grp='gr --patch'
  alias grH='gr --hard'
  alias grs='gr --soft'
  alias grsh='gr --soft HEAD^'
  alias grHo='gr --hard origin/$(git branch-name)'

  grh() {
    if [ "$#" -eq 0 ]; then
      log_error 'requires parameters for safety use `grH` instead if you want to clobber working-copy'
    else
      indent --header git reset --hard "$@"
    fi
  }

  # rebase
  alias gri='git rebase --interactive --autostash'
  alias grimb='gri "$(gmbh)"'

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

  alias gacne='indent --header git add -A ;
               indent --header git commit --no-edit'

  alias gcanepf='gcane; gpf'
  alias gacanepf='gaa; gcane ; gpf'

  # cherry-pick
  gcp() {
    if [ "$#" -gt 0 ]; then
      git cherry-pick "$@"
    else
      BRANCH="$(git fuzzy branch)"
      if [ -n "$BRANCH" ]; then
        SELECTIONS="$(git fuzzy log "$BRANCH")"
        if [ -n "$SELECTIONS" ]; then
          echo "$SELECTIONS" | xargs -n 1 sh -c '
            echo git cherry-pick $0
            git cherry-pick $0 || (
              echo
              echo "ERROR: cherry-pick for $0 failed! Exiting."
              echo
              exit 255
            )
          '
        else
          log_error "expected at least one commit to be selected"
        fi
      else
        log_error "expected a branch to be selected"
      fi
    fi
  }

  # rebase
  alias greb='git rebase'
  alias grc='git rebase --continue'
  alias grcn='git -c core.editor=true rebase --continue'
  alias gra='git rebase --abort'
  # some others in `functions/git.sh`

  # push
  git_push_wrapper() {
    OPTIONS=''
    SECOND_TRY_OPTIONS=''
    if [ "$#" -gt 0 ]; then
      POSSIBLE_SWITCHES="$1"
      if [[ "$POSSIBLE_SWITCHES" =~ ^[fun]+$ ]]; then
        # remaining options are for the `push` command
        shift

        # force options
        case "$POSSIBLE_SWITCHES" in
          *ff*)
            OPTIONS="$OPTIONS -f" ;;
          *f*)
            OPTIONS="$OPTIONS --force-with-lease" ;;
        esac

        # upstream options
        case "$POSSIBLE_SWITCHES" in
          *u*)
            OPTIONS="$OPTIONS -u" ;;
        esac

        # upstream options
        case "$POSSIBLE_SWITCHES" in
          *nn*)
            OPTIONS="--no-verify $OPTIONS" ;;
          *n*)
            SECOND_TRY_OPTIONS="--no-verify $SECOND_TRY_OPTIONS" ;;
        esac
      fi
    fi
    block-on-merge-base && eval "indent --header git push origin $OPTIONS '$(git branch-name)' $(printf ' %q' "$@")"
  }
  alias gp='git_push_wrapper'
  alias gpf='git_push_wrapper f'
  alias gpu='git_push_wrapper u'

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

  # submodules
  alias gsu='indent --header git submodule status; indent --header git submodule update'

  # --- random higher-order ---
  # create a flake branch
  gflake() {
    if [ -n "$(git status --short)" ]; then
      wip 'for flake'
    fi

    indent --header git checkout "$(git merge-base-branch)"
    indent --header git pull "$(git merge-base-remote)" "$(git merge-base-branch)"

    BRANCH_NAME="hiren/fix-flake-$(date +%F)"
    while [ "$#" -gt 0 ]; do
      BRANCH_NAME="$BRANCH_NAME-${1##*/}"
      shift
    done

    if git rev-parse --verify "$BRANCH_NAME" > /dev/null 2>&1; then
      log_error "branch '$BRANCH_NAME' already exists"
    else
      gcob "$BRANCH_NAME"
    fi
  }

  # toss the branch and make a new one
  alias gtoss='git toss-branch'

  # wip / switch / unwip
  wcob() {
    wip
    if [ $# -gt 0 ]; then
      gcob "$@"
    else
      gcob
    fi
    unwip
  }

  # --- submodules
  alias gsub='indent --header git submodule update --init --recursive'

  # --- github ---
  # this one technically clobbers gnu `pr` installed with `brew` on `macOS`
  gpr() {
    if [ "$#" -eq 0 ]; then
      indent --header git pull-request
    elif [ "$#" -eq 1 ] && [[ "$1" =~ ^-+$ ]]; then
      num_dashes="${#1}"
      indent --header git pull-request "@{-${num_dashes}}"
    else
      indent --header git pull-request "$@"
    fi
  }

  alias gfpr='gf pr'
  alias gw='git web'

  # --- watch ---
  # watch status
  alias gsw='watch -c "git -c color.ui=always status --short"'

  # --- vim ---
  vmb() {
    if ! is-in-git-repo; then
      log_error 'could not `vmb`: must be a `git` repository'
    else
      BASE_COMMIT="$(git merge-base "$(git merge-base-absolute)" HEAD)"
      eval "vim $(git diff -z --name-only "$BASE_COMMIT" | xargs -0 -n1 bash -c 'printf " %q" "$0"')"
    fi
  }

  vmbb() {
    if ! is-in-git-repo; then
      log_error 'could not `vmbb`: must be a `git` repository'
    else
      BRANCH_NAME=
      if [ "$#" -gt 0 ]; then
        BRANCH_NAME="$1"
      else
        BRANCH_NAME="$(gb)"
      fi

      if ! git rev-parse --verify "$BRANCH_NAME" > /dev/null 2>&1; then
        log_error "branch '$BRANCH_NAME' not found"
      else
        BASE_COMMIT="$(git merge-base "$(git merge-base-absolute)" "$BRANCH_NAME")"
        eval "vim $(git diff -z --name-only "$BASE_COMMIT" | xargs -0 -n1 bash -c 'printf " %q" "$0"')"
      fi
    fi
  }

  vs() {
    if ! is-in-git-repo; then
      log_error 'could not `vs`: must be a `git` repository'
    else
      eval "vim $(git status --porcelain --short | cut -c4- | file-must-exist | file-per-line-as-args)"
    fi
  }

  MERGE_CONFLICT_VIM_REGEX="+/<<<<<<<\|=======\|>>>>>>>"
  MERGE_CONFLICT_IN_STATUS_REGEX='^(UU|U | U)'

  vcon() {
    if ! is-in-git-repo; then
      log_error 'could not `vcon`: must be a `git` repository'
    elif [ -z "$(git status --short)" ]; then
      log_error 'no changes in status'
    elif ! git status --short --porcelain | grep -q -E "$MERGE_CONFLICT_IN_STATUS_REGEX"; then
      log_error 'no conflicts in status'
    else
      eval "vim '$MERGE_CONFLICT_VIM_REGEX' $(git status --porcelain --short | grep -E "$MERGE_CONFLICT_IN_STATUS_REGEX" | cut -c4- | file-must-exist | file-per-line-as-args)"
    fi
  }

  vh() {
    if ! is-in-git-repo; then
      log_error 'could not `vh`: must be a `git` repository'
    else
      eval "vim $(git diff -z --name-only HEAD^ | xargs -0 -n1 bash -c 'printf " %q" "$0"')"
    fi
  }

  # shellcheck disable=2120
  vd() {
    if ! is-in-git-repo; then
      log_error 'could not `vd`: must be a `git` repository'
    elif [ "$#" -gt 0 ]; then
      eval "vim $(git diff  -z --name-only "$@" | xargs -0 -n1 bash -c 'printf " %q" "$0"')"
    elif [ -n "$(git status --short)" ]; then
      vs
    else
      vmb
    fi
  }

  # wip/switch/unwip/vd
  vcob() {
    if [ $# -gt 0 ]; then
      wcob "$@"
    else
      wcob
    fi
    vd
  }

  fixlock() {
    rm "$(git rev-parse --show-toplevel)/.git/index.lock"
  }

fi

unset -f heroku_remote
