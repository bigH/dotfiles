#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  COMPLETEABLE_SHELL_TYPE='zsh'
elif [[ "$SHELL" == *'bash' ]]; then
  COMPLETEABLE_SHELL_TYPE='bash'
else
  COMPLETEABLE_SHELL_TYPE=''
fi

# only configure these things if you're in `bash` or `zsh`
if [ ! -z "$COMPLETEABLE_SHELL_TYPE" ]; then
  # Auto-completion
  [[ $- == *i* ]] && auto_source "$DOT_FILES_DIR/fzf/shell/completion.$COMPLETEABLE_SHELL_TYPE" 2> /dev/null

  # Key bindings
  auto_source "$DOT_FILES_DIR/fzf/shell/key-bindings.$COMPLETEABLE_SHELL_TYPE"

  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

  if type fd >/dev/null 2>&1; then
    # Use `fd` instead of the default find command for listing path candidates.
    _fzf_compgen_path() {
      fd --hidden --follow --exclude ".git" . "$1"
    }

    # Use `fd` to generate the list for directory completion
    _fzf_compgen_dir() {
      fd --type d --hidden --follow --exclude ".git" . "$1"
    }

    # use `fd`
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude ".git" .'
    export FZF_CTRL_T_COMMAND='fd --hidden --follow --exclude ".git" .'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude ".git" .'
  fi

  if type gls >/dev/null 2>&1; then
    # use `gls` if present (on OS X)
    export DIR_PREVIEW_COMMAND="gls --color=always -G"
  else
    # use `ls` otherwise
    export FZF_ALT_C_OPTS="ls --color=always -G"
  fi

  # use `ls` to preview directories
  export FZF_ALT_C_OPTS="--preview='$DIR_PREVIEW_COMMAND'"

  # binary -> display indication of this
  # directory -> use `$DIR_PREVIEW_COMMAND`
  # files -> `bat` is installed on all my machines
  export FZF_CTRL_T_OPTS='--preview='"'"'[[ $(file --mime {}) =~ binary ]] &&
                                           echo {} is a binary file ||
                                         [[ $(file --mime {}) =~ directory ]] &&
                                           '"$DIR_PREVIEW_COMMAND"' {} ||
                                         bat --style=numbers --color=always {}'"'"
fi
