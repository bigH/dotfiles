#!/usr/bin/env bash

alias gaaa='
  indent --header git add --all;
  indent --header pre-commit;
  indent --header git add --all;
  indent --header pre-commit'

alias gaaas='gaaa; gs'
