#!/usr/bin/env bash

# turn off certain `shellcheck` errors
export SHELLCHECK_OPTS="-e SC1090"

# these aliases have to be defined so these commands are seen to exist
if type fdfind >/dev/null 2>&1; then
  alias fd=fdfind
fi

if type batcat >/dev/null 2>&1; then
  alias bat=batcat
fi

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

# Add `coreutils` 'g' prefixed
if [ -d '/usr/local/opt/coreutils/bin' ]; then
  export PATH="/usr/local/opt/coreutils/bin:$PATH"
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
fi

if [ -d '/usr/local/opt/openjdk@11' ]; then
  JAVA_HOME="/usr/local/opt/openjdk@11"
fi

if [ -n "$JAVA_HOME" ]; then
  export JAVA_HOME
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
if type rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

# Setup Helm in path
if [ -d "$HOME/opt/helm-2.17.0" ]; then
  export PATH="$HOME/opt/helm-2.17.0:$PATH"
  export HELM_V2_HOME=$HOME/.helm2
  export HELM_HOME="$HOME/.helm2"
fi

# Setup Helm in path
if [ -d "$HOME/opt/helm-3.5.2" ]; then
  export PATH="$HOME/opt/helm-3.5.2:$PATH"
  export HELM_V3_CONFIG=$HOME/.helm3
  if [ -z "$HELM_HOME" ]; then
    export HELM_HOME="$HOME/.helm3"
  fi
fi

# NB: this alias must be here for completion to be configured correctly in `configs/helm.sh`
# if helm is not defined yet
if ! type helm >/dev/null 2>&1; then
  # helm3 > helm2
  if type helm3 >/dev/null 2>&1; then
    alias helm=helm3
  elif type helm2 >/dev/null 2>&1; then
    alias helm=helm2
  fi
fi

# Add `made/*` - NB: always last
export PATH="$DOT_FILES_DIR/made/bin:$PATH"
export MANPATH="$DOT_FILES_DIR/made/doc:$MANPATH"

# Add Home `bin`
if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

# Add Home `local-bin` if present
# useful for overriding and making local-specific installs
if [ -d "$HOME/local-bin" ]; then
  export PATH="$HOME/local-bin:$PATH"
fi

# Add `.local/bin` - used by (Haskell) `stack`
if [ -d "$HOME/.local/bin" ]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# Add `utils` - all externally sourced scripts
if [ -d "$DOT_FILES_DIR/utils" ]; then
  export PATH="$DOT_FILES_DIR/utils:$PATH"
fi

if type delta >/dev/null 2>&1; then
  export DIFF_PAGER="delta --theme=gruvbox --highlight-removed"
elif type diff-so-fancy >/dev/null 2>&1; then
  export DIFF_PAGER="diff-so-fancy"
else
  export DIFF_PAGER="cat -"
fi

if [ -d "$DOT_FILES_DIR/git-fuzzy" ]; then
  export PATH="$DOT_FILES_DIR/git-fuzzy/bin:$PATH"

  export GF_DEBUG_MODE=""
  export GF_COMMAND_DEBUG_MODE=""
  export GF_COMMAND_FZF_DEBUG_MODE=""
  export GF_COMMAND_LOG_OUTPUT=""
  export GF_INTERNAL_COMMAND_DEBUG_MODE=""

  # export GF_DEBUG_MODE="YES"
  # export GF_COMMAND_DEBUG_MODE="YES"
  # export GF_COMMAND_FZF_DEBUG_MODE="YES"
  # export GF_COMMAND_LOG_OUTPUT="YES"
  # export GF_INTERNAL_COMMAND_DEBUG_MODE="YES"

  export GF_PREFERRED_PAGER="$DIFF_PAGER"
  if type delta >/dev/null 2>&1; then
    # only add `__WIDTH__` if using `delta` - other pagers don't support it
    export GF_PREFERRED_PAGER="$GF_PREFERRED_PAGER -w __WIDTH__"
  fi

  export GF_HUB_PR_FORMAT="%pC%I%Creset %Cyellow(%ur)%Creset %Cmagenta(%au)%Creset %t %l%n"

  export GF_SNAPSHOT_DIRECTORY="./.git-fuzzy-snapshots"

  export GF_BAT_STYLE="changes"
  export GF_BAT_THEME="gruvbox"

  export GF_GREP_COLOR='1;30;48;5;15'
  export GF_LOG_MENU_PARAMS='--pretty=gflog'
  export GF_REFLOG_MENU_PARAMS='--pretty=gfreflog'
fi

if [ -d "$DOT_FILES_DIR/interactively" ]; then
  export PATH="$DOT_FILES_DIR/interactively/bin:$PATH"
fi

if [ -d "$HOME/.sdkman" ]; then
  export SDKMAN_DIR="$HOME/.sdkman"
  if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
  fi
fi
