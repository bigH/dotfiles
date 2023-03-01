dclean() {
  if [ "$#" -gt 0 ]; then
    COMMAND="$1"
    shift
  else
    COMMAND_SELECTION_OUTPUT="$(
      echo "volume\ncontainer\nimage\nnetwork" \
        | fzf +m --print-query --phony --preview 'docker {1} ls | grep -F --color=always {q}'
    )"
    FILTER="$(echo "${COMMAND_SELECTION_OUTPUT}" | head -1)"
    COMMAND="$(echo "${COMMAND_SELECTION_OUTPUT}" | tail -n +2)"
  fi

  if [ -z "$FILTER" ]; then
    FILTER=""

    if [ "$#" -gt 0 ]; then
      FILTER="$1"
      shift
    fi
  fi

  if [ -n "$COMMAND" ]; then
    if [ "$COMMAND" = "volume" ]; then
      ID_COLUMN="{2}"
    elif [ "$COMMAND" = "image" ]; then
      ID_COLUMN="{3}"
    else
      # container and network
      ID_COLUMN="{1}"
    fi

    docker "${COMMAND}" ls | tail -n +2 \
      | fzf --exact -q "$FILTER" -m -n2 --preview "docker '$COMMAND' inspect {2} | bat --language=json" \
      | awk '{print $2}' | xargs docker "$COMMAND" rm
  else
    log_warning "no command selected"
  fi
}

