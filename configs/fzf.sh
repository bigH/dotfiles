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
  auto_source "$DOT_FILES_DIR/auto-sized-fzf/auto-sized-fzf.sh" 2> /dev/null

  export FZF_SIZER_HORIZONTAL_PREVIEW_PERCENT_CALCULATION='max(60, min(80, 100 - ((7000 + (11 * __WIDTH__))  / __WIDTH__)))'
  export FZF_SIZER_VERTICAL_PREVIEW_PERCENT_CALCULATION='max(60, min(80, 100 - ((3000 + (5 * __HEIGHT__)) / __HEIGHT__)))'

  export FZF_DEFAULTS_BASIC="\
  --border \
  --pointer='» ' \
  --marker='◈ ' \
  --layout=reverse \
  --bind 'ctrl-space:toggle-preview' \
  --bind 'ctrl-s:toggle-sort' \
  --bind 'ctrl-e:preview-down' \
  --bind 'ctrl-y:preview-up' \
  --no-height"

  export FZF_DEFAULT_OPTS_MULTI="\
    --bind alt-d:deselect-all \
    --bind alt-a:select-all"

  build_fzf_defaults() {
    FZF_DEFAULT_OPTS="\
      $FZF_DEFAULTS_BASIC \
      --preview '[ -f {} ] && bat --style=numbers,changes --color=always {} || exa --color=always -l {}' \
      $(fzf_sizer_preview_window_settings)"
    # shellcheck disable=2090
    export FZF_DEFAULT_OPTS
  }

  build_fzf_defaults

  if command_exists fd; then
    # Use `fd` instead of the default find command for listing path candidates.
    _fzf_compgen_path() {
      fd --color=always --strip-cwd-prefix --hidden --follow . "$1"
    }

    # Use `fd` to generate the list for directory completion
    _fzf_compgen_dir() {
      fd --color=always --strip-cwd-prefix --type d --hidden --follow . "$1"
    }

    # use `fd`
    export FZF_DEFAULT_COMMAND='fd --color=always --strip-cwd-prefix --hidden --follow .'
    export FZF_CTRL_T_COMMAND='fd --color=always --strip-cwd-prefix --hidden --follow .'
    export FZF_ALT_C_COMMAND='fd --color=always --strip-cwd-prefix --type d --hidden --follow .'

    export FZF_CTRL_R_OPTS='--preview "echo {}" --height 50% --preview-window down:5:wrap --bind "?:toggle-preview"'
  fi

  if command_exists exa; then
    export DIR_PREVIEW_COMMAND='exa --color=always -l --color-scale --classify --sort=type --git'
  else
    if command_exists gls; then
      # `gls` installed by `coreutils`
      export DIR_PREVIEW_COMMAND='gls --color=always -G'
    else
      export FZF_ALT_C_OPTS='ls --color=always -G'
    fi
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
