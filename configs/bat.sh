#!/usr/bin/env bash

export BAT_STYLE='changes,numbers'
if bat --list-themes | grep gruvbox 2>&1 > /dev/null; then
  export BAT_THEME='gruvbox'
else
  export BAT_THEME='zenburn'
fi
