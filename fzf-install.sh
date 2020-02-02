#!/bin/bash

set -e

cd $DOT_FILES_DIR/fzf
rm -rf target/*
rm -f bin/fzf
make install
./install --no-key-bindings --no-completion --no-update-rc --no-bash --no-zsh --no-fish

cp bin/fzf{,-tmux} $DOT_FILES_DIR/made/bin
cp man/fzf*.* $DOT_FILES_DIR/made/doc/.
