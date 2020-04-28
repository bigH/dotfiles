#!/usr/bin/env zsh

# `autocd` allows you to cd by just typing in a directory name
#
# NB: I don't like this any-more because:
#
#   $ pwd
#   /path/to
#   $ mkdir somewhere
#   $ alias go=somewhere
#   $ go
#   $ pwd
#   /path/to/somewhere
#
setopt noautocd

# warn me if a glob doesn't match anything
setopt nomatch

# globbing is case insensitive
setopt no_case_glob

# commands preceded with '#' aren't run
setopt interactive_comments

# ignore any commands beginning with a space
setopt hist_ignore_space

# load zmv - the pattern renamer/mover/copier in zsh
autoload -Uz zmv

# highlight usefully
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
