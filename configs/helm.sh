#!/usr/bin/env bash

if type helm >/dev/null 2>&1; then
  if [[ "$SHELL" == *'zsh' ]]; then
    source <(helm completion zsh)
  elif [[ "$SHELL" == *'bash' ]]; then
    source <(helm completion bash)
  fi
fi

if type helm2 >/dev/null 2>&1; then
  if [[ "$SHELL" == *'zsh' ]]; then
    source <(helm2 completion zsh)
  elif [[ "$SHELL" == *'bash' ]]; then
    source <(helm2 completion bash)
  fi
fi

if type helm3 >/dev/null 2>&1; then
  if [[ "$SHELL" == *'zsh' ]]; then
    source <(helm3 completion zsh)
  elif [[ "$SHELL" == *'bash' ]]; then
    source <(helm3 completion bash)
  fi
fi
