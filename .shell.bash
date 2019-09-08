#!/usr/bin/env bash

# Don't put duplicate lines in the history
export HISTCONTROL=ignoreboth:erasedups

# Set history length
HISTFILESIZE=1000000000
HISTSIZE=1000000

# Append to the history file, don't overwrite it
shopt -s histappend
# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize
# Autocorrect typos in path names when using `cd`
shopt -s cdspell
# Save all lines of a multiple-line command in the same history entry (allows easy re-editing of multi-line commands)
shopt -s cmdhist
# Do not autocomplete when accidentally pressing Tab on an empty line. (It takes forever and yields "Display all 15 gazillion possibilites?")
shopt -s no_empty_cmd_completion
# **/thing works properly
shopt -s globstar
# Include .* in *
shopt -s dotglob
# Ignore case in patterns
shopt -s nocaseglob
# Ignore case in patterns
shopt -s nocaseglob

for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done

