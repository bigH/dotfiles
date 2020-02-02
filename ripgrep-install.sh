#!/bin/bash

set -e

cd $DOT_FILES_DIR/ripgrep
rm -rf target/*

if [ -d "$HOME/.cargo" ]; then
  source "$HOME/.cargo/env"
  cargo clean -q
  cargo build --release -q

  cp target/release/rg $DOT_FILES_DIR/made/bin/.
  cp rg.1.en.gz $DOT_FILES_DIR/made/doc/man1/.
else
  echo "ERROR: '$HOME/.cargo' not found"
fi
