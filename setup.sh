#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren

source $DOT_FILES_DIR/.colors
touch $DOT_FILES_DIR/.env_context

if [ $# -eq 1 ]; then
  echo "$1" > $DOT_FILES_DIR/.env_context
fi

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"

if ! command -v zsh >/dev/null 2>&1; then
  printf "${BOLD}Zsh is not installed!${NORMAL} Please install zsh first!\n"
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
    printf "${BOLD}Please manually change your default shell to zsh!${NORMAL}\n"
  fi
fi

function mk_expected_dir {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "${GREEN}Creating${NORMAL}: $1 ..."
      mkdir -p $1
    else
      echo "${GREEN}Directory already present${NORMAL}: $1 ..."
    fi
  else
    echo "${BOLD}ERROR${NORMAL}: mk_expected_dir requires 1 arguments"
    exit 1
  fi
}

function mkdir_if_not_exists {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "${GREEN}Creating${NORMAL}: $1 ..."
      mkdir -p $1
    else
      echo "Directory already present: $1 ..."
      echo "${BOLD}WARN${NORMAL}: Skipping directory creation $1..."
    fi
  else
    echo "${BOLD}ERROR${NORMAL}: mkdir_if_not_exists requires 1 arguments"
    exit 1
  fi
}

function link_if_possible {
  if [ $# -eq 2 ]; then
    if [ -L "$2" ]; then
      echo "Link already present: ?? -> $2 ..."
      echo "${BOLD}WARN${NORMAL}: Skipping linking $1 -> $2..."
    elif [ -e "$2" ]; then
      echo "File/Directory present at $2 ..."
      echo "${BOLD}WARN${NORMAL}: Skipping linking $1 -> $2..."
    else
      echo "${GREEN}Linking${NORMAL}: $1 -> $2..."
      ln -s "$1" "$2"
    fi
  else
    echo "${BOLD}ERROR${NORMAL}: link_if_possible requires 2 arguments"
    exit 1
  fi
}

echo ""

mk_expected_dir $DOT_FILES_DIR/.local/share/fzf-history

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

echo 'Installing `zsh-completions` ...'
git clone git://github.com/zsh-users/zsh-completions.git $HOME/.oh-my-zsh/custom/plugins/zsh-completions
echo ""

echo 'Installing `pure` ...'
git clone https://github.com/sindresorhus/pure.git $DOT_FILES_DIR/pure
echo ""

link_if_possible $DOT_FILES_DIR/.zshrc $HOME/.zshrc

echo ""
echo "ZSH Setup ${GREEN}Complete${NORMAL}!"
echo ""

echo 'Installing `git-wtf` ...'
git clone https://github.com/michaelklishin/git-wtf.git $DOT_FILES_DIR/git-wtf
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
echo ""

mk_expected_dir $HOME/.config/nvim
link_if_possible $DOT_FILES_DIR/.nvim.init.vim $HOME/.config/nvim/init.vim
echo ""

link_if_possible $DOT_FILES_DIR/.alacritty.yml $HOME/.alacritty.yml
link_if_possible $DOT_FILES_DIR/.ackrc $HOME/.ackrc
link_if_possible $DOT_FILES_DIR/.pryrc $HOME/.pryrc
echo ""

link_if_possible $DOT_FILES_DIR $HOME/home

link_if_possible $DOT_FILES_DIR/nice-noise-loops $HOME/nice-noise-loops

link_if_possible $DOT_FILES_DIR/bin $HOME/bin

if [ ! -z "$DOT_FILES_ENV" ] && [ -e $DOT_FILES_DIR/$DOT_FILES_ENV-bin ]; then
  link_if_possible $DOT_FILES_DIR/$DOT_FILES_ENV-bin $HOME/$DOT_FILES_ENV-bin
fi

echo ""
echo ""

echo '  -- Recommendations:'
echo ''
echo '     `brew install fzf ag ccat coreutils ctags cabal ghc`'
echo '     `cabal install cabal-install Cabal`'
echo '     `cabal install happy alex fast-tags hindent stylish-hashell hlint`'
echo '     `gem install ripper-tags`'
echo ''
echo '     ... you may require `sudo`'
echo '     ... there may be more'
echo ''
echo '     `~/.hiren/.osx`'
echo '     ... sets up OS X in a nice way'
echo ''
echo 'Done!'
echo ''
