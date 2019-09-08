#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren
source $DOT_FILES_DIR/util.sh

if ! type pay >/dev/null 2>&1; then
  echo "${RED}${BOLD}ERROR: \`pay\` not found${NORMAL}"
  exit 1
fi

PAY_HOST="$(pay show-host)"
echo "${BLUE}${BOLD}Running \`remote_cleanup.stripe.sh\`...${NORMAL}"
ssh -t "$PAY_HOST" '$HOME/.hiren/remote_cleanup.stripe.sh' | $DOT_FILES_DIR/bin/indent
echo ""
echo "${BLUE}${BOLD}Done.${NORMAL}"
echo ""

