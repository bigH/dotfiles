#!/usr/bin/env bash

# goto retool directories
alias jham='[ -d "$RETOOL_DEV" ] && cd $RETOOL_DEV/hammerhead'
alias jret='[ -d "$RETOOL_DEV" ] && cd $RETOOL_DEV/retool'

# run front-end
alias yy='jham && _yy'
alias yyy='jham && _yyy'

# run back-end
alias rr='jret && _rr'
alias rrr='jret && _rrr'
