#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  source <(kubectl completion zsh)
elif [[ "$SHELL" == *'bash' ]]; then
  source <(kubectl completion bash)
fi
