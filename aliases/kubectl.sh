#!/usr/bin/env bash

alias k='kubectl-wrapper'
alias kg='kubectl-wrapper --log-context get'
alias kd='kubectl-wrapper --log-context describe'
alias kl='kubectl-wrapper --log-context logs'
alias kc='kubectl-wrapper config'

alias kcc='kubectl config current-context'

kf() {
  # shellcheck disable=2016
  HELP_TEXT='
Usage:
  kf  <action> ...

  # interactively selects namespace to apply command to
  kfn <action> ...

  # interactively selects context to apply command to
  kfc <action> ...

Arguments:
  `--` splits the arg list into 3 useful parts
  `---` is equivalent to `-- --`

  `kf <command> [type] [...global args] -- [...get args] -- [...action args]`
  `kf <command> [type] [...global args] --- [...action args]

  `kf exec --context=foo -n bar --- -it psql` results in:

    # loading the list of items
    `kubectl get pod --context=foo -n bar`

    # applying the action chosen to the selection
    `kubectl describe pod <selection> --context=foo -n bar -it psql`

Commands:

  # `kubectl get -o yaml`
  kf get <type> [...args]

  # `kubectl describe`
  kf describe <type> [...args]

  # `kubectl edit`
  kf edit <type> [...args]

  # `kubectl exec` (does not require a resource type)
  kf exec [...args]

Gotchas:

 - `--all-namespaces` will not work properly because forwarding namespace
   to later commands will not work - for that use `kfn`
'

  if [ "$#" -eq 0 ]; then
    log_error "${BOLD}action${NORMAL} (exec, describe, etc.) is ${BOLD}required${NORMAL}"
    echo "$HELP_TEXT"
  else
    # get action
    ACTION="$1"
    shift

    # some actions take a type
    case "$ACTION" in
      'get' | 'describe' | 'edit')
        if [ "$#" -eq 0 ]; then
          log_error "${BOLD}type${NORMAL} (pod, deploy, ing, svc, etc.) is ${BOLD}required${NORMAL}"
          echo "$HELP_TEXT"
        else
          TYPE="$1"
          shift
        fi
        ;;
      'exec')
        TYPE="pod"
        ;;
    esac

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
    echo __kubectl_select_one "$TYPE" "${GET_ARGS[@]}"
    SELECTION="$(__kubectl_select_one "$TYPE" "${GET_ARGS[@]}")"

    if [ -n "$SELECTION" ]; then
      case "$ACTION" in
        get)
          kubectl get -o yaml "$TYPE" "$SELECTION" "${ACTION_ARGS[@]}" | eval "$KUBECTL_YAML_VIEWER"
          ;;
        describe)
          kubectl describe "$TYPE" "$SELECTION" "${ACTION_ARGS[@]}" | eval "$KUBECTL_YAML_VIEWER" ;;
        edit)
          kubectl edit "$TYPE" "$SELECTION" "${ACTION_ARGS[@]}" ;;
        exec)
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
alias kfd='kf describe'
alias kfe='kf edit'
alias kfx='kf exec'

alias kfnv='kfn get'
alias kfnd='kfn describe'
alias kfne='kfn edit'
alias kfnx='kfn exec'

alias kfcv='kfc get'
alias kfcd='kfc describe'
alias kfce='kfc edit'
alias kfcx='kfc exec'

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

kdiff() {
  LEFT="$1"
  RIGHT="$2"

  shift
  shift

  if [ -t 1 ]; then
    diff -u <(kubectl "--context=$LEFT" "$@") <(kubectl "--context=$RIGHT" "$@") | eval "$DIFF_PAGER"
  else
    diff -u <(kubectl "--context=$LEFT" "$@") <(kubectl "--context=$RIGHT" "$@")
  fi
}

kbash() {
  POD_NAME="$(__kubectl_select_one pod "$@")"
  if [ -n "$POD_NAME" ]; then
    log_info "selected '$POD_NAME'"
    kubectl exec -it "$POD_NAME" "$@" bash
  else
    log_warning "no pod selected"
  fi
}

# build a table for all pods with status
kube-events-sorted() {
  kubectl get event --sort-by=".metadata.managedFields[0].time" "$@"
}

# NB: make sure to escape double-quotes (!!!!!!!!!!!!!)
build_watchable_command() {
  FUNCTION_NAME="$1"
  COMMAND_LINE="$2"
  FILTER="$3"

  eval "$FUNCTION_NAME() { eval \"$COMMAND_LINE \$(printf '%q' \"\$@\") | $FILTER\" }"
  eval "watch-$FUNCTION_NAME() { watch \"$COMMAND_LINE \$(printf '%q' \"\$@\") | $FILTER\" }"
}

# build a table for all pods with status
KUBE_POD_COUNT_BY_IMAGE_COMMAND='kubectl get pods -o jsonpath=\"{range .items[*]}{.spec.containers[0].image}#{.metadata.labels.app}#{.status.phase}#{.status.reason}#{.status.message}{\\\"\n\\\"}{end}\"'
build_watchable_command 'kube-pod-count-by-image' "$KUBE_POD_COUNT_BY_IMAGE_COMMAND" 'sort | uniq -c | column -t -s \"#\"'

# build a table for all pods with status
KUBE_NODE_LAYOUT_COMMAND='kubectl get pods -o jsonpath=\"{range .items[?(@.status.phase==\\\"Running\\\")]}{.spec.nodeName}#{.status.hostIP}#{.metadata.name}#{.status.podIP}{\\\"\n\\\"}{end}\"'
build_watchable_command 'kube-node-layout' "$KUBE_NODE_LAYOUT_COMMAND" 'column -t -s \"#\" | sort'
