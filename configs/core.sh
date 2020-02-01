#!/usr/bin/env bash

# Add Haskell configs
if [ -e $HOME/.ghcup/env ]; then
  source $HOME/.ghcup/env
else
  export PATH="$HOME/.cabal/bin:$PATH"
fi

# Add go `bin`
export PATH="$HOME/go/bin:$PATH"

# Add Home `bin`
export PATH="$HOME/bin:$PATH"

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
  source $HOME/.cargo/env
fi

# Add `cargo`
if [ -d "$HOME/.rustup" ]; then
  export RUSTUP_HOME="$HOME/.rustup"
fi

# Add `made-bin`
export PATH="$DOT_FILES_DIR/made-bin:$PATH"

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
  if [ -n"$JAVA_HOME" ]; then
    export JAVA_HOME
  fi
fi

# Add iTerm2 things
if [[ "$SHELL" == *'zsh' ]]; then
  if [ -e "${HOME}/.iterm2_shell_integration.zsh" ]; then
    source "${HOME}/.iterm2_shell_integration.zsh"
  fi
fi

# Add `rg` completion to
if [ -e "$DOT_FILES_DIR/ripgrep/complete" ]; then
  if [[ "$SHELL" == *'zsh' ]]; then
    fpath+="$DOT_FILES_DIR/ripgrep/complete"
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
