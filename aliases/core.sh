#!/usr/bin/env bash

# ls override from oh-my-zsh
if type exa >/dev/null 2>&1; then
  export EXA_DEFAULT_OPTS='--sort=type --color=auto --group-directories-first'
  export EXA_LONG_OPTS='--classify --time-style=long-iso --git --color-scale --long'

  # shellcheck disable=2139
  alias l="exa $EXA_DEFAULT_OPTS"

  # shellcheck disable=2139
  alias ls="exa $EXA_DEFAULT_OPTS"

  # shellcheck disable=2139
  alias ll="exa $EXA_DEFAULT_OPTS $EXA_LONG_OPTS"

  # shellcheck disable=2139
  alias la="exa $EXA_DEFAULT_OPTS $EXA_LONG_OPTS -a"
elif type gls >/dev/null 2>&1; then
  alias ls='gls -p --color=auto -G --group-directories-first'
else
  alias ls='ls -p --color=auto -G --group-directories-first'
fi

# common typo for me
alias kls=ls

if type fdfind >/dev/null 2>&1; then
  alias fd=fdfind
fi

alias zsh="SHELL=\"/bin/zsh\" zsh"
alias bash="SHELL=\"/bin/bash\" bash"

# NB: removed because the output can cause annoying terminal delays
# alias cp='cp -v'
# alias mv='mv -v'
# alias rm='rm -v'

# tree
alias tree='tree --dirsfirst'

# useful `kill` commands
# NB: removed because fzf will complete `kill <tab>`
# alias k=kill
# alias k9='kill -9'

# use `nvim` if present, otherwise `vim`
if type nvim >/dev/null 2>&1; then
  alias vim='nvim'
  alias vi='nvim'
  alias v='nvim'
else
  alias vi='vim'
  alias v='vim'
fi

# chrome memory
alias chromem='ps -ev | grep -i chrome | awk '"'"'{print $12}'"'"' | paste -s -d"+" - | bc'

# go to dot files
alias jh='cd $DOT_FILES_DIR'

# `yarn` -> `y`
if type yarn >/dev/null 2>&1; then
  alias y='yarn'
fi

# `tldr` is like `man`
if type bat >/dev/null 2>&1; then
  if type prefer-bat >/dev/null 2>&1; then
    alias cat='prefer-bat'
    alias ccat='command cat'
  fi
fi

# `tldr` is like `man`
if type tldr >/dev/null 2>&1; then
  alias tldr='tldr --theme base16'
fi

# `prettyping` -> `ping`
if type prettyping >/dev/null 2>&1; then
  alias ping='prettyping'
fi
