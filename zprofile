autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

export SHELL="/bin/zsh"
export SHELL_NAME="zsh"

export DOT_FILES_DIR="$HOME/.hiren"

source "$DOT_FILES_DIR/profile"

# happens after `profile` since we get `brew` on the `PATH` there
if command_exists brew; then
  if [ -e "$(brew --prefix)/share/zsh-completions" ]; then
    FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
  fi
fi
