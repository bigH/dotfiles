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

# Ctrl-B/F - back / forward by word (instead of Alt)
# frees up Alt for other uses
bindkey '^b' backward-word
bindkey '^f' forward-word

# Alt-B inserts branch (OR if you use shortcuts, anything relating to branches)
if command_exists git-fuzzy; then
  insert-git-branch-name() {
    LBUFFER+="$(git-fuzzy branch)"
  }

  zle -N insert-git-branch-name
  bindkey '^[b' insert-git-branch-name
fi

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

# Shell-GPT integration ZSH v0.2
_sgpt_zsh() {
if [[ -n "$BUFFER" ]]; then
    _sgpt_prev_cmd=$BUFFER
    BUFFER+="⌛"
    zle -I && zle redisplay
    BUFFER=$(sgpt --shell <<< "$_sgpt_prev_cmd" --no-interaction)
    zle end-of-line
fi
}
zle -N _sgpt_zsh
bindkey ^l _sgpt_zsh
# Shell-GPT integration ZSH v0.2

# Alt-S - insert SHA of the current commit
insert-sha() {
  LBUFFER+="$(git rev-parse HEAD)"
}
zle -N insert-sha
bindkey '^[s' insert-sha

# Alt-S - insert SHA of the current commit
insert-sha() {
  LBUFFER+="$(git rev-parse HEAD)"
}
zle -N insert-sha
bindkey '^[s' insert-sha

# Alt-E - make the command use `entr`
add-entr() {
  if [[ "$#BUFFER" -gt 0 ]]; then
    BUFFER="fd | entr -c $BUFFER"
    CURSOR="$((CURSOR + 13))"
  else
    BUFFER="fd | entr -c $history[$((HISTCMD-1))]"
    CURSOR=2
  fi
}
zle -N add-entr
bindkey '^[e' add-entr
