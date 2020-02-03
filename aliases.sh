#!/usr/bin/env bash

# TODO not sure if this is a good idea?
# make it so everything works properly when switching shells
# bash='SHELL=/bin/bash bash'
# zsh='SHELL=/bin/zsh bash'

# ls override from oh-my-zsh
if type exa >/dev/null 2>&1; then
  alias ls='exa --color=auto --group-directories-first -G'
  alias ll='exa --color=auto --group-directories-first -l'
  alias la='exa --color=auto --group-directories-first -la'
elif type gls >/dev/null 2>&1; then
  alias ls='gls -p --color=auto -G --group-directories-first'
else
  alias ls='ls -p --color=auto -G --group-directories-first'
fi

if type kubectl >/dev/null 2>&1; then
  alias kc=kubectl
fi

# manipulate files verbosely (print log of what happened)
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'

# tree
alias tree='tree --dirsfirst'

# useful `kill` commands
alias k=kill
alias k9='kill -9'

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

# `docker` -> `d`
if type docker >/dev/null 2>&1; then
  alias d=docker
fi

# `docker-compose` -> `dc`
if type docker-compose >/dev/null 2>&1; then
  alias dc=docker-compose
fi

# `tldr` is like `man`
if type tldr >/dev/null 2>&1; then
  alias tldr=tldr --theme base16
fi

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
  alias gpom='g pull $(g merge-base-remote) $(g merge-base-branch)'
  alias gprom='g pull --rebase $(g merge-base-remote) $(g merge-base-branch)'

  # push
  alias gp='g push origin $(g branch-name)'
  alias gpf='g push --force origin $(g branch-name)'
  alias gpu='g push -u origin $(g branch-name)'

  # diff
  alias gd='g diff'
  alias gdm='g diff "$(g merge-base-remote)/$(g merge-base-branch)"'
  alias gnd='gn diff'
  alias gndm='gn diff "$(g merge-base-remote)/$(g merge-base-branch)"'
  alias gds='g diff --staged'
  alias gnds='gn diff --staged'

  # vim/vim-all
  alias gv='g vim'
  alias gva='g vim-all'
fi
