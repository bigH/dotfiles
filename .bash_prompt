#!/usr/bin/env bash

# Clean and minimalistic Bash prompt
# Stolen from https://github.com/sapegin/dotfiles/blob/dd063f9c30de7d2234e8accdb5272a5cc0a3388b/includes/bash_prompt.bash

# Highly special-cased (1) to run on remote nodes (2) assumes never using `git`

# User color
case $(id -u) in
  0) USER_COLOR="${RED}${BOLD}" ;;  # root
  *) USER_COLOR="${CYAN}${BOLD}" ;;
esac

# Symbols
USER_HOST_DELIMITER="$(printf "\xE2\x91\x8A")"
HOST_PATH_DELIMITER="$(printf "\xE2\x8B\xAF") "
PROMPT_SYMBOL="$(printf "\xE2\x9D\xAF")"

function prompt_command() {
  # Only show username if not default
  local USER_PROMPT="${USER_COLOR}${USER}${NORMAL}"

  local HOSTNAME_HEAD="$HOSTNAME"

  # Split the hostname if applicable
  if [[ "$HOSTNAME" == *'.'* ]]; then
    HOSTNAME_HEAD="${HOSTNAME%%.*}"
  fi

  # TODO white-n `/` in the whole path
  # Show hostname inside SSH session
  local HOST_PROMPT="${USER_HOST_DELIMITER} ${YELLOW}${BOLD}${HOSTNAME_HEAD}${NORMAL}"

  # Substitute `~`
  local WORKING_DIR=$(pwd)
  if [[ "$WORKING_DIR" == "$HOME"* ]]; then
    WORKING_DIR="~${WORKING_DIR#"$HOME"}"
  fi

  # Split the working directory if applicable
  local WORKING_DIR_INIT=""
  local WORKING_DIR_LAST="$WORKING_DIR"
  if [[ "$WORKING_DIR" == *'/'* ]]; then
    WORKING_DIR_LAST="${WORKING_DIR##*/}"
    WORKING_DIR_INIT="${WORKING_DIR%/*}${WHITE}/"
  fi

  # Format prompt
  FIRST_LINE="${USER_PROMPT} ${HOST_PROMPT} ${HOST_PATH_DELIMITER} ${GRAY}${WORKING_DIR_INIT}${BOLD}${WORKING_DIR_LAST}${NORMAL}"

  # Text (commands) inside \[...\] does not impact line length calculation which fixes stange bug when looking through the history
  # $? is a status of last command, should be processed every time prompt prints
  SECOND_LINE="\`if [ \$? = 0 ]; then echo \[\$GREEN\]; else echo \[\$RED\]; fi\`\$PROMPT_SYMBOL\[\$NORMAL\] "
  PS1="\n$FIRST_LINE\n$SECOND_LINE"

  # Same color for multi-line commands
  PS2="\`if [ \$? = 0 ]; then echo \[\$GREEN\]; else echo \[\$RED\]; fi\`\$PROMPT_SYMBOL\[\$NORMAL\] "

  # Terminal title
  local TITLE="$WORKING_DIR_LAST \xE2\x80\x94 $HOSTNAME_HEAD"
  echo -ne "\033]0;$TITLE"; echo -ne "\007"
}

PROMPT_COMMAND=prompt_command
