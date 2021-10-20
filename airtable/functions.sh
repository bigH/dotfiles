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
