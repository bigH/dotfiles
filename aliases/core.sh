#!/usr/bin/env bash

# ls override from oh-my-zsh
if command_exists exa; then
  # want all these options to expand in alias rather than when alias is triggered
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
elif command_exists gls; then
  alias ls='gls -p --color=auto -G --group-directories-first'
else
  alias ls='ls -p --color=auto -G --group-directories-first'
fi

# common typo for me
alias kls=ls

# see config/core.sh for aliases below if they're needed (e.g. for Ubuntu)
# $ alias fd=fdfind
# $ alias bat=batcat

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
if ! command_exists nvim; then
  alias vi='vim'
  alias v='vim'
else
  alias vim='nvim'
  alias vi='nvim'
  alias v='nvim'

  # TODO get rid of these once new vim setup is done
  alias nv='nvim -u "$DOT_FILES_DIR/nvim/init.lua"'
fi

# chrome memory
# shellcheck disable=2142
alias chromem='ps -ev | grep -i chrome | awk '"'"'{print $12}'"'"' | paste -s -d"+" - | bc'

# go to dot files
alias jh='cd $DOT_FILES_DIR'

# `yarn` -> `y`
if command_exists yarn; then
  alias y='yarn'
fi

# `tldr` is like `man`
if command_exists bat; then
  if command_exists prefer-bat; then
    alias cat='prefer-bat'
    alias ccat='command cat'
  fi
fi

# `tldr` is like `man`
if command_exists tldr; then
  alias tldr='tldr --theme base16'
fi

# `prettyping` -> `ping`
if command_exists prettyping; then
  alias ping='prettyping'
fi

# `blender` cli
if [ -f '/Applications/Blender.app/Contents/MacOS/Blender' ]; then
  alias blender='/Applications/Blender.app/Contents/MacOS/Blender'
fi
