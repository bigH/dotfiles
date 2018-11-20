#!/bin/bash

# unlinks
unlink $HOME/.ackrc
unlink $HOME/.gitignore_global
unlink $HOME/.gitconfig
unlink $HOME/.vimrc
unlink $HOME/.zshrc
unlink $HOME/.hiren/bin/git-wtf

# unlink directories
rm -f $HOME/.vim
rm -f $HOME/bin

# cleanings
rm -rf $HOME/.hiren/.vim
rm -rf $HOME/.hiren/git-wtf
rm -rf $HOME/.hiren/solarized
rm -rf $HOME/.hiren/dircolors-solarized
rm -rf $HOME/.oh-my-zsh

