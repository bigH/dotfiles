#!/bin/bash

echo "(devbox) ${BLUE}${BOLD} -- begin -- ${NORMAL}"

if ! command -v cargo >/dev/null 2>&1; then
  echo "${RED}${BOLD}\`cargo\` is not installed!${NORMAL}"
  echo "It's required for installing other programs from source!"
  exit
fi

export DOT_FILES_DIR=$HOME/.hiren

echo "stripe-remote" > $DOT_FILES_DIR/.env_context

source $DOT_FILES_DIR/util.sh

echo ""
echo "(devbox) ${BLUE}${BOLD}..random directories..${NORMAL}"

chmod +x $DOT_FILES_DIR/*.sh
chmod +x $DOT_FILES_DIR/bin/*
rm -rf $DOT_FILES_DIR/made-bin
mk_expected_dir $DOT_FILES_DIR/.local/share/fzf-history
mkdir_if_not_exists $DOT_FILES_DIR/logs

echo ""
echo "(devbox) ${BLUE}${BOLD}Cleanup \`made-bin\` directory${NORMAL}"

clean_dir $DOT_FILES_DIR/made-bin

echo ""
echo "(devbox) ${BLUE}${BOLD}Cleanup \`vim\` directories${NORMAL}"

clean_dir $DOT_FILES_DIR/.vim/sessions
clean_dir $DOT_FILES_DIR/.vim/tmp
clean_dir $DOT_FILES_DIR/.vim/backup
clean_dir $DOT_FILES_DIR/.vim/bundle
clean_dir $DOT_FILES_DIR/.vim/undodir
clean_dir $DOT_FILES_DIR/.vim/scratch

echo ""
echo "(devbox) ${BLUE}${BOLD}Symlinking things...${NORMAL}"

link_if_possible $DOT_FILES_DIR/.rgignore $HOME/.rgignore
link_if_possible $DOT_FILES_DIR/.vimrc $HOME/.vimrc
link_if_possible $DOT_FILES_DIR/.vim $HOME/.vim
link_if_possible $DOT_FILES_DIR/.zshrc $HOME/.zshrc
link_if_possible $DOT_FILES_DIR/.pryrc $HOME/.pryrc
link_if_possible $DOT_FILES_DIR/git-wtf/git-wtf $DOT_FILES_DIR/bin/git-wtf

echo ""
echo "(devbox) ${BLUE}${BOLD}Linking UltiSnips${NORMAL}"

link_if_possible $DOT_FILES_DIR/UltiSnips $HOME/.vim/UltiSnips

echo ""
echo "(devbox) ${BLUE}${BOLD}Installing \`fzf\`${NORMAL}"

$DOT_FILES_DIR/fzf-install.sh > $DOT_FILES_DIR/logs/fzf-install-log 2> $DOT_FILES_DIR/logs/fzf-install-log

echo ""
echo "(devbox) ${BLUE}${BOLD}Installing \`rg\`${NORMAL}"

$DOT_FILES_DIR/ripgrep-install.sh > $DOT_FILES_DIR/logs/rg-install-log 2> $DOT_FILES_DIR/logs/rg-install-log

echo ""
echo "(devbox) ${BLUE}${BOLD}Installing \`fd\`${NORMAL}"

$DOT_FILES_DIR/fd-install.sh > $DOT_FILES_DIR/logs/fd-install-log 2> $DOT_FILES_DIR/logs/fd-install-log

echo ""
echo "(devbox) ${BLUE}${BOLD}Installing \`bat\`${NORMAL}"

$DOT_FILES_DIR/bat-install.sh > $DOT_FILES_DIR/logs/bat-install-log 2> $DOT_FILES_DIR/logs/bat-install-log

echo ""
echo "(devbox) ${BLUE}${BOLD}Symlinking \`oh-my-zsh\`...${NORMAL}"

link_if_possible $DOT_FILES_DIR/.oh-my-zsh $HOME/.oh-my-zsh

echo ""
echo "(devbox) ${BLUE}${BOLD}Setting up \`zsh\`${NORMAL}"

if ! grep 'zsh' .profile >/dev/null 2>&1; then
  cp -f $HOME/.profile $HOME/.profile-bak
  echo 'zsh' >> $HOME/.profile
fi

echo "(devbox) ${BLUE}${BOLD} -- end -- ${NORMAL}"
echo ""
