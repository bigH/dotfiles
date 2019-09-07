#!/bin/bash

cd $DOT_FILES_DIR/ripgrep
rm -rf target/*
cargo clean -q
cargo build --release -q

cp target/release/rg $DOT_FILES_DIR/made-bin
