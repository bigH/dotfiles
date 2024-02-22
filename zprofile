autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

export SHELL="/bin/zsh"
export SHELL_NAME="zsh"

export DOT_FILES_DIR="$HOME/.hiren"

source "$DOT_FILES_DIR/profile"
