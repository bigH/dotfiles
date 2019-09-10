#!/bin/sh

export DOT_FILES_DIR=$HOME/.hiren
source $DOT_FILES_DIR/util.sh

# unlinks
unlink $HOME/.alacritty.yml
unlink $HOME/.ackrc
unlink $HOME/.config/nvim/init.vim
unlink $HOME/.gitignore_global
unlink $HOME/.rgignore
unlink $HOME/.gitconfig
unlink $HOME/.inputrc
unlink $HOME/.pryrc
unlink $HOME/.tigrc
unlink $HOME/.vimrc
unlink $HOME/.zshrc

# unlink directories
rm -f $HOME/.vim/UltiSnips
rm -f $HOME/.vim
rm -f $HOME/nice-noise-loops
rm -f $HOME/bin

if [ ! -z "$DOT_FILES_ENV" ]; then
  rm -f $HOME/$DOT_FILES_ENV-bin
fi

# cleanings
rm -rf $DOT_FILES_DIR/.oh-my-zsh
rm -rf $DOT_FILES_DIR/.vim
rm -rf $DOT_FILES_DIR/made-bin
rm -rf $DOT_FILES_DIR/fzf
rm -rf $DOT_FILES_DIR/ripgrep
rm -rf $DOT_FILES_DIR/bat
rm -rf $DOT_FILES_DIR/fd
rm -rf $DOT_FILES_DIR/pure
rm -rf $HOME/.oh-my-zsh

echo "Done."
