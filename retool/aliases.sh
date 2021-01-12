#!/usr/bin/env bash

# goto retool directories
alias jret='[ -d "$RETOOL_DEV" ] && cd $RETOOL_DEV'
alias jfront='[ -d "$RETOOL_DEV" ] && cd $RETOOL_DEV/frontend'
alias jback='[ -d "$RETOOL_DEV" ] && cd $RETOOL_DEV/backend'
alias jku='[ -d "$RETOOL_DEV" ] && cd $RETOOL_DEV/retool-k8s'

# run front-end
alias yy='jham && _yy'
alias yyy='jham && _yyy'

# run back-end
alias rr='jret && _rr'
alias rrr='jret && _rrr'
