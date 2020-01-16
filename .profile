#!/usr/bin/env bash

export DOT_FILES_DIR=$HOME/.hiren

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"

if type nvim >/dev/null 2>&1; then
  export EDITOR="$(which nvim)"
else
  export EDITOR="$(which vim)"
fi

source "$DOT_FILES_DIR/colors.sh"

source "$DOT_FILES_DIR/configs/all.sh"

if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -d "$DOT_FILES_DIR/$DOT_FILES_ENV/bin" ]; then
    export PATH="$DOT_FILES_DIR/$DOT_FILES_ENV/bin:$PATH"
  fi
fi

# potentially migrate to similar approach to configs
source "$DOT_FILES_DIR/aliases.sh"
if [ ! -z "$DOT_FILES_ENV" ]; then
  if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/aliases.sh" ]; then
    source "$DOT_FILES_DIR/$DOT_FILES_ENV/aliases.sh"
  fi
fi

source "$DOT_FILES_DIR/functions/all.sh"

if [[ "$SHELL" == *'zsh' ]]; then
  source "$DOT_FILES_DIR/.zsh.bindings"
fi

if [[ "$SHELL" == *'zsh' ]]; then
  source "$DOT_FILES_DIR/.zsh_prompt"
  source "$DOT_FILES_DIR/.shell.zsh"
elif [[ "$SHELL" == *'bash' ]]; then
  source "$DOT_FILES_DIR/.bash_prompt"
  source "$DOT_FILES_DIR/.shell.bash"
fi
