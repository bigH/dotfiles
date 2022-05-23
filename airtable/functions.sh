#!/usr/bin/env bash

db() {
  mysql -u root -proot "$@"
}

migrate()     {
  (cd "$HYPERBASE_DEV_PATH" && grunt admin:db:migrate | bin/bunyan)
}

dev() {
  (cd "$HYPERBASE_DEV_PATH" && ./node_modules/.bin/nf start)
}

devinfo() {
  (cd "$HYPERBASE_DEV_PATH" && BUNYAN_LOG_LEVEL=info ./node_modules/.bin/nf start)
}

devdebug() {
  (cd "$HYPERBASE_DEV_PATH" && BUNYAN_LOG_LEVEL=debug ./node_modules/.bin/nf start)
}

devweb() {
  (cd "$HYPERBASE_DEV_PATH/web_service/" && ./DEVELOPMENT_run_web.sh)
}

devworker() {
  (cd "$HYPERBASE_DEV_PATH/worker_service/" &&  ./DEVELOPMENT_run_single_worker.sh)
}

devbuilder() {
  (cd "$HYPERBASE_DEV_PATH/block_builder_service/" && ./DEVELOPMENT_run_block_builder_service.sh)
}

devrealtime() {
  (cd "$HYPERBASE_DEV_PATH/realtime_service/" && ./DEVELOPMENT_run_realtime.sh)
}

bll_list() {
  echo 'trace'
  echo 'debug'
  echo 'info'
  echo 'warn'
  echo 'error'
  echo 'fatal'
}

bll() {
  BUNYAN_LOG_LEVEL="$(bll_list | fzf +m --preview-window=hidden)"
  if [ -z "$BUNYAN_LOG_LEVEL" ]; then
    BUNYAN_LOG_LEVEL=info
  fi
  export BUNYAN_LOG_LEVEL
}

blf_list() {
  echo 'long: (the default) pretty'
  echo 'json: JSON output, 2-space indent'
  echo 'json-4: JSON output, 4-space indent'
  echo "bunyan: 0 indented JSON, bunyan\'s native format"
  echo 'inspect: node.js `util.inspect` output'
  echo 'short: like "long", but more concise'
  echo 'simple: level, followed by "-" and then the message'
}

blf() {
  BUNYAN_FORMAT="$(blf_list | fzf +m --preview-window=hidden | cut -d':' -f1)"
  export BUNYAN_FORMAT
}

teams() {
  yq -M 'keys | .[]' "$HYPERBASE_DEV_PATH/TEAMS.yaml"
}

test_owners_json() {
  (cd "$HYPERBASE_DEV_PATH" && "bin/who_owns.js" --json $(fd '.*\.(spec|test)\.tsx'))
}

owner_stats() {
  test_owners_json |
    jq -r '.[] | .team // "NO_OWNER"' |
    sort |
    uniq -c |
    sort -nr
}

list_owners() {
  test_owners_json |
    jq -r '.[] | .path + "%" + (.team // "None")' |
    sort |
    column -t -s '%'
}

browse_owners() {
  # shellcheck disable=2046,2086
  list_owners |
    eval "h None 'team-.*' team-dev-effectiveness team-core-product" |
    fzf --ansi -m --preview-window=hidden
}

select_unowned() {
  # shellcheck disable=2046,2086
  test_owners_json |
    jq -r '.[] | select(.team == null) | .path' |
    sort |
    fzf --ansi -m --preview-window=hidden
}

rehyperdb() {
  if [ "$PWD" = "$(cd "$HYPERBASE_DEV_PATH" && pwd)" ]; then
    silently_run_and_report mysql -u root -proot -e "DROP DATABASE hyperbase_app;"
    silently_run_and_report mysql -u root -proot -e "DROP DATABASE hyperbase_app_live_001;"
    silently_run_and_report mysql -u root -proot -e "DROP DATABASE hyperbase_app_realtime_001;"
    silently_run_and_report mysql -u root -proot -e "DROP DATABASE hyperbase_app_realtime_002;"

    silently_run_and_report grunt admin:db:createShard --mysqlEndpoint=localhost --dbShardRole=main --dbShardId=dbsMAIN0000000000 --dbShardState=active
    silently_run_and_report grunt admin:db:createShard --mysqlEndpoint=localhost --dbShardRole=applicationLive --dbShardId=dbsAPPLIVE0000001 --dbShardState=active
    silently_run_and_report grunt admin:db:createShard --mysqlEndpoint=localhost --dbShardRole=realtime --dbShardId=dbsREALTIME000001 --dbShardState=active
    silently_run_and_report grunt admin:db:createShard --mysqlEndpoint=localhost --dbShardRole=realtime --dbShardId=dbsREALTIME000002 --dbShardState=active

    silently_run_and_report grunt admin:db:migrate

    silently_run_and_report mysql -uroot -proot -e "INSERT INTO hyperbase_app._adminFlags (name, value) VALUES ('NEW_APPLICATIONS_LIVE_SHARD_IDS', '[\"dbsAPPLIVE0000001\"]'), ('QUALITY_OF_SERVICE_LEVEL_TO_REALTIME_SHARD_ID_MAPPING', '{\"normal\":\"dbsREALTIME000001\",\"high\":\"dbsREALTIME000002\"}');"

    echo "${BOLD}NOTE:${NORMAL} ${GREY}... below command takes some time ...${NORMAL}"
    silently_run_and_report grunt admin:explore:pullFromProduction --templateSyncMode=all --universeSyncMode=some
  else
    log_error "you must be in the \`\$HYPERBASE_DEV_PATH\` (\`$HYPERBASE_DEV_PATH\`)"
  fi
}

ci_activate_python_environment() {
    DESIRED_VENV="$HYPERBASE_DEV_PATH/ci/py/.pyenv"

    if [ "$VIRTUAL_ENV" = "$DESIRED_VENV" ]; then
        log_info "already active: venv at $VIRTUAL_ENV"
    else
        if [ -n "$VIRTUAL_ENV" ]; then
            log_info "deactivating: venv at $VIRTUAL_ENV"
            deactivate
        fi

        if [ -d "$DESIRED_VENV" ]; then
            log_info "activating: venv at $DESIRED_VENV"
            # shellcheck disable=1091
            . "$DESIRED_VENV/bin/activate"
        else
            log_info "creating: venv at $DESIRED_VENV"
            python3 -m venv "$DESIRED_VENV"

            log_info "activating: venv at $DESIRED_VENV"
            # shellcheck disable=1091
            . "$DESIRED_VENV/bin/activate"

            log_info "setting up: venv at $DESIRED_VENV"
            pip install -r requirements-dev.txt
        fi
    fi
}

ci_load_tokens_from_aws_secrets() {
    indent --header "$HYPERBASE_DEV_PATH/bin/get-aws-creds" --stage development --role AirtableDeveloperAdminAccessViaOkta --type hyperbase

    GITHUB_AUTH_TOKEN="$(aws --profile=hyperbase_development_AirtableDeveloperAdminAccessViaOkta secretsmanager get-secret-value --region=us-west-2 --secret-id=/github/CI_PY_TESTS_GITHUB_AUTH_TOKEN | jq -r .SecretString)"
    export GITHUB_AUTH_TOKEN

    SLACK_TOKEN="$(aws --profile=hyperbase_development_AirtableDeveloperAdminAccessViaOkta secretsmanager get-secret-value --region=us-west-2 --secret-id=/github/JENKINS_SLACK_TOKEN | jq -r .SecretString)"
    export SLACK_TOKEN
}

cienv() {
    if [ "$1" = '--full' ]; then
        ci_load_tokens_from_aws_secrets
    fi

    ci_activate_python_environment
}

# NOTES:
# I used this to diff 2 dependency graphs that may have been created with file
# scan order being different or had incremental updates while being captured on
# the same code state.
#
# After saving this I discovered `jd` a JSON diff tool that provides the option
# to treat arrays as sets and specify keys for which this needs to be done.
#
# $1 and $2 are files
dependency_graph_same() {
  QUERY='{
    reversedDependencies: (
        .reversedDependencies |
            to_entries |
            map({key: .key, value: (.value | sort)}) |
            from_entries
    ),
    dependencies: (
        .dependencies |
            to_entries |
            map({key: .key, value: (.value | sort)}) |
            from_entries
    )
  }'
  diff -u <(jq -MS "$QUERY" "$1") <(jq -MS "$QUERY" "$2") |
    delta --side-by-side --default-language JSON
}

# NOTES:
# I used this to verify that the partial dependency graph saved (when pressing
# Ctrl-C) had all dependencies of a file listed correctly both when a complete
# dependency graph is dumped and an incomplete one is
#
# $1 is the source of file list
# $2 is being checked against this
dependency_graph_same_by_file() {
  QUERY='{
    dependencies: (
      .dependencies["{1}"] |
        sort
    ),
    reversedDependencies: (
      .reversedDependencies |
        to_entries |
        map(
          select(
            .value |
              map(. == "{1}") |
              any
          ) |
          .key
        ) |
        sort
    ),
  }'
  jq -r '.dependencies | keys | sort | .[]' "$1" |
    fzf -m --preview-window="bottom:80%:wrap" \
        --preview="\
          echo {1}; \
          echo; \
          diff --new-line-format='+%L' --old-line-format='-%L' --unchanged-line-format=' %L' \
            <(jq -CS '$QUERY' '$1') \
            <(jq -CS '$QUERY' '$2') | \
          delta --default-language=json --color-only"
}
