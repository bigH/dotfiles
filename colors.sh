#!/bin/sh

# `zsh` color things
if [[ "$SHELL" == *'zsh' ]]; then
  autoload -U colors;
  colors
fi

# Defaults
if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors)
fi

if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  export RED="$(tput setaf 1)"
  export GREEN="$(tput setaf 2)"
  export YELLOW="$(tput setaf 3)"
  export BLUE="$(tput setaf 4)"
  export MAGENTA="$(tput setaf 5)"
  export CYAN="$(tput setaf 6)"
  export WHITE="$(tput setaf 7)"
  export GRAY="$(tput setaf 8)"
  export BOLD="$(tput bold)"
  export UNDERLINE="$(tput sgr 0 1)"
  export INVERT="$(tput sgr 1 0)"
  export NORMAL="$(tput sgr0)"
else
  export RED=""
  export GREEN=""
  export YELLOW=""
  export BLUE=""
  export MAGENTA=""
  export CYAN=""
  export WHITE=""
  export GRAY=""
  export BOLD=""
  export UNDERLINE=""
  export INVERT=""
  export NORMAL=""
fi

# Mispelling
export GREY="$GRAY"