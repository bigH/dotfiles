#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"

# unlinks
unlink $HOME/.ackrc
unlink $HOME/.gitignore_global
unlink $HOME/.gitconfig
unlink $HOME/.vimrc
unlink $HOME/.zshrc
unlink $DOT_FILES_DIR/bin/git-wtf

# unlink directories
rm -f $HOME/.vim

if [ ! -z "$DOT_FILES_ENV" ]; then
  rm -f $HOME/$DOT_FILES_ENV-bin
fi

rm -f $HOME/bin

# cleanings
rm -rf $DOT_FILES_DIR/.vim
rm -rf $DOT_FILES_DIR/git-wtf
rm -rf $DOT_FILES_DIR/solarized
rm -rf $DOT_FILES_DIR/dircolors-solarized
rm -rf $HOME/.oh-my-zsh

