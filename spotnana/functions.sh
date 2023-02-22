#!/usr/bin/env bash

jb() {
  cd "$SPOTNANA_BACKEND"
}

jf() {
  cd "$HOME/dev/spotnana/spotnana-frontend/src/react"
}

spot-docker() {
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
    docker-compose --profile kafka-ui up
  el  else
    docker-compose "$@" up
  fi
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

mci() {
  m clean install
}
