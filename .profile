#!/usr/bin/env bash

export DOT_FILES_DIR=$HOME/.hiren

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"

source $DOT_FILES_DIR/.colors

if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/.$DOT_FILES_ENV.profile" ]; then
    source $DOT_FILES_DIR/.$DOT_FILES_ENV.profile
  fi
fi

source $DOT_FILES_DIR/.local.configs

if [[ "$SHELL" == *'zsh' ]]; then
  source $DOT_FILES_DIR/.shell.zsh
elif [[ "$SHELL" == *'bash' ]]; then
  source $DOT_FILES_DIR/.shell.bash
fi

if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/.$DOT_FILES_ENV.configs" ]; then
    source $DOT_FILES_DIR/.$DOT_FILES_ENV.configs
  fi
else
  source $DOT_FILES_DIR/.default.configs
fi

source $DOT_FILES_DIR/.aliases
if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/.$DOT_FILES_ENV.aliases" ]; then
    source $DOT_FILES_DIR/.$DOT_FILES_ENV.aliases
  fi
fi

source $DOT_FILES_DIR/.functions

source $DOT_FILES_DIR/.rg.functions

source $DOT_FILES_DIR/.fzf.configs
source $DOT_FILES_DIR/.fzf.functions
if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/.$DOT_FILES_ENV.functions" ]; then
    source $DOT_FILES_DIR/.$DOT_FILES_ENV.functions
  fi
fi
if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/.$DOT_FILES_ENV.ctags.functions" ]; then
    source $DOT_FILES_DIR/.$DOT_FILES_ENV.ctags.functions
  fi
fi
source $DOT_FILES_DIR/.ctags.configs

if [[ "$SHELL" == *'zsh' ]]; then
  source $DOT_FILES_DIR/.zsh.bindings
fi

if [[ "$SHELL" == *'zsh' ]]; then
  source $DOT_FILES_DIR/.zsh_prompt
elif [[ "$SHELL" == *'bash' ]]; then
  source $DOT_FILES_DIR/.bash_prompt
fi
