#!/usr/bin/env bash
# shellcheck disable=2016

fzf_present() {
  type fzf >/dev/null 2>&1
}

alias_variants() {
  if [ "$#" = '0' ]; then
    echo '`alias_variants` expects > 0 params'
  else
    orig="$1"
    shift

    while [ "$#" -ge 2 ]; do
      suffix="$1"
      shift

      addend="$1"
      shift

      eval "alias $orig$suffix='$orig $addend'"
    done
  fi
}

## `git diff`
alias_diff_variants() {
  alias_variants "$1" \
    's' '--staged' \
    'h' 'HEAD' \
    'sh' 'HEAD^' \
    'mb' '$(gmbh)' \
    'mbh' 'HEAD $(gmbh)'
}

alias_diff_variants 'gd'
if fzf_present ; then
  gd() {
    if [ "$#" = '0' ]; then
      git fuzzy status
    else
      git fuzzy diff "$@"
    fi
  }
else
  alias gd='git diff'
fi

alias_diff_variants 'gdd'
alias gdd='git diff'

alias_diff_variants 'gnd'
alias gnd='git --no-pager diff'

unset -f alias_diff_variants

# `git show`
if fzf_present ; then
  gsh() {
    if [ "$#" = '0' ]; then
      commit="$(gh_one)"
      if [ -n "$commit" ]; then
        git fuzzy diff "$commit" "$commit^"
      else
        git fuzzy diff "HEAD" "HEAD^"
      fi
    elif [ "$#" = '1' ]; then
      git fuzzy diff "$1" "$1^"
    fi
  }
else
  alias gsh='git show'
fi

# `git rebase`
if fzf_present ; then
  gri() {
    if [ "$#" = '0' ]; then
      commit="$(gh_one)"
      if [ -n "$commit" ]; then
        git fuzzy diff "$commit" "$commit^"
      else
        git fuzzy diff "HEAD" "HEAD^"
      fi
    elif [ "$#" = '1' ]; then
      git fuzzy diff "$1" "$1^"
    fi
  }
else
  alias gri='git reset --interactive'
fi
alias grimb='gri $(gmbh)'

# `git branch`
if fzf_present ; then
  gb() {
    git fuzzy branch
  }
  alias gbd='gb'
else
  alias gb='git branch'
  alias gbd='gb --delete --force'
fi

# `git status`
if fzf_present ; then
  alias gs='git fuzzy status'
else
  alias gs='git status --short'
fi

# `git checkout`
gcob() {
  if [ "$#" = 1 ]; then
    if git rev-parse --verify "$1" > /dev/null 2>&1 ; then
      git checkout "$1"
    else
      git checkout -b "$1"
    fi
  else
    log_error 'no branch selected'
  fi
}

unset -f fzf_present
unset -f alias_variants
