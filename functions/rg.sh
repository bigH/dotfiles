#!/usr/bin/env bash

## `rg` helpers

# `rg` w/ clipboard term
rgp() {
  log_command rg "$(pbpaste)" "$@"
  rg "$(pbpaste)" "$@"
}
