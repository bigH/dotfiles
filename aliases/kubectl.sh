#!/usr/bin/env bash

if [ -d "$DOT_FILES_DIR/kube-fuzzy" ]; then
  source "$DOT_FILES_DIR/kube-fuzzy/extras.sh"
fi

alias kgpo="kube-fuzzy get pods"
