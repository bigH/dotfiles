#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren

source $DOT_FILES_DIR/.colors
touch $DOT_FILES_DIR/.env_context

if [ $# -eq 1 ]; then
  echo "$1" > $DOT_FILES_DIR/.env_context
fi

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"

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

mkdir_if_not_exists $DOT_FILES_DIR/.vim/tmp
mkdir_if_not_exists $DOT_FILES_DIR/.vim/backup
mkdir_if_not_exists $DOT_FILES_DIR/.vim/bundle
mkdir_if_not_exists $DOT_FILES_DIR/.vim/undodir

echo ""

if [ ! -d "$DOT_FILES_DIR/.vim/bundle/Vundle.vim" ]; then
  echo "Cloning Vundle for ViM ..."
  git clone https://github.com/VundleVim/Vundle.vim.git $DOT_FILES_DIR/.vim/bundle/Vundle.vim
fi

echo ""

link_if_possible $DOT_FILES_DIR/.vimrc $HOME/.vimrc
link_if_possible $DOT_FILES_DIR/.vim $HOME/.vim

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

link_if_possible $DOT_FILES_DIR/.zshrc $HOME/.zshrc

echo ""
echo "ZSH Setup ${GREEN}Complete${NORMAL}!"
echo ""

echo 'Installing `git-wtf` ...'
git clone https://github.com/michaelklishin/git-wtf.git $DOT_FILES_DIR/git-wtf
echo ""

echo 'Installing `solarized` ...'
git clone https://github.com/altercation/solarized.git $DOT_FILES_DIR/solarized
echo ""

echo 'Installing `dircolors-solarized` ...'
git clone https://github.com/seebi/dircolors-solarized.git $DOT_FILES_DIR/dircolors-solarized
echo ""

link_if_possible $DOT_FILES_DIR/git-wtf/git-wtf $DOT_FILES_DIR/bin/git-wtf
echo ""

if [ ! -z "$DOT_FILES_ENV" ]; then
  link_if_possible $DOT_FILES_DIR/.$DOT_FILES_ENV.gitignore_global $HOME/.gitignore_global
  link_if_possible $DOT_FILES_DIR/.$DOT_FILES_ENV.gitconfig $HOME/.gitconfig
else
  link_if_possible $DOT_FILES_DIR/.gitignore_global $HOME/.gitignore_global
  link_if_possible $DOT_FILES_DIR/.gitconfig $HOME/.gitconfig
fi

link_if_possible $DOT_FILES_DIR/.ackrc $HOME/.ackrc
link_if_possible $DOT_FILES_DIR/.pryrc $HOME/.pryrc
link_if_possible $DOT_FILES_DIR/bin $HOME/bin

if [ ! -z "$DOT_FILES_ENV" ] && [ -e $DOT_FILES_DIR/$DOT_FILES_ENV-bin ]; then
  link_if_possible $DOT_FILES_DIR/$DOT_FILES_ENV-bin $HOME/$DOT_FILES_ENV-bin
fi

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
