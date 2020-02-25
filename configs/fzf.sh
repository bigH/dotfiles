#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  COMPLETEABLE_SHELL_TYPE='zsh'
elif [[ "$SHELL" == *'bash' ]]; then
  COMPLETEABLE_SHELL_TYPE='bash'
else
  COMPLETEABLE_SHELL_TYPE=''
fi

# only configure these things if you're in `bash` or `zsh`
if [ -n "$COMPLETEABLE_SHELL_TYPE" ]; then
  # Auto-completion
  [[ $- == *i* ]] && auto_source "$HOME/.fzf.$COMPLETEABLE_SHELL_TYPE" 2> /dev/null

  export FZF_DEFAULT_OPTS=" --border \
                            --layout=reverse \
                            --bind '?:toggle-preview' \
                            --bind 'ctrl-s:toggle-sort' \
                            --bind 'ctrl-e:preview-down' \
                            --bind 'ctrl-y:preview-up' \
                            --bind 'change:top' \
                            --height '55%' \
                            --preview-window 'right:50%' "

  if type fd >/dev/null 2>&1; then
    # Use `fd` instead of the default find command for listing path candidates.
    _fzf_compgen_path() {
      fd --hidden --follow . "$1"
    }

    # Use `fd` to generate the list for directory completion
    _fzf_compgen_dir() {
      fd --type d --hidden --follow . "$1"
    }

    # use `fd`
    export FZF_DEFAULT_COMMAND='fd --hidden --follow .'
    export FZF_CTRL_T_COMMAND='fd --hidden --follow .'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow .'

    export FZF_CTRL_R_OPTS='--preview "echo {}" --height 50% --preview-window down:5:wrap --bind "?:toggle-preview"'
  fi

  if type gls >/dev/null 2>&1; then
    # use `gls` if present (on OS X)
    export DIR_PREVIEW_COMMAND='gls --color=always -G'
  else
    # use `ls` otherwise
    export FZF_ALT_C_OPTS='ls --color=always -G'
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
