#!/usr/bin/env bash

# ls override from oh-my-zsh
if type exa >/dev/null 2>&1; then
  alias l='exa --color=auto --group-directories-first'
  alias ls='exa --color=auto --group-directories-first'
  alias ll='exa --color=auto --group-directories-first -l'
  alias la='exa --color=auto --group-directories-first -la'
elif type gls >/dev/null 2>&1; then
  alias ls='gls -p --color=auto -G --group-directories-first'
else
  alias ls='ls -p --color=auto -G --group-directories-first'
fi

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
  alias vim=nvim
  alias vi=nvim
  alias v=nvim
else
  alias vi=vim
  alias v=vim
fi

# chrome memory
alias chromem='ps -ev | grep -i chrome | awk '"'"'{print $12}'"'"' | paste -s -d"+" - | bc'

# go to dot files
alias jh='cd $DOT_FILES_DIR'

# `rg` - better colors
alias rg="rg -S --hidden --colors 'match:fg:white' --colors 'match:style:bold' --colors 'line:fg:blue'"

# `yarn` -> `y`
if type yarn >/dev/null 2>&1; then
  alias y=yarn
fi

# `tldr` is like `man`
if type bat >/dev/null 2>&1; then
  if type prefer-bat >/dev/null 2>&1; then
    alias cat=prefer-bat
  fi
fi

# `tldr` is like `man`
if type tldr >/dev/null 2>&1; then
  alias tldr=tldr --theme base16
fi
