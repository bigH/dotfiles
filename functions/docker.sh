dclean() {
  local docker_command
  local search_filter

  if [ "$#" -eq 2 ]; then
    docker_command="$1"
    search_filter="$2"
  elif [ "$#" -eq 1 ]; then
    docker_command="$1"
    search_filter=""
  elif [ "$#" -eq 0 ]; then
    COMMAND_SELECTION_OUTPUT="$(
      echo "volume\ncontainer\nimage\nnetwork" \
        | fzf +m --print-query --phony --preview 'docker {1} ls | grep -F --color=always {q}'
    )"
    search_filter="$(echo "${COMMAND_SELECTION_OUTPUT}" | head -1)"
    docker_command="$(echo "${COMMAND_SELECTION_OUTPUT}" | tail -n +2)"
  fi

  if [ -n "$docker_command" ]; then
    if [ "$docker_command" = "volume" ]; then
      ID_COLUMN="{2}"
    elif [ "$docker_command" = "image" ]; then
      ID_COLUMN="{3}"
    else
      # container and network
      ID_COLUMN="{1}"
    fi

    docker "${docker_command}" ls | tail -n +2 \
      | fzf --exact -q "$search_filter" -m -n2 --preview "docker '$docker_command' inspect {2} | bat --language=json" \
      | awk '{print $2}' | xargs docker "$docker_command" rm
  else
    log_warning "no command selected"
  fi
}

