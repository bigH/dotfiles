#!/usr/bin/env bash

__kubectl_select_one() {
  SUBJECT=pods
  if [ "$#" -gt 0 ]; then
    SUBJECT="$1"
  fi

  kubectl get "$@" | \
    fzf \
      --no-multi \
      --ansi \
      --header-lines=1 \
      --preview "kubectl get $SUBJECT {1} -o yaml | bat --color=always --language=yaml --style=plain" | \
    awk '{ print $1 }'
}

__kubectl_select_many() {
  SUBJECT=pods
  if [ "$#" -gt 0 ]; then
    SUBJECT="$1"
  fi

  kubectl get "$@" | \
    fzf \
      --multi \
      --ansi \
      --header-lines=1 \
      --preview "kubectl get $SUBJECT {1} -o yaml | bat --color=always --language=yaml --style=plain" | \
    awk '{ print $1 }'
}
