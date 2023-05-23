#!/usr/bin/env bash

export DOT_FILES_DIR=$HOME/.hiren
source "$DOT_FILES_DIR/setup_utils.sh"

# unlinks
unlink "$HOME/.ackrc"
unlink "$HOME/.alacritty.yml"
unlink "$HOME/.clocignore"
unlink "$HOME/.ctags"
unlink "$HOME/.fdignore"
unlink "$HOME/.fxrc"
unlink "$HOME/.gitconfig"
unlink "$HOME/.gitignore_global"
unlink "$HOME/.inputrc"
unlink "$HOME/.pryrc"
unlink "$HOME/.rgignore"
unlink "$HOME/.tigrc"

# big ones
unlink "$HOME/.bashrc"
unlink "$HOME/.bash_profile"
unlink "$HOME/.zshrc"
unlink "$HOME/.zprofile"

# unlink, but directory can remain
unlink "$HOME/.config/alacritty/alacritty.yml"
unlink "$HOME/.config/nvim"
unlink "$HOME/.config/gh-dash"
unlink "$HOME/.ideavimrc"

# unlink directories
rm -f "$HOME/nice-noise-loops"
rm -f "$HOME/bin"

# cleanings
rm -rf "$DOT_FILES_DIR/.oh-my-zsh"
rm -rf "$DOT_FILES_DIR/.vim"
rm -rf "$DOT_FILES_DIR/made"
rm -rf "$DOT_FILES_DIR/fzf"
rm -rf "$DOT_FILES_DIR/fzf-tab-completion"
rm -rf "$DOT_FILES_DIR/ripgrep"
rm -rf "$DOT_FILES_DIR/bat"
rm -rf "$DOT_FILES_DIR/fd"
rm -rf "$DOT_FILES_DIR/pure"
rm -rf "$DOT_FILES_DIR/cheat.sh"
rm -rf "$DOT_FILES_DIR/utils"
rm -rf "$DOT_FILES_DIR/pgdiff"
rm -rf "$HOME/.oh-my-zsh"

echo "Done."
