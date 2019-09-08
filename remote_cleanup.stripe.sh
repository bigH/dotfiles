#!/bin/bash

function devbox_echo() {
  printf "[${MAGENTA}${BOLD}DEVBOX${NORMAL}] $1"
}

echo ""

unlink $HOME/.rgignore
unlink $HOME/.pryrc
unlink $HOME/.vimrc

rm -f $HOME/.vim/UltiSnips
rm -f $HOME/.vim

devbox_echo "${BLUE}${BOLD}Removing \`.hiren\`${NORMAL}"; echo ""

rm -rf $DOT_FILES_DIR

devbox_echo "${BLUE}${BOLD}Restoring old \`.profile\`${NORMAL}"; echo ""

mv -f $HOME/.profile-bak $HOME/.profile

echo ""
