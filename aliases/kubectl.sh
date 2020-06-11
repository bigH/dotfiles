#!/usr/bin/env bash

alias k='kubectl-wrapper'
alias kg='kubectl-wrapper --log-context get'
alias kd='kubectl-wrapper --log-context describe'
alias kl='kubectl-wrapper --log-context logs'
alias kc='kubectl-wrapper config'

alias kcc='kubectl config current-context'

ksc() {
  CURRENT_CONTEXT_INFO='
  Current Context: '"$RED$BOLD$(kubectl config current-context)$NORMAL"'
  '
  kubectl config get-contexts | \
    cut -c11- | \
    awk '{ print $1 }' | \
    tail +2 | \
    fzf +m \
      --header "$CURRENT_CONTEXT_INFO" \
      --no-preview | \
    xargs kubectl config use-context
}

ksn() {
  CURRENT_CONTEXT_INFO='
  Current Context: '"$RED$BOLD$(kubectl config current-context)$NORMAL"'
  '
  kubectl get namespaces | \
    awk '{ print $1 }' | \
    tail +2 | \
    fzf +m \
      --header "$CURRENT_CONTEXT_INFO" \
      --no-preview | \
      xargs kubectl config set-context "$(kubectl config current-context)" --namespace
}
