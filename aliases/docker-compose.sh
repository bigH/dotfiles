#!/usr/bin/env bash

# `docker-compose` -> `dc`
if type docker-compose >/dev/null 2>&1; then
  alias dc=docker-compose
fi
