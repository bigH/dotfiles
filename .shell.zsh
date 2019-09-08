#!/usr/bin/env zsh

# General zshzle options
# cd by just typing in a directory name
setopt autocd
# warn me if a glob doesn't match anything
setopt nomatch
# globbing is case insensitive
setopt no_case_glob
# commands preceded with '#' aren't run
setopt interactive_comments

# load zmv - the pattern renamer/mover/copier in zsh
autoload -Uz zmv

# highlight usefully
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)