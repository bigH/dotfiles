#!/bin/bash

function devbox_echo() {
  printf "[${MAGENTA}${BOLD}DEVBOX${NORMAL}] $1"
}

echo ""
echo " -- begin -- "

if ! command -v cargo >/dev/null 2>&1; then
  echo "${RED}${BOLD}\`cargo\` is not installed!${NORMAL}"
  echo "It's required for installing other programs from source!"
  exit
fi

export DOT_FILES_DIR=$HOME/.hiren

echo "stripe-remote" > $DOT_FILES_DIR/.env_context

source $DOT_FILES_DIR/util.sh

devbox_echo "${BLUE}${BOLD}Random Directories${NORMAL}"; echo ""
mk_expected_dir $DOT_FILES_DIR/.local/share/fzf-history
mk_or_clean_dir $DOT_FILES_DIR/logs
echo ""

devbox_echo "${BLUE}${BOLD}\`made-bin\` Directory${NORMAL}"; echo ""

mk_or_clean_dir $DOT_FILES_DIR/made-bin

echo ""
devbox_echo "${BLUE}${BOLD}\`.vim\` Sub-Directories${NORMAL}"; echo ""

mk_or_clean_dir $DOT_FILES_DIR/.vim/sessions
mk_or_clean_dir $DOT_FILES_DIR/.vim/tmp
mk_or_clean_dir $DOT_FILES_DIR/.vim/backup
mk_or_clean_dir $DOT_FILES_DIR/.vim/bundle
mk_or_clean_dir $DOT_FILES_DIR/.vim/undodir
mk_or_clean_dir $DOT_FILES_DIR/.vim/scratch

echo ""
devbox_echo "${BLUE}${BOLD}Symlinks${NORMAL}"; echo ""

link_if_possible $DOT_FILES_DIR/.rgignore $HOME/.rgignore
link_if_possible $DOT_FILES_DIR/.vimrc $HOME/.vimrc
link_if_possible $DOT_FILES_DIR/.vim $HOME/.vim
link_if_possible $DOT_FILES_DIR/.ackrc $HOME/.ackrc
link_if_possible $DOT_FILES_DIR/.inputrc $HOME/.inputrc
link_if_possible $DOT_FILES_DIR/UltiSnips $HOME/.vim/UltiSnips

echo ""
devbox_echo "${BLUE}${BOLD}Installing \`fzf\`${NORMAL}"
print_symbol_for_status "build" "$DOT_FILES_DIR/fzf-install.sh > $DOT_FILES_DIR/logs/fzf-install-log 2> $DOT_FILES_DIR/logs/fzf-install-log"
echo ""

devbox_echo "${BLUE}${BOLD}Installing \`rg\`${NORMAL}"
print_symbol_for_status "build" "$DOT_FILES_DIR/ripgrep-install.sh > $DOT_FILES_DIR/logs/ripgrep-install-log 2> $DOT_FILES_DIR/logs/ripgrep-install-log"
echo ""

# fails to build on devbox
# devbox_echo "${BLUE}${BOLD}Installing \`fd\`${NORMAL}"
# print_symbol_for_status "build" "$DOT_FILES_DIR/bat-install.sh > $DOT_FILES_DIR/logs/bat-install-log 2> $DOT_FILES_DIR/logs/bat-install-log"
# echo ""

devbox_echo "${BLUE}${BOLD}Installing \`bat\`${NORMAL}"
print_symbol_for_status "build" "$DOT_FILES_DIR/fd-install.sh > $DOT_FILES_DIR/logs/fd-install-log 2> $DOT_FILES_DIR/logs/fd-install-log"
echo ""

devbox_echo "${BLUE}${BOLD}\`chmod\` Executables${NORMAL}"; echo ""
chmod +x $DOT_FILES_DIR/*.sh
chmod +x $DOT_FILES_DIR/bin/*
chmod +x $DOT_FILES_DIR/*-bin/*
echo ""

devbox_echo "${BLUE}${BOLD}Setup \`$DOT_FILES_DIR/.pryrc\`${NORMAL}"; echo ""
if ! grep "DOT_FILES_DIR" .pryrc >/dev/null 2>&1; then
  cp -f $HOME/.pryrc $HOME/.pryrc-bak
  {
    echo ''
    echo 'ENV["DOT_FILES_DIR"]="#{ENV["HOME"]}/.hiren"'
    echo 'require_relative File.join(ENV["DOT_FILES_DIR"], ".pryrc")'
  } >> $HOME/.pryrc
fi

devbox_echo "${BLUE}${BOLD}Setup \`$DOT_FILES_DIR/.profile\`${NORMAL}"; echo ""
if ! grep "DOT_FILES_DIR" .profile >/dev/null 2>&1; then
  cp -f $HOME/.profile $HOME/.profile-bak
  {
    echo ''
    echo 'DOT_FILES_DIR="$HOME/.hiren"'
    echo 'source $DOT_FILES_DIR/.profile'
  } >> $HOME/.profile
fi

echo " --  end  -- "
echo ""
