#!/usr/bin/env bash

## `rg` helpers

# `rg` + a pager
rgp() {
  rg "$@" --heading --line-number --color=always | less -R
}

# `rb` + `rg` + a pager
rbgp() {
  rgp "$@" -g '*.rb'
}

# `rb` + `rg`
rbg() {
  rg "$@" -g '*.rb'
}

