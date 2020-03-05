#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  source <(helm completion zsh)
elif [[ "$SHELL" == *'bash' ]]; then
  source <(helm completion bash)
fi
