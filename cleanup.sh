#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren
source "$DOT_FILES_DIR/util.sh"

# TODO call project cleanup.sh

# unlinks
unlink "$HOME/.ackrc"
unlink "$HOME/.alacritty.yml"
unlink "$HOME/.config/alacritty.yml"
unlink "$HOME/.ctags"
unlink "$HOME/.gitconfig"
unlink "$HOME/.gitignore_global"
unlink "$HOME/.inputrc"
unlink "$HOME/.pryrc"
unlink "$HOME/.rgignore"
unlink "$HOME/.tigrc"
unlink "$HOME/.vimrc"
unlink "$HOME/.zshrc"

# unlink, but directory can remain
unlink "$HOME/.vim/coc-settings.json"
unlink "$HOME/.config/nvim/coc-settings.json"
unlink "$HOME/.config/nvim/init.vim"

# unlink directories
rm -f "$HOME/.vim/UltiSnips"
rm -f "$HOME/.config/nvim/syntax"
rm -f "$HOME/.config/nvim/ftdetect"
rm -f "$HOME/.vim/syntax"
rm -f "$HOME/.vim/ftdetect"
rm -f "$HOME/.vim"
rm -f "$HOME/nice-noise-loops"
rm -f "$HOME/bin"

# cleanings
rm -rf "$DOT_FILES_DIR/.oh-my-zsh"
rm -rf "$DOT_FILES_DIR/.vim"
rm -rf "$DOT_FILES_DIR/made-bin"
rm -rf "$DOT_FILES_DIR/fzf"
rm -rf "$DOT_FILES_DIR/ripgrep"
rm -rf "$DOT_FILES_DIR/bat"
rm -rf "$DOT_FILES_DIR/fd"
rm -rf "$DOT_FILES_DIR/pure"
rm -rf "$HOME/.oh-my-zsh"

echo "Done."
