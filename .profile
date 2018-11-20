export DOT_FILES_DIR=~/.hiren

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"

source $DOT_FILES_DIR/.colors
source $DOT_FILES_DIR/.local.configs

if [ "$DOT_FILES_ENV" = "stripe" ]; then
  source $DOT_FILES_DIR/.stripe.configs
else
  source $DOT_FILES_DIR/.default.configs
fi

source $DOT_FILES_DIR/.aliases
source $DOT_FILES_DIR/.fzf.functions
source $DOT_FILES_DIR/.fzf.configs
source $DOT_FILES_DIR/.zsh.functions
if [ "$DOT_FILES_ENV" = "stripe" ]; then
  source $DOT_FILES_DIR/.stripe.ctags.functions
else
  # source $DOT_FILES_DIR/.ctags.functions
fi
source $DOT_FILES_DIR/.ctags.configs
source $DOT_FILES_DIR/.bindings
