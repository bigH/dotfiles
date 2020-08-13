#!/usr/bin/env bash

export DOT_FILES_DIR="$HOME/.hiren"

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/env-context)"

if type nvim >/dev/null 2>&1; then
  export EDITOR="$(which nvim)"
else
  export EDITOR="$(which vim)"
fi

# basics with no dependencies
# NB: technically doesn't support auto_source
auto_source "$DOT_FILES_DIR/sh_utils.sh"

# configs/path (almost everything below needs them to work)
auto_source "$DOT_FILES_DIR/configs/all.sh"

if [ -n "$DOT_FILES_ENV" ]; then
  if [ -d "$DOT_FILES_DIR/$DOT_FILES_ENV/bin" ]; then
    export PATH="$DOT_FILES_DIR/$DOT_FILES_ENV/bin:$PATH"
  fi
fi

# NB: may require `bin` and things from `configs`
auto_source "$DOT_FILES_DIR/functions/all.sh"
auto_source "$DOT_FILES_DIR/aliases/all.sh"

if [[ "$SHELL" == *'zsh' ]]; then
  auto_source "$DOT_FILES_DIR/zsh-bindings.sh"
  auto_source "$DOT_FILES_DIR/zsh-prompt.sh"
  auto_source "$DOT_FILES_DIR/zsh-shell.sh"
elif [[ "$SHELL" == *'bash' ]]; then
  auto_source "$DOT_FILES_DIR/bash-prompt.sh"
  auto_source "$DOT_FILES_DIR/bash-shell.sh"
fi

auto_source_initialize
