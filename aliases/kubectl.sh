#!/usr/bin/env bash

alias k='kubectl-wrapper'
alias kg='kubectl-wrapper --log-context get'
alias ke='kubectl-wrapper --log-context edit'
alias kd='kubectl-wrapper --log-context describe'
alias kl='kubectl-wrapper --log-context logs'
alias kc='kubectl-wrapper config'

alias kcc='kubectl config current-context'

kv() {
  kubectl-wrapper --log-context get -o yaml "$@" | bat --language=yaml --style=plain
}

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

kdiff() {
  LEFT="$1"
  RIGHT="$2"

  shift
  shift

  diff -u <(kubectl "--context=$LEFT" "$@") <(kubectl "--context=$RIGHT" "$@")
}

kbash() {
  POD_NAME=$(__kubectl_select_one pod "$@")
  if [ -n "$POD_NAME" ]; then
    log_info "selected '$POD_NAME'"
    kubectl exec -it "$POD_NAME" "$@" bash
  else
    log_warning "no pod selected"
  fi
}
