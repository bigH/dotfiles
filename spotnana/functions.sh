#!/usr/bin/env bash

jb() {
  cd "$SPOTNANA_BACKEND"
}

jf() {
  cd "$HOME/dev/spotnana/spotnana-frontend/src/react"
}

sdc() {
  docker-compose -f "$SPOTNANA_DEVCLUSTER_DOCKER_COMPOSE_FILE" "$@"
}

sd() {
  # extra down in case
  sdc down

  docker ps -q | \
    xargs docker container stop

  if [ "$#" -gt 0 ] && [ "$1" -eq "--clean" ]; then
    docker volume ls -q | \
      grep -db-data | \
      xargs docker volume rm
    shift
  fi

  if [ "$#" -eq 0 ]; then
    sdc --profile "$DEFAULT_DOCKER_COMPOSE_PROFILE" up
  else
    sdc "$@" up
  fi

  # extra down in case
  sdc down
}

sdbclean() {
  dclean volume db-data
}

if command_exists yq; then
  spg() {
    local selection
    if [ -n "$1" ]; then
      selection="$1"
    else
      selection="$(yq \
        '.services | keys | .[] | select(. == "*-db")' \
        "$SPOTNANA_DEVCLUSTER_DOCKER_COMPOSE_FILE" |
        fzf +m --preview-window=hidden)"
      
      if [ -z "$selection" ]; then
        log_warning "no selection made"
        return 1
      fi
    fi

    local user="$(yq ".services.$selection.environment.POSTGRES_USER" "$SPOTNANA_DEVCLUSTER_DOCKER_COMPOSE_FILE")"
    local db="$(yq ".services.$selection.environment.POSTGRES_DB" "$SPOTNANA_DEVCLUSTER_DOCKER_COMPOSE_FILE")"
    local port="$(yq ".services.$selection.command | split(\" \") | .[1]" "$SPOTNANA_DEVCLUSTER_DOCKER_COMPOSE_FILE")"

    sdc exec -it "$selection" psql -U "$user" -d "$db" -p "$port"
  }
fi

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
  m clean
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

leo_prop_path() {
  if [ "$#" -eq 0 ]; then
    log_error "no property ID provided."
    return 1
  fi

  local id="$1"
  local prop_path="$HOME/dev/random/leonardo/property-$id.xml"

  echo "$prop_path"
}

leo_prop() {
  if [ "$#" -eq 0 ]; then
    log_error "no property ID provided."
    return 1
  fi

  local id="$1"
  local prop_path="$(leo_prop_path "$id")"

  if [ -f "$prop_path" ]; then
    xq --color "$prop_path" | less -REX
  else
    curl -X POST https://arcapi.leonardoworldwide.net/arc-api/standard/ \
      -d '<?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <Content>
          <Header>
            <BucketType>GetOMSPropertyWithMediaRQ</BucketType>
            <ApiKey>'"$LEO_API_KEY"'</ApiKey>
          </Header>
          <Body>
            <PropertyId>'"$id"'</PropertyId>
          </Body>
      </Content>' | xq > "$prop_path"
    leo_prop "$id"
  fi
}

leo_props() {
  local leo_props_path="$HOME/dev/random/leonardo/"

  rg -l --color=always "^" "$leo_props_path" |
    fzf +m --ansi --no-height --phony \
      $FZF_DEFAULT_OPTS_MULTI \
      --bind "change:reload(rg -l --color=always {q} '$leo_props_path')" \
      --preview "xq --color {}" \
      --preview-window "wrap:70%"
}
