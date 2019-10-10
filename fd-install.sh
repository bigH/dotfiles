#!/bin/bash

set -e

cd $DOT_FILES_DIR/fd
rm -rf target/*

if [ -d "$HOME/.cargo" ]; then
  source "$HOME/.cargo/env"
  cargo clean -q
  cargo build --release -q

  cp target/release/fd $DOT_FILES_DIR/made-bin
else
  echo "ERROR: '$HOME/.cargo' not found"
fi
