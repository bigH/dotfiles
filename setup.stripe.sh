#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren
source $DOT_FILES_DIR/util.sh

if ! type pay >/dev/null 2>&1; then
  echo "${RED}${BOLD}ERROR: \`pay\` not found${NORMAL}"
  exit 1
fi

PAY_HOST="$(pay show-host)"
if [ -z "$PAY_HOST" ]; then
  echo "${RED}${BOLD}ERROR: \`pay host\` didn't return anything.${NORMAL}"
  echo " - check connectivity"
  echo " - check VPN"
  exit 1
fi
printf "${BLUE}${BOLD}Syncing \`$PAY_HOST\`${NORMAL}"
print_symbol_for_status "rsync" "rsync -rz '$DOT_FILES_DIR' '$USER@$PAY_HOST:~'"
echo ""
echo ""

echo "${BLUE}${BOLD}Running \`remote_setup.stripe.sh\`...${NORMAL}"
ssh -t "$PAY_HOST" '$HOME/.hiren/remote_setup.stripe.sh' | $DOT_FILES_DIR/bin/indent
echo ""
echo "${BLUE}${BOLD}Done.${NORMAL}"
echo ""

