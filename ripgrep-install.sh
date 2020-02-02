#!/bin/bash

set -e

cd $DOT_FILES_DIR/ripgrep
rm -rf target/*

if [ -d "$HOME/.cargo" ]; then
  source "$HOME/.cargo/env"
  cargo clean -q
  cargo build --release -q

  cp target/release/rg $DOT_FILES_DIR/made/bin/.
  cp doc/rg.* $DOT_FILES_DIR/made/doc/.
else
  echo "ERROR: '$HOME/.cargo' not found"
fi
