#!/usr/bin/env bash

if command_exists helm; then
  if [[ "$SHELL" == *'zsh' ]]; then
    source <(helm completion zsh)
  elif [[ "$SHELL" == *'bash' ]]; then
    source <(helm completion bash)
  fi
fi

if command_exists helm2; then
  if [[ "$SHELL" == *'zsh' ]]; then
    source <(helm2 completion zsh)
  elif [[ "$SHELL" == *'bash' ]]; then
    source <(helm2 completion bash)
  fi
fi

if command_exists helm3; then
  if [[ "$SHELL" == *'zsh' ]]; then
    source <(helm3 completion zsh)
  elif [[ "$SHELL" == *'bash' ]]; then
    source <(helm3 completion bash)
  fi
fi
