#!/bin/sh

# unlinks
unlink ~/.ackrc
unlink ~/.gitignore_global
unlink ~/.gitconfig
unlink ~/.vimrc
unlink ~/.zshrc
unlink ~/.hiren/bin/git-wtf

# unlink directories
rm -f ~/.vim
rm -f ~/bin

# cleanings
rm -rf ~/.hiren/.vim
rm -rf ~/.hiren/git-wtf
rm -rf ~/.hiren/solarized
rm -rf ~/.hiren/dircolors-solarized
rm -rf ~/.oh-my-zsh

