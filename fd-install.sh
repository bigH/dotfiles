#!/bin/bash

set -e

cd $DOT_FILES_DIR/fd
rm -rf target/*
cargo clean -q
cargo build --release -q

cp target/release/fd $DOT_FILES_DIR/made-bin
