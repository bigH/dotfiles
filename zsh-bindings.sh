#!/usr/bin/env zsh

# Ctrl-P - select file to paste
fzf-file-select-and-insert() {
  LBUFFER+="$(fzf-file-selector)"
  zle redisplay
}
zle -N fzf-file-select-and-insert
bindkey '^p' fzf-file-select-and-insert

# Alt-P - select file based on ripgrep
fzf-ripgrep-select-and-insert() {
  LBUFFER+="$(fzf-ripgrep-selector "$LBUFFER")"
  zle redisplay
}
zle -N fzf-ripgrep-select-and-insert
bindkey '^[p' fzf-ripgrep-select-and-insert

# Ctrl-N - select directory to paste
fzf-directory-select-and-insert() {
  LBUFFER+="$(fzf-directory-selector)"
  zle redisplay
}
zle -N fzf-directory-select-and-insert
bindkey '^n' fzf-directory-select-and-insert

# Ctrl-H - find commit SHA(s)
fzf-gh-widget() {
  local result="$(git fuzzy log | join_lines);"
  LBUFFER+="$result"
  zle redisplay
}
zle -N fzf-gh-widget
bindkey '^h' fzf-gh-widget

# Alt-O - open files differing from particular commit
fzf-git-files-from-commits() {
  local commits="$(git fuzzy log)"
  local num_commits="$(echo "$commits" | wc -l | awk '{ print $1 }')"
  if [ "$num_commits" -eq 0 ]; then
    local result="$(git fuzzy diff $(git merge-base HEAD $(git merge-base-absolute)) | join_lines);"
    LBUFFER+="$result"
  elif [ "$num_commits" -eq 1 ]; then
    local result="$(git fuzzy diff "$commits"^ | join_lines);"
    LBUFFER+="$result"
  elif [ "$num_commits" -eq 2 ]; then
    local range="$(echo "$commits" | tac | join_lines '..')"
    local result="$(git fuzzy diff "$range" | join_lines);"
    LBUFFER+="$result"
  elif [ "$num_commits" -ge 2 ]; then
    # unsupported
  fi
  zle redisplay
}
zle -N fzf-git-files-from-commits
bindkey '^[o' fzf-git-files-from-commits

# Ctrl-O - open files differing from merge-base
fzf-open-git-widget() {
  local result="$( \
    { git fuzzy status || \
      git fuzzy diff $(git merge-base HEAD $(git merge-base-absolute)) \
    } | join_lines \
  )"
  if [[ "$LBUFFER" = *" " ]]; then
    LBUFFER+="$result"
  else
    LBUFFER+=" $result"
  fi
  zle redisplay
}
zle -N fzf-open-git-widget
bindkey '^O' fzf-open-git-widget

# Ctrl-B/F - back / forward by word
bindkey '^b' backward-word
bindkey '^f' forward-word

# Alt-B/F - back / forward by word
bindkey '^[b' emacs-backward-word
bindkey '^[f' emacs-forward-word

# Ctrl-V - edit the command line in vim
bindkey '^v' edit-command-line

fixup-command-for-cmd-substitution() {
  if [[ "$1" == *'rg'* ]]; then
    if [[ "$1" == *'$(rg'* ]] || [[ "$1" == *' -l'* ]] || [[ "$1" == *' --files-without-match'* ]]; then
      # too complex or already containing flag needed
      echo "$1"
    else
      echo "$1" | sed 's/rg/rg -l/'
    fi
  else
    echo "$1"
  fi
}

# Alt-V - `vim $(... -l)` around
insert-last-command-with-vim() {
  BUFFER='vim $('
  BUFFER+="$(fixup-command-for-cmd-substitution "$history[$((HISTCMD-1))]")"
  BUFFER+=')'
  CURSOR=$(echo "$#BUFFER - 1" | bc)
}
zle -N insert-last-command-with-vim
bindkey '^[v' insert-last-command-with-vim

# Alt-R - `rg $(... -l)` around
insert-last-command-with-rg() {
  BUFFER='rg  -- $('
  BUFFER+="$(fixup-command-for-cmd-substitution "$history[$((HISTCMD-1))]")"
  BUFFER+=')'
  CURSOR=3
}
zle -N insert-last-command-with-rg
bindkey '^[r' insert-last-command-with-rg
