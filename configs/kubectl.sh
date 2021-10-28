#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  source <(kubectl completion zsh)
  if command_exists stern; then
    source <(stern --completion=zsh)
  fi
elif [[ "$SHELL" == *'bash' ]]; then
  source <(kubectl completion bash)
  if command_exists stern; then
    source <(stern --completion=bash)
  fi
fi

