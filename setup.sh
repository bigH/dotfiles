#!/bin/sh

function mkdir_if_not_exists() {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "Creating: $1 ..."
      mkdir -p $1
    else
      echo "Directory already present: $1 ..."
      echo "WARN: Skipping directory creation $1..."
    fi
  else
    echo "ERROR: mkdir_if_not_exists requires 1 arguments"
    exit 1
  fi
}

function link_if_possible() {
  if [ $# -eq 2 ]; then
    if [ -L "$2" ]; then
      echo "Link already present: ?? -> $2 ..."
      echo "WARN: Skipping linking $1 -> $2..."
    elif [ -e "$2" ]; then
      echo "File/Directory present at $2 ..."
      echo "WARN: Skipping linking $1 -> $2..."
    else
      echo "Linking: $1 -> $2..."
      ln -s "$1" "$2"
    fi
  else
    echo "ERROR: link_if_possible requires 2 arguments"
    exit 1
  fi
}

echo ""

mkdir_if_not_exists ~/.hiren/.vim/tmp
mkdir_if_not_exists ~/.hiren/.vim/backup
mkdir_if_not_exists ~/.hiren/.vim/bundle

echo ""

if [ ! -d "~/.hiren/.vim/bundle/Vundle.vim" ]; then
  echo "Cloning Vundle for ViM ..."
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.hiren/.vim/bundle/Vundle.vim
fi

echo ""

link_if_possible ~/.hiren/.vimrc ~/.vimrc
link_if_possible ~/.hiren/.vim ~/.vim

echo ""

echo "Installing ViM plugins ..."
vim +PluginInstall +qall

echo ""
echo "ViM Setup Complete!"
echo ""

echo 'Installing `oh-my-zsh` ...'
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
echo ""

echo 'Installing `zsh-autosuggestions` ...'
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
echo ""

echo 'Installing `zsh-syntax-highlighting` ...'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
echo ""


link_if_possible ~/.hiren/.zshrc ~/.zshrc

echo ""
echo "ZSH Setup Complete!"
echo ""

link_if_possible ~/.hiren/.gitconfig.stripe ~/.gitconfig
link_if_possible ~/.hiren/.ackrc ~/.ackrc
link_if_possible ~/.hiren/bin ~/bin

echo ""

echo ""

echo '  -- Recommend: `brew install fzf ag`'
echo '  -- ... there may be more'

echo ""

echo '  -- Recommend: `~/.hiren/.osx`'
echo '  -- ... sets up OS X in a nice way'

echo ""

echo "Done!"

echo ""
