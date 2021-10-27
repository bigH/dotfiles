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
  export BUNYAN_LOG_LEVEL="$(bll_list | fzf +m --preview-window=hidden)"
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
  export BUNYAN_FORMAT="$(blf_list | fzf +m --preview-window=hidden | cut -d':' -f1)"
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
