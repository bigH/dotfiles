#!/usr/bin/env bash

# turn off certain `shellcheck` errors
export SHELLCHECK_OPTS="-e SC1090"

# Add Haskell configs
if [ -e $HOME/.ghcup/env ]; then
  auto_source $HOME/.ghcup/env
elif [ -d "$HOME/.cabal/bin" ]; then
  export PATH="$HOME/.cabal/bin:$PATH"
fi

# Add go `bin`
if [ -d "$HOME/go/bin" ]; then
  export PATH="$HOME/go/bin:$PATH"
fi

# Add Home `bin`
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

# Turn RUST_BACKTRACE on
export RUST_BACKTRACE=1

# Setup `dircolors`
# `dircolors` isn't on the path
if [ -e "/usr/local/opt/coreutils/libexec/gnubin/dircolors" ]; then
  eval `/usr/local/opt/coreutils/libexec/gnubin/dircolors $DOT_FILES_DIR/gruvbox.dircolors`
fi

# Add `linuxbrew` to path if present
if [ -d '/home/linuxbrew/.linuxbrew/bin' ]; then
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
fi

# Add `bison`
if [ -d '/usr/local/opt/bison/bin' ]; then
  export PATH="/usr/local/opt/bison/bin:$PATH"
fi

if [ -d '/usr/local/opt/bison/lib' ]; then
  export LDFLAGS="-L/usr/local/opt/bison/lib"
fi

# Add `cargo`
if [ -f "$HOME/.cargo/env" ]; then
  auto_source $HOME/.cargo/env
fi

# Add `cargo`
if [ -d "$HOME/.rustup" ]; then
  export RUSTUP_HOME="$HOME/.rustup"
fi

# Add `emacs`
if [ -d '/usr/local/Cellar/emacs/26.2/bin' ]; then
  export PATH="/usr/local/Cellar/emacs/26.2/bin:$PATH"
fi

# Add `nvm`
if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Add `llvm`
if [ -d '/usr/local/opt/llvm/bin/' ]; then
  export PATH="/usr/local/opt/llvm/bin/:$PATH"
fi

if [ -x '/usr/libexec/java_home' ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
  if [ -n "$JAVA_HOME" ]; then
    export JAVA_HOME
  fi
fi

# Add iTerm2 things
if [[ "$SHELL" == *'zsh' ]]; then
  if [ -e "${HOME}/.iterm2_shell_integration.zsh" ]; then
    auto_source "${HOME}/.iterm2_shell_integration.zsh"
  fi
fi

# add brew path
if [ -d '/usr/local/sbin' ]; then
  export PATH="/usr/local/sbin:$PATH"
fi

# Initialize `rbenv`
if type docker >/dev/null 2>&1; then
  alias d=docker
fi

# Initialize `rbenv`
if type rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# Setup Helm in path
if [ -d "$HOME/opt/helm-2.14.3" ]; then
  export PATH="$HOME/opt/helm-2.14.3:$PATH"
fi

# Add `made/*` - NB: always last
export PATH="$DOT_FILES_DIR/made/bin:$PATH"
export MANPATH="$DOT_FILES_DIR/made/doc:$MANPATH"
