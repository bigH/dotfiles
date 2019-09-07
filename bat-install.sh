#!/bin/bash

cd $DOT_FILES_DIR/bat
rm -rf target/*
cargo clean -q
cargo build --release -q

cp target/release/bat $DOT_FILES_DIR/made-bin
