#!/usr/bin/env bash

jb() {
  cd "$SPOTNANA_BACKEND"
}

jf() {
  cd "$HOME/dev/spotnana/spotnana-frontend/src/react"
}

sd() {
  cd "$HOME/dev/spotnana/spotnana/src/devcluster"

  docker-compose down

  docker ps -q | \
    xargs docker container stop

  if [ "$#" -gt 0 ] && [ "$1" -eq "--clean" ]; then
    docker volume ls -q | \
      grep -db-data | \
      xargs docker volume rm
    shift
  fi

  if [ "$#" -eq 0 ]; then
    docker-compose --profile "$DEFAULT_DOCKER_COMPOSE_PROFILE" up
  else
    docker-compose "$@" up
  fi

  docker-compose down
}

sd-dbclean() {
  dclean volume db-data
}

m() {
  if [ "$#" -gt 0 ]; then
    (
      cd "$SPOTNANA_BACKEND/src/java" &&
      mvn -DskipTests -Dskip.agg.coverage=true -Dskip.git.commit.id.plugin=true "$@"
    )
  else
    log_error '`m` requires arguments'
  fi
}

mc() {
  m install
}

mi() {
  m install
}

mci() {
  m clean install
}

needs_recheck() {
  local checks_output="$(gh pr checks --required | cat -)"
  if ! [[ "$checks_output" == *"no required checks"* ]]; then
    return 0
  else
    return 1
  fi
}

rerun_checks() {
  (gh pr edit --remove-label 'RunAllTests' || true) &&
    gh pr edit --add-label 'RunAllTests'
}

recheck() {
  command_exists gh && needs_recheck && rerun_checks && pr_checks_watch
}

