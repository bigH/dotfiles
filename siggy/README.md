Siggy
=====

Siggy is a very light-weight signaling application. You can use it for personal setups where you want to link what two programs are doing.

I used it to have `iTerm` send events to all the running vim processes such that if I click `foo/bar/baz.py:123`, any vim process that has that inside their CWD, opens it and navigates to that file.

It's a handy tool for me and dead-simple to run. The point is for it to take up minimal cycles on my machine and be absolute bare-bones.

## QuickStart

TODO

## Installation

TODO

## Usage

Here's a simple example of a few programs that talk to eachother
```
# start siggy daemon on port defined XXXXXXXXXXXXXXX
siggy --serve &

# start a listener with a channel name that is the current directory
# run `echo <message>`
siggy  --listen --channel "$(pwd)" -- echo

# listen to file changes
find . | entr siggy --channel "$(pwd)" --send \_
```

Now you can have events indicating file changes sent to your listener. The idea here is to support integration with arbitrary programs.

### Non-Goals**

- Reliability: This program is meant for personal use. Any time the daemon is found not running, all commands fail and the user can simply restart it. If you want reliability, run it in a loop.

