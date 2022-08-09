# shellcheck disable=2016

export SIGGY_GLOBAL_USAGE='
Usage:

  siggy [...]

Subcommands:



Examples:

  Set up siggy for the first time:
    $ siggy setup

  Wait for a signal
    $ siggy wait foo

  Send a signal
    $ siggy send foo <optional payload>

  Run a command, culminating in a signal that includes exit code
    $ siggy send foo

Configuration:

'
