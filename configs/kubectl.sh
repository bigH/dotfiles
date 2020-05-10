#!/usr/bin/env bash

if [[ "$SHELL" == *'zsh' ]]; then
  source <(kubectl completion zsh)
  if type stern >/dev/null 2>&1; then
    source <(stern --completion=zsh)
  fi
elif [[ "$SHELL" == *'bash' ]]; then
  source <(kubectl completion bash)
  if type stern >/dev/null 2>&1; then
    source <(stern --completion=bash)
  fi
fi

