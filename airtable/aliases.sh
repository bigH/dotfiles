alias ja='cd $HYPERBASE_DEV_PATH'
alias web='open https://hyperbasedev.com:3000/'

# canonical aliases for the use of others
alias opendev='open https://hyperbasedev.com:3000/'
alias godev='cd $HYPERBASE_DEV_PATH'

# a-cli development alias
alias jac='cd $A_CLI_DEV_PATH'

alias adev='echo "alias a=\"$A_CLI_DEV_PATH/bin/run\"" > $DOT_FILES_DIR/airtable/a_alias.sh'
alias aprod='echo "alias a=\"command a\"" > $DOT_FILES_DIR/airtable/a_alias.sh'

auto_source "$DOT_FILES_DIR/airtable/a_alias.sh"
