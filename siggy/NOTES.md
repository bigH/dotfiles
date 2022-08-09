```
# clear all the signals
siggy clear

# send signal based on command
siggy ensure bob <command> [args]

# send particular payload
siggy send bob <payload>

# send status code of last command
siggy send bob $?

# expect particular payload
siggy wait bob[:<payload>]

# expect anything but particular payload
siggy wait bob[:^<payload>]

# expect multiple signals before continuing
siggy wait bob[:<payload>] lisa[:<payload>]

# signals can only be spent once; so you can namespace them however useful:
siggy ... $JOB_NAME.bob

siggy ... $JOB_NAME.bob
```
