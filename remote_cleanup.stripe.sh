#!/bin/bash

unlink $HOME/.rgignore
unlink $HOME/.pryrc
unlink $HOME/.vimrc
unlink $HOME/.zshrc

rm -f $HOME/.vim/UltiSnips
rm -f $HOME/.vim

rm -rf $HOME/.oh-my-zsh

rm -rf $DOT_FILES_DIR

mv -f $HOME/.profile-bak $HOME/.profile
