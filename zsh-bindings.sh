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

# Ctrl-N - insert current directory's name
insert-current-directory-basename() {
  LBUFFER+="$(basename $(pwd))"
  zle redisplay
}
zle -N insert-current-directory-basename
bindkey '^n' insert-current-directory-basename

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

# Ctrl-R - append history to the command line
fzf-history-widget-append() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
  # Ensure the module is loaded if not already, and the required features, such
  # as the associative 'history' array, which maps event numbers to full history
  # lines, are set. Also, make sure Perl is installed for multi-line output.
  if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
    selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --expect='enter,alt-enter' --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  else
    selected="$(fc -rl 1 | awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --expect='enter,alt-enter' --bind=ctrl-r:toggle-sort --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  fi
  local ret=$?

  selected_content="$(echo "$selected" | tail -n +2)"
  key_pressed="$(echo "$selected" | head -n 1)"

  if [ -n "$selected_content" ]; then
    if [[ $(awk '{print $1; exit}' <<< "$selected_content") =~ ^[1-9][0-9]* ]]; then
      NEW_CONTENT="$(history $MATCH | head -n1 | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]*//')"
    else # selected is a custom query, not from history
      NEW_CONTENT="$selected_content"
    fi

    if [ "$key_pressed" = 'alt-enter' ]; then
      if ! [[ "$LBUFFER" =~ ^[[:space:]]*$ ]]; then
        NEW_CONTENT=$'\n'"$NEW_CONTENT"
      fi

      if ! [[ "$RBUFFER" =~ ^[[:space:]]*$ ]]; then
        NEW_CONTENT="$NEW_CONTENT"$'\n'
      fi

      LBUFFER+="$NEW_CONTENT"
    else
      LBUFFER="$NEW_CONTENT"
      RBUFFER=""
    fi
  fi
  zle reset-prompt
  return $ret
}

zle -N fzf-history-widget-append
bindkey '^r' fzf-history-widget-append

# Alt-A - append last command
insert-last-command() {
  LBUFFER+=" $history[$((HISTCMD-1))]"
}

zle -N insert-last-command
bindkey '^[a' insert-last-command

# Alt-Shift-A - append last command output
insert-last-command-output() {
  LBUFFER+=" $(eval "$history[$((HISTCMD-1))]")"
}

zle -N insert-last-command-output
bindkey '^[A' insert-last-command-output

# get_ith_param_from_history() {
#   i=$1
#   command_line="$history[$((HISTCMD-1))]"
# }
#
# for i in {0..9}; do
#   insert-${i}th-arg() {
#     LBUFFER+=" $(get_ith_param $i)"
#   }
# done
#
