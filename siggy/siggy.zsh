#!/bin/zsh

siggy() {
  # NB: we cannot export this and wouldn't want to
  SIGGY_LAST_COMMAND_EXIT_CODE=$? siggy-command "$@"
}
