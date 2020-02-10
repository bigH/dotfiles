#!/usr/bin/env bash

# NB: Auto-Sourcing this file will clobber auto-sourcing data
# this prevents the file from being sourced more than once
if [ -z "$AUTO_SOURCED_FILES" ] ; then
  export AUTO_SOURCED_FILES=" "

  # TODO: tune; currently, check every prompt while debugging
  export AUTO_SOURCER_CHECK_INTERVAL="10"
  export AUTO_SOURCER_LAST_CHECK=""

  auto_source() {
    # TODO make sure to re-source only if it is changed
    if [ -z "$1" ]; then
      echo "ERROR: specify a file to source."
    else
      # use appropriate `source` command
      if type source >/dev/null 2>&1; then
        source "$1"
      else
        . "$1"
      fi

      # only record if not already present
      if [[ "$AUTO_SOURCED_FILES" != *"$1 "* ]]; then
        AUTO_SOURCED_FILES+="$1 "
      fi
    fi
  }

  last_mtime() {
    if [ -z "$1" ]; then
      echo "ERROR: specify a file to source."
    else
      if type gstat >/dev/null 2>&1; then
        # NB: expect local to contain `gstat` if `stat` is not GNU implementation
        # on `macOS`, this is achieved by installing coreutils
        # on `linux`, this won't exist and `stat` will work "correctly"
        gstat -c %Y "$1"
      else
        stat -c %Y "$1"
      fi
    fi
  }

  auto_source_check_sources_zsh() {
    NOW_UTC="$(date +%s)"
    if [ "$(echo "$AUTO_SOURCER_LAST_CHECK + $AUTO_SOURCER_CHECK_INTERVAL" | bc)" -lt "$NOW_UTC" ]; then
      for SOURCED_FILE in `echo $AUTO_SOURCED_FILES`; do
        if [[ "$SOURCED_FILE" == "$HOME"* ]]; then
          DISPLAY_PATH="~${SOURCED_FILE#"$HOME"}"
        fi
        if [ -e "$SOURCED_FILE" ] && [ "$(last_mtime "$SOURCED_FILE")" -gt "$AUTO_SOURCER_LAST_CHECK" ]; then
          # disrupts output from other commands
          # echo "\`$DISPLAY_PATH\` changed, resourcing..."
          auto_source "$SOURCED_FILE"
        fi
      done
      AUTO_SOURCER_LAST_CHECK="$NOW_UTC"
    fi
  }

  auto_source_initialize() {
    AUTO_SOURCER_LAST_CHECK="$(date +%s)"
    if [[ "$SHELL" == *'zsh' ]]; then
      precmd() {
        auto_source_check_sources_zsh
      }
    elif [[ "$SHELL" == *'bash' ]]; then
      echo "TODO: support bash in \`auto_source\`"
    else
      echo "ERROR: \`auto_source\` doens't support \`$SHELL\`"
    fi
  }
fi
