#!/usr/bin/env bash

alias k='kubectl-wrapper'
alias kg='kubectl-wrapper --log-context get'
alias kd='kubectl-wrapper --log-context describe'
alias kl='kubectl-wrapper --log-context logs'
alias kc='kubectl-wrapper config'

alias kcc='kubectl config current-context'

kf() {
  # shellcheck disable=2016
  HELP_TEXT="
Usage:
  kf  <action> ...

  # interactively selects namespace to apply command to
  kfn <action> ...

  # interactively selects context to apply command to
  kfc <action> ...

Arguments:
  '--' splits the arg list into 3 useful parts
  '---' is equivalent to '-- --'

  kf <command> [type] [...global args] -- [...get args] -- [...action args]
  kf <command> [type] [...global args] --- [...action args]

  # For example, this command
  kf exec --context=foo -n bar --- -it psql

    # Delegates to this one for the list
    kubectl get pod --context=foo -n bar

    # Delegates to this one for the preview
    kubectl describe pod <selection> --context=foo -n bar -it psql

Commands:

  # interactively list and look at the YAML for some resource type (get + describe)
  kf get <type> [...args]

  # interactively select an item of resource type to edit
  kf edit <type> [...args]

  # interactively select a pod to execute a command against
  kf exec [...args]

Gotchas:

 - '--all-namespaces' will not work properly because forwarding namespace
   to later commands will not work - for that use 'kfn'
"

  if [ "$#" -eq 0 ]; then
    log_error "${BOLD}action${NORMAL} (exec, describe, etc.) is ${BOLD}required${NORMAL}"
    echo "$HELP_TEXT"
    return 1
  else
    # get action
    ACTION="$1"
    shift

    # split the arg list
    ARG_TYPE='0'

    ACTION_ARGS=()
    GET_ARGS=()

    if [ -n "$KUBECTL_FORCE_NAMESPACE" ]; then
      ACTION_ARGS+=(--namespace "$KUBECTL_FORCE_NAMESPACE")
      GET_ARGS+=(--namespace "$KUBECTL_FORCE_NAMESPACE")
    fi

    if [ -n "$KUBECTL_FORCE_CONTEXT" ]; then
      ACTION_ARGS+=(--context "$KUBECTL_FORCE_CONTEXT")
      GET_ARGS+=(--context "$KUBECTL_FORCE_CONTEXT")
    fi

    # some actions take a type
    case "$ACTION" in
      'get' | 'g' | 'describe' | 'd' | 'edit' | 'e')
        if [ "$#" -eq 0 ]; then
          log_warning "${BOLD}type${NORMAL} (pod, deploy, ing, svc, etc.) not provided; prompting..."
          TYPE="$(__kubectl_select_resource_type "${GET_ARGS[@]}")"
          if [ -z "$TYPE" ]; then
            log_error "${BOLD}type${NORMAL} (pod, deploy, ing, svc, etc.) not selected or provided"
            return 1
          fi
        else
          TYPE="$1"
          shift
        fi
        ;;
      'exec' | 'x')
        TYPE="pod"
        ;;
    esac

    for arg in "$@"; do
      if [ "$arg" = '--' ]; then
        ((ARG_TYPE+=1))
      elif [ "$arg" = '---' ]; then
        ((ARG_TYPE+=2))
      else
        if [ "$ARG_TYPE" -eq 0 ]; then
          ACTION_ARGS+=("$arg")
          GET_ARGS+=("$arg")
        elif [ "$ARG_TYPE" -eq 1 ]; then
          GET_ARGS+=("$arg")
        else
          ACTION_ARGS+=("$arg")
        fi
      fi
    done

    # get user's selected object
    SELECTION="$(__kubectl_select_one "$TYPE" "${GET_ARGS[@]}")"

    if [ -n "$SELECTION" ]; then
      case "$ACTION" in
        get | g)
          kubectl get -o yaml "$TYPE" "$SELECTION" "${ACTION_ARGS[@]}" | eval "$KUBECTL_YAML_VIEWER" ;;
        describe | d)
          kubectl describe "$TYPE" "$SELECTION" "${ACTION_ARGS[@]}" | eval "$KUBECTL_YAML_VIEWER" ;;
        edit | e)
          kubectl edit "$TYPE" "$SELECTION" "${ACTION_ARGS[@]}" ;;
        exec | x)
          kubectl exec "$SELECTION" "${ACTION_ARGS[@]}" ;;
        esac
    else
      log_warning "no $TYPE selected"
    fi
  fi
}

kfn() {
  KUBECTL_FORCE_NAMESPACE="$(__kubectl_select_one namespace)"
  if [ -n "$KUBECTL_FORCE_NAMESPACE" ]; then
    kf "$@"
  else
    log_warning "no namespace selected"
  fi
  unset KUBECTL_FORCE_NAMESPACE
}

kfc() {
  KUBECTL_FORCE_CONTEXT="$(__kubectl_select_context)"
  if [ -n "$KUBECTL_FORCE_CONTEXT" ]; then
    kf "$@"
  else
    log_warning "no context selected"
  fi
  unset KUBECTL_FORCE_CONTEXT
}

alias kfv='kf get'
alias kfg='kf get'
alias kfd='kf describe'
alias kfe='kf edit'
alias kfx='kf exec'

ksc() {
  KUBECTL_SELECTED_CONTEXT="$(__kubectl_select_context)"
  if [ -n "$KUBECTL_SELECTED_CONTEXT" ]; then
    kubectl config use-context "$KUBECTL_SELECTED_CONTEXT"
  else
    log_warning "no context selected"
  fi
}

ksn() {
  CURRENT_CONTEXT="$(kubectl config current-context)"
  KUBECTL_SELECTED_NAMESPACE="$(__kubectl_select_one namespace)"
  if [ -n "$KUBECTL_SELECTED_NAMESPACE" ]; then
    kubectl config set-context "$CURRENT_CONTEXT" --namespace "$KUBECTL_SELECTED_NAMESPACE"
  else
    log_warning "no namespace selected"
  fi
}

alias kscn='ksc ; ksn'

export KDIFF_RENDERER="command cat -"

kdiff() {
  LEFT="$1"
  RIGHT="$2"

  shift
  shift

  if [ -t 1 ] && [ -n "$DIFF_PAGER" ]; then
    diff -u <(eval "kubectl \"--context=$LEFT\" $(printf ' %q' "$@") | $KDIFF_RENDERER") \
            <(eval "kubectl \"--context=$RIGHT\" $(printf ' %q' "$@") | $KDIFF_RENDERER") \
            | eval "$DIFF_PAGER"
  else
    diff -u <(eval "kubectl \"--context=$LEFT\" $(printf ' %q' "$@") | $KDIFF_RENDERER") \
            <(eval "kubectl \"--context=$RIGHT\" $(printf ' %q' "$@") | $KDIFF_RENDERER")
  fi
}

# start a shell on a pod (treats args as query)
kbash() {
  POD_NAME="$(__kubectl_select_one pod "$@")"
  if [ -n "$POD_NAME" ]; then
    log_info "selected '$POD_NAME'"
    kubectl exec -it "$POD_NAME" "$@" bash
  else
    log_warning "no pod selected"
  fi
}

# really get _all_ the things (highlighting regexes provided as arguments)
kgetall() {
  QUERY="($([ $# -eq 0 ] && printf '' || printf '%s|' "$@")\$)"
  for i in $(kubectl api-resources --verbs=list -o name | sort | uniq); do
    echo
    echo "\$ kubectl get --all-namespaces --ignore-not-found ${i}"
    if [ -n "$QUERY" ]; then
      kubectl get --all-namespaces --ignore-not-found "${i}" | grep --color=always -E "$QUERY"
    else
      kubectl get --all-namespaces --ignore-not-found "${i}"
    fi
  done
}

# examine secrets as though they are certificates
kcert() {
  ARGS="$([ $# -eq 0 ] && printf '' || printf '%q ' "$@")"
  kubectl get secret "$@" | \
    fzf \
      --no-multi \
      --ansi \
      --header-lines=1 \
      --preview "echo {1} ; kubectl get secret {1} $ARGS -o jsonpath='{.data.tls\\.crt}' | xargs echo | base64 -D | openssl x509 -text -noout" | \
    awk '{ print $1 }'
}

# all kube events sorted by time (passes args to kubectl)
kube-events-sorted() {
  kubectl get event --all-namespaces --sort-by=".metadata.creationTimestamp" "$@"
}

# NB: make sure to escape double-quotes (!!!!!!!!!!!!!)
build_watchable_command() {
  local function_name="$1"
  local command_prefix="$2"
  local filter="$3"

  local command_string="$command_prefix \$([ \$# -eq 0 ] && printf '' || printf '%q' \"\$@\") | $filter"

  eval "$function_name() { eval \"$command_string\" }"
  eval "watch-$function_name() { watch \"$command_string\" }"
}

# build a table for all pods with status
KUBE_POD_COUNT_BY_IMAGE_COMMAND='kubectl get pods -o jsonpath=\"{range .items[*]}{.spec.containers[0].image}#{.metadata.labels.app}#{.status.phase}#{.status.reason}#{.status.message}{\\\"\n\\\"}{end}\"'
build_watchable_command 'kube-pod-count-by-image' "$KUBE_POD_COUNT_BY_IMAGE_COMMAND" 'sort | uniq -c | column -t -s \"#\"'

# build a table for all pods with status
KUBE_NODE_LAYOUT_COMMAND='kubectl get pods -o jsonpath=\"{range .items[?(@.status.phase==\\\"Running\\\")]}{.spec.nodeName}#{.status.hostIP}#{.metadata.name}#{.status.podIP}{\\\"\n\\\"}{end}\"'
build_watchable_command 'kube-node-layout' "$KUBE_NODE_LAYOUT_COMMAND" 'column -t -s \"#\" | sort'
