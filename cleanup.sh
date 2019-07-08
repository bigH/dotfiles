#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"

# unlinks
unlink $HOME/.alacritty.yml
unlink $HOME/.ackrc
unlink $HOME/.config/nvim/init.vim
unlink $HOME/.gitignore_global
unlink $HOME/.gitconfig
unlink $HOME/.pryrc
unlink $HOME/.vimrc
unlink $HOME/.zshrc

unlink $DOT_FILES_DIR/bin/git-wtf

# unlink directories
rm -f $HOME/.vim/UltiSnips
rm -f $HOME/.vim
rm -f $HOME/home
rm -f $HOME/nice-noise-loops
rm -f $HOME/bin

if [ ! -z "$DOT_FILES_ENV" ]; then
  rm -f $HOME/$DOT_FILES_ENV-bin
fi

# cleanings
rm -rf $DOT_FILES_DIR/.vim
rm -rf $DOT_FILES_DIR/pure
rm -rf $DOT_FILES_DIR/git-wtf
rm -rf $HOME/.oh-my-zsh

