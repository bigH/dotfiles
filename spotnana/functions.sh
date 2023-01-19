#!/usr/bin/env bash

jb() {
  cd "$HOME/dev/spotnana/spotnana"
}

jf() {
  cd "$HOME/dev/spotnana/spotnana-frontend/src/react"
}

spot-docker() {
  cd "$HOME/dev/spotnana/spotnana/src/devcluster"
  docker-compose down
  docker ps -q | xargs docker container stop
  docker-compose up
}

spot-docker() {
  cd "$HOME/dev/spotnana/spotnana/src/devcluster"
  docker-compose down
  docker ps -q | xargs docker container stop
  docker-compose up
}
