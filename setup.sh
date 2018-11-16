#!/bin/bash

source $HOME/.hiren/.colors
touch $HOME/.hiren/.env_context

if [ $# -eq 1 ]; then
  echo "$1" > $HOME/.hiren/.env_context
fi

export DOT_FILES_ENV="$(cat $HOME/.hiren/.env_context)"

if ! command -v zsh >/dev/null 2>&1; then
  printf "${RED}Zsh is not installed!${NORMAL} Please install zsh first!\n"
  exit
fi

TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
  # If this platform provides a "chsh" command (not Cygwin), do it, man!
  if hash chsh >/dev/null 2>&1; then
    printf "${BLUE}Time to change your default shell to zsh!${NORMAL}\n"
    chsh -s $(grep /zsh$ /etc/shells | tail -1) $USER
  # Else, suggest the user do so manually.
  else
    printf "I can't change your shell automatically because this system does not have chsh.\n"
    printf "${RED}Please manually change your default shell to zsh!${NORMAL}\n"
  fi
fi

function mkdir_if_not_exists {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "${GREEN}Creating${NORMAL}: $1 ..."
      mkdir -p $1
    else
      echo "Directory already present: $1 ..."
      echo "${YELLOW}WARN${NORMAL}: Skipping directory creation $1..."
    fi
  else
    echo "${RED}ERROR${NORMAL}: mkdir_if_not_exists requires 1 arguments"
    exit 1
  fi
}

function link_if_possible {
  if [ $# -eq 2 ]; then
    if [ -L "$2" ]; then
      echo "Link already present: ?? -> $2 ..."
      echo "${YELLOW}WARN${NORMAL}: Skipping linking $1 -> $2..."
    elif [ -e "$2" ]; then
      echo "File/Directory present at $2 ..."
      echo "${YELLOW}WARN${NORMAL}: Skipping linking $1 -> $2..."
    else
      echo "${GREEN}Linking${NORMAL}: $1 -> $2..."
      ln -s "$1" "$2"
    fi
  else
    echo "${RED}ERROR${NORMAL}: link_if_possible requires 2 arguments"
    exit 1
  fi
}

echo ""

mkdir_if_not_exists $HOME/.hiren/.vim/tmp
mkdir_if_not_exists $HOME/.hiren/.vim/backup
mkdir_if_not_exists $HOME/.hiren/.vim/bundle
mkdir_if_not_exists $HOME/.hiren/.vim/undodir

echo ""

if [ ! -d "$HOME/.hiren/.vim/bundle/Vundle.vim" ]; then
  echo "Cloning Vundle for ViM ..."
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.hiren/.vim/bundle/Vundle.vim
fi

echo ""

link_if_possible $HOME/.hiren/.vimrc $HOME/.vimrc
link_if_possible $HOME/.hiren/.vim $HOME/.vim

echo ""

echo "Installing ViM plugins ..."
vim +PluginInstall +qall

echo ""
echo "ViM Setup ${GREEN}Complete${NORMAL}!"
echo ""

echo 'Installing `oh-my-zsh` ...'
git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
echo ""

echo 'Installing `zsh-autosuggestions` ...'
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
echo ""

echo 'Installing `zsh-syntax-highlighting` ...'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
echo ""

link_if_possible $HOME/.hiren/.zshrc $HOME/.zshrc

echo ""
echo "ZSH Setup ${GREEN}Complete${NORMAL}!"
echo ""

if [ "$DOT_FILES_ENV" = "stripe" ]; then
  link_if_possible $HOME/.hiren/.stripe.gitignore_global $HOME/.gitignore_global
  link_if_possible $HOME/.hiren/.stripe.gitconfig $HOME/.gitconfig
else
  link_if_possible $HOME/.hiren/.gitignore_global $HOME/.gitignore_global
  link_if_possible $HOME/.hiren/.gitconfig $HOME/.gitconfig
fi

link_if_possible $HOME/.hiren/.ackrc $HOME/.ackrc
link_if_possible $HOME/.hiren/bin $HOME/bin

echo ""

echo ""

echo '  -- Recommendations:'
echo ''
echo '     `brew install fzf ag ccat coreutils ctags`'
echo '     ... there may be more'
echo ''
echo '     `~/.hiren/.osx`'
echo '     ... sets up OS X in a nice way'
echo ''
echo 'Done!'
echo ''
