#!/usr/bin/env bash

if [ -z "$KUBECTL_YAML_VIEWER" ]; then
  KUBECTL_YAML_VIEWER="less"
  if command_exists bat; then
    KUBECTL_YAML_VIEWER="bat --color=always --language=yaml --style=plain"
  fi
fi

__kubectl_select_one() {
  SUBJECT=pods
  if [ "$#" -gt 0 ]; then
    SUBJECT="$1"
    shift
  fi

  ARGS="$([ $# -eq 0 ] && printf '' || printf '%q ' "$@")"

  kubectl get "$SUBJECT" "$@" | \
    fzf \
      --no-multi \
      --ansi \
      --header-lines=1 \
      --preview "kubectl get $SUBJECT $ARGS {1} -o yaml | $KUBECTL_YAML_VIEWER" | \
    awk '{ print $1 }'
}

__kubectl_select_resource_type() {
  ARGS="$([ $# -eq 0 ] && printf '' || printf '%q ' "$@")"

  kubectl api-resources "$@" | \
    fzf \
      --no-multi \
      --ansi \
      --header-lines=1 \
      --preview "kubectl get {1} $ARGS | $KUBECTL_YAML_VIEWER" | \
    awk '{ print $1 }'
}

__kubectl_select_many() {
  SUBJECT=pods
  if [ "$#" -gt 0 ]; then
    SUBJECT="$1"
    shift
  fi

  ARGS="$([ $# -eq 0 ] && printf '' || printf '%q ' "$@")"

  kubectl get "$SUBJECT" "$@" | \
    fzf \
      --multi \
      --ansi \
      --header-lines=1 \
      --preview "kubectl get $SUBJECT $ARGS {1} -o yaml | $KUBECTL_YAML_VIEWER" | \
    awk '{ print $1 }'
}

__kubectl_select_context() {
  CURRENT_CONTEXT_INFO='
  Current Context: '"$RED$BOLD$(kubectl config current-context)$NORMAL"'
  '

  kubectl config get-contexts -o name | \
      fzf +m \
        --header "$CURRENT_CONTEXT_INFO" \
        --no-preview
}
