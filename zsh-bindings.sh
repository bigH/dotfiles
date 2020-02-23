#!/usr/bin/env zsh

# expand _only_ aliases that I want to expand
# function expand-alias() {
#   zle _expand_alias
#   zle self-insert
# }
# zle -N expand-alias
# bindkey -M main '^i' expand-alias

# Ctrl-P - select file to paste
fzf-file-select-and-insert() {
  LBUFFER+=$(fzf-file-selector)
  zle redisplay
}
zle -N fzf-file-select-and-insert
bindkey '^p' fzf-file-select-and-insert

# Ctrl-N - select directory to paste
fzf-directory-select-and-insert() {
  LBUFFER+=$(fzf-directory-selector)
  zle redisplay
}
zle -N fzf-directory-select-and-insert
bindkey '^n' fzf-directory-select-and-insert

# Ctrl-H - find commit SHA(s)
fzf-gh-widget() {
  local result=$(gh | join-lines);
  LBUFFER+=$result
  zle redisplay
}
zle -N fzf-gh-widget
bindkey '^h' fzf-gh-widget

# Alt-H - commit SHA range
fzf-gh-range-widget() {
  local result=$(gh | tac | join-lines '..');
  LBUFFER+=$result
  zle redisplay
}
zle -N fzf-gh-range-widget
bindkey '^[h' fzf-gh-range-widget

# Alt-O - open files differing from particular commit
fzf-git-files-from-commits() {
  local commits=$(gh)
  local num_commits=$(echo "$commits" | wc -l | bc)
  if [ "$num_commits" -eq 1 ]; then
    local result=$(gfc "$commits" | join-lines);
    LBUFFER+=$result
  elif [ "$num_commits" -eq 2 ]; then
    local range=$(echo "$commits" | tac | join-lines '..')
    local result=$(gfr "$range" | join-lines);
    LBUFFER+=$result
  elif [ "$num_commits" -ge 2 ]; then
    # unsupported
  fi
  zle redisplay
}
zle -N fzf-git-files-from-commits
bindkey '^[o' fzf-git-files-from-commits

# Ctrl-O - open files differing from merge-base
fzf-gfc-widget() {
  local result=$(gfc | join-lines);
  LBUFFER+=$result
  zle redisplay
}
zle -N fzf-gfc-widget
bindkey '^O' fzf-gfc-widget

# Ctrl-B/F - back / forward by word
bindkey '^b' backward-word
bindkey '^f' forward-word

# Alt-B/F - back / forward by word
bindkey '^[b' emacs-backward-word
bindkey '^[f' emacs-forward-word

# Alt-Space - see status
zmodload -i zsh/parameter
fzf-git-status() {
  local result=$(gfs | join-lines);
  LBUFFER+=$result
  zle redisplay
}
zle -N fzf-git-status
bindkey '^[ ' fzf-git-status

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
