#!/usr/bin/env bash

gf_helper_diff_direct_menu_content() {
  QUERY="$1"
  shift
  if [ -z "$QUERY" ]; then
    gf_git_command_with_header diff --name-only "$@"
  else
    gf_git_command_with_header diff -G "$QUERY" --name-only "$@"
  fi
}

gf_helper_diff_direct_preview_content() {
  QUERY=""
  if [ -n "$1" ]; then
    # shellcheck disable=2089
    QUERY="$1"
  fi
  shift

  FILE_PATH=""
  if [ -n "$1" ]; then
    # shellcheck disable=2089
    FILE_PATH="$1"
  fi
  shift

  if [ -z "$QUERY" ]; then
    # shellcheck disable=2086,2090
    gf_git_command_with_header diff "$@" -- $FILE_PATH | diff-so-fancy
  else
    # shellcheck disable=2086,2090
    gf_git_command_with_header diff "$@" -- $FILE_PATH | diff-so-fancy | grep --color=always -E "$QUERY|$"
  fi
}
