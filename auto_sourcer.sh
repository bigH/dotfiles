#!/usr/bin/env bash

# TODO: tune; currently, check every prompt while debugging
export AUTO_SOURCER_CHECK_INTERVAL="10"
export AUTO_SOURCING_FILE_CHANGED=""
export AUTO_SOURCED_FILES=""

# NB: Auto-Sourcing this file will clobber auto-sourcing data this prevents the
# file from being sourced more than once in a given shell
if [ -z "$AUTO_SOURCED_FILES" ] ; then
  # NB: these cannot be an `export` because we don't want it propagating to
  # child shells
  AUTO_SOURCER_LAST_CHECK=""
  AUTO_SOURCED_FILES=" "

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
      if [[ "$AUTO_SOURCED_FILES" != *" $1 "* ]]; then
        AUTO_SOURCED_FILES+="$1 "
      fi
    fi
  }

  last_mtime() {
    if [ -z "$1" ]; then
      echo "ERROR: specify a file to source."
    else
      # NB: first try `gstat` which is installed by `brew` for `coreutils` to
      # not clobber existing `macOS` utilities
      if type gstat >/dev/null 2>&1; then
        gstat -c %Y "$1"
      else
        stat -c %Y "$1"
      fi
    fi
  }

  auto_source_check_and_reload_sources() {
    NOW_UTC="$(date +%s)"
    NEXT_CHECK_TIME="$(echo "$AUTO_SOURCER_LAST_CHECK + $AUTO_SOURCER_CHECK_INTERVAL" | bc)"

    # only check after interval
    if [ "$NOW_UTC" -gt "$NEXT_CHECK_TIME" ]; then
      AUTO_SOURCING_FILE_CHANGED="YES"
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
      AUTO_SOURCING_FILE_CHANGED=""
      AUTO_SOURCER_LAST_CHECK="$NOW_UTC"
    fi
  }

  auto_source_initialize() {
    AUTO_SOURCER_LAST_CHECK="$(date +%s)"
  }
fi
