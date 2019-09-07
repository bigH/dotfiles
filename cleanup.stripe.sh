#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren
source $DOT_FILES_DIR/util.sh

if ! type pay >/dev/null 2>&1; then
  echo "${RED}${BOLD}ERROR: \`pay\` not found${NORMAL}"
  exit 1
fi

PAY_HOST="$(pay show-host)"
echo "(local) ${BLUE}${BOLD}Running \`remote_cleanup.stripe.sh\`...${NORMAL}"
ssh "$PAY_HOST" '$HOME/.hiren/remote_cleanup.stripe.sh' | sed 's/^/  /'
echo "(local) ${BLUE}${BOLD}Done.${NORMAL}"
echo ""

