export DOT_FILES_DIR=$HOME/.hiren

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"

source $DOT_FILES_DIR/.colors
source $DOT_FILES_DIR/.local.configs

if [ ! -z "$DOT_FILES_ENV" ]; then
  source $DOT_FILES_DIR/.$DOT_FILES_ENV.configs
else
  source $DOT_FILES_DIR/.default.configs
fi

source $DOT_FILES_DIR/.aliases
source $DOT_FILES_DIR/.fzf.functions
source $DOT_FILES_DIR/.fzf.configs
source $DOT_FILES_DIR/.zsh.functions
if [ ! -z "$DOT_FILES_ENV" ]; then
  source $DOT_FILES_DIR/.$DOT_FILES_ENV.functions
fi
if [ ! -z "$DOT_FILES_ENV" ]; then
  source $DOT_FILES_DIR/.$DOT_FILES_ENV.ctags.functions
fi
source $DOT_FILES_DIR/.ctags.configs
source $DOT_FILES_DIR/.bindings

source $DOT_FILES_DIR/.pure_setup
