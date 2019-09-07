#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren
source $DOT_FILES_DIR/util.sh

if ! type pay >/dev/null 2>&1; then
  echo "${RED}${BOLD}ERROR: \`pay\` not found${NORMAL}"
  exit 1
fi

echo "(local) ${BLUE}${BOLD}Syncing...${NORMAL}"
PAY_HOST="$(pay show-host)"
rsync -rz "$DOT_FILES_DIR" "$USER@`pay show-host`:~"
echo "(local) ${BLUE}${BOLD}Done Sync.${NORMAL}"
echo ""

echo "(local) ${BLUE}${BOLD}Running \`remote_setup.stripe.sh\`...${NORMAL}"
echo ""
ssh -t "$PAY_HOST" '$HOME/.hiren/remote_setup.stripe.sh' | $DOT_FILES_DIR/bin/indent
echo ""
echo "(local) ${BLUE}${BOLD}Done.${NORMAL}"
echo ""

