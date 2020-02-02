#!/usr/bin/env zsh

# expand _only_ aliases that I want to expand
# function expand-alias() {
#   zle _expand_alias
#   zle self-insert
# }
# zle -N expand-alias
# bindkey -M main '^i' expand-alias

# Ctrl-P - select file to paste
bindkey '^p' fzf-file-widget
# Ctrl-N - select directory to paste
bindkey '^n' fzf-cd-widget

# Ctrl-H - find commit SHA(s)
fzf-gh-widget() { local result=$(gh | join-lines); LBUFFER+=$result }
zle -N fzf-gh-widget
bindkey '^h' fzf-gh-widget

# Alt-H - commit SHA range
fzf-gh-range-widget() { local result=$(gh | tac | join-lines '..'); LBUFFER+=$result }
zle -N fzf-gh-range-widget
bindkey '^[h' fzf-gh-range-widget

# Alt-O - open files differing from particular commit
fzf-gfi-gh-widget() { local result=$(gfi $(gh) | join-lines); LBUFFER+=$result }
zle -N fzf-gfi-gh-widget
bindkey '^[o' fzf-gfi-gh-widget

# Ctrl-O - open files differing from merge-base
fzf-gfi-widget() { local result=$(gfi | join-lines); LBUFFER+=$result }
zle -N fzf-gfi-widget
bindkey '^O' fzf-gfi-widget

# Ctrl-B/F - back / forward by word
bindkey '^b' backward-word
bindkey '^f' forward-word

# Alt-B/F - back / forward by word
bindkey '^[b' emacs-backward-word
bindkey '^[f' emacs-forward-word

# Alt-Space - insert `git branch-name`
zmodload -i zsh/parameter
insert-git-branch-name() {
  LBUFFER+=`git branch-name`
}
zle -N insert-git-branch-name
bindkey '^[ ' insert-git-branch-name

# Alt-X - insert last command result
zmodload -i zsh/parameter
insert-last-command-output() {
  LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output
bindkey '^[x' insert-last-command-output

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
