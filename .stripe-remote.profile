#!/bin/sh

setopt AUTO_NAME_DIRS

zstyle :prompt:pure:user color yellow
zstyle :prompt:pure:user:root color red
zstyle :prompt:pure:host color magenta

PROMPT='[%F{green}%BDEVBOX%b%f] '"$PROMPT"
RPROMPT='[%F{green}%BDEVBOX%b%f]'
