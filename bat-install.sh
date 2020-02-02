#!/bin/bash

set -e

cd $DOT_FILES_DIR/bat
rm -rf target/*

if [ -d "$HOME/.cargo" ]; then
  source "$HOME/.cargo/env"
  cargo clean -q
  cargo build --release -q

  cp target/release/bat $DOT_FILES_DIR/made/bin
  cp assets/manual/bat.* $DOT_FILES_DIR/made/doc/.
else
  echo "ERROR: '$HOME/.cargo' not found"
fi
