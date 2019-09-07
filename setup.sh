#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren
source $DOT_FILES_DIR/util.sh

if ! command -v zsh >/dev/null 2>&1; then
  printf "${RED}${BOLD}Zsh is not installed!${NORMAL} Please install zsh first!\n"
  exit
fi

TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
  # If this platform provides a "chsh" command (not Cygwin), do it, man!
  if hash chsh >/dev/null 2>&1; then
    printf "${BLUE}${BOLD}Time to change your default shell to zsh!${NORMAL}\n"
    chsh -s $(grep /zsh$ /etc/shells | tail -1) $USER
  # Else, suggest the user do so manually.
  else
    printf "I can't change your shell automatically because this system does not have chsh.\n"
    printf "${BOLD}Please manually change your default shell to zsh!${NORMAL}\n"
  fi
fi

echo ""
echo "${BLUE}${BOLD}..random directories..${NORMAL}"

mk_expected_dir $DOT_FILES_DIR/.local/share/fzf-history
mk_expected_dir $DOT_FILES_DIR/logs

echo ""
echo "${BLUE}${BOLD}\`made-bin\` directory${NORMAL}"

mkdir_if_not_exists $DOT_FILES_DIR/made-bin

echo ""
echo "${BLUE}${BOLD}Cleanup \`vim\` directories${NORMAL}"

mkdir_if_not_exists $DOT_FILES_DIR/.vim/sessions
mkdir_if_not_exists $DOT_FILES_DIR/.vim/tmp
mkdir_if_not_exists $DOT_FILES_DIR/.vim/backup
mkdir_if_not_exists $DOT_FILES_DIR/.vim/bundle
mkdir_if_not_exists $DOT_FILES_DIR/.vim/undodir
mkdir_if_not_exists $DOT_FILES_DIR/.vim/scratch

echo ""
echo "${BLUE}${BOLD}Install \`bundle/Vundle\`${NORMAL}"

if [ ! -d "$DOT_FILES_DIR/.vim/bundle/Vundle.vim" ]; then
  echo "Cloning Vundle for ViM ..."
  git clone https://github.com/VundleVim/Vundle.vim.git $DOT_FILES_DIR/.vim/bundle/Vundle.vim
fi

echo ""
echo "${BLUE}${BOLD}\`.vim\` and \`.vimrc\`${NORMAL}"

link_if_possible $DOT_FILES_DIR/.vimrc $HOME/.vimrc
link_if_possible $DOT_FILES_DIR/.vim $HOME/.vim

echo ""
echo "${BLUE}${BOLD}Linking UltiSnips${NORMAL}"

link_if_possible $DOT_FILES_DIR/UltiSnips $HOME/.vim/UltiSnips

echo ""
echo "ViM Setup ${BLUE}${BOLD}Complete${NORMAL}!"
echo ""

echo "${BLUE}${BOLD}Installing \`fzf\` ...${NORMAL}"
git clone https://github.com/junegunn/fzf.git $DOT_FILES_DIR/fzf
$DOT_FILES_DIR/fzf-install.sh > $DOT_FILES_DIR/logs/fzf-install-log 2> $DOT_FILES_DIR/logs/fzf-install-log
echo ""

echo "${BLUE}${BOLD}Installing \`ripgrep\` ...${NORMAL}"
git clone https://github.com/BurntSushi/ripgrep.git $DOT_FILES_DIR/ripgrep
$DOT_FILES_DIR/ripgrep-install.sh > $DOT_FILES_DIR/logs/ripgrep-install-log 2> $DOT_FILES_DIR/logs/ripgrep-install-log
echo ""

echo "${BLUE}${BOLD}Installing \`bat\` ...${NORMAL}"
git clone https://github.com/sharkdp/bat.git $DOT_FILES_DIR/bat
$DOT_FILES_DIR/bat-install.sh > $DOT_FILES_DIR/logs/bat-install-log 2> $DOT_FILES_DIR/logs/bat-install-log
echo ""

echo "${BLUE}${BOLD}Installing \`fd\` ...${NORMAL}"
git clone https://github.com/sharkdp/fd.git $DOT_FILES_DIR/fd
$DOT_FILES_DIR/fd-install.sh > $DOT_FILES_DIR/logs/fd-install-log 2> $DOT_FILES_DIR/logs/fd-install-log
echo ""

echo "${BLUE}${BOLD}Installing \`oh-my-zsh\` ...${NORMAL}"
git clone https://github.com/robbyrussell/oh-my-zsh.git $DOT_FILES_DIR/.oh-my-zsh
echo ""

echo "${BLUE}${BOLD}Installing \`zsh-autosuggestions\` ...${NORMAL}"
git clone https://github.com/zsh-users/zsh-autosuggestions $DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-autosuggestions
echo ""

echo "${BLUE}${BOLD}Installing \`zsh-syntax-highlighting\` ...${NORMAL}"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
echo ""

echo "${BLUE}${BOLD}Installing \`zsh-completions\` ...${NORMAL}"
git clone git://github.com/zsh-users/zsh-completions.git $DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-completions
echo ""

echo "${BLUE}${BOLD}Installing \`pure\` ...${NORMAL}"
git clone https://github.com/sindresorhus/pure.git $DOT_FILES_DIR/pure
echo ""

link_if_possible $DOT_FILES_DIR/.zshrc $HOME/.zshrc
link_if_possible $DOT_FILES_DIR/.oh-my-zsh $HOME/.oh-my-zsh

echo ""
echo "ZSH Setup ${BLUE}${BOLD}Complete${NORMAL}!"
echo ""

echo "${BLUE}${BOLD}Installing \`git-wtf\` ...${NORMAL}"
git clone https://github.com/michaelklishin/git-wtf.git $DOT_FILES_DIR/git-wtf
echo ""

link_if_possible $DOT_FILES_DIR/git-wtf/git-wtf $DOT_FILES_DIR/bin/git-wtf
echo ""

echo "${DOT_FILES_ENV_DISPLAY} ${BLUE}${BOLD}git configurations${NORMAL}"
if [ ! -z "$DOT_FILES_ENV" ]; then
  link_if_possible $DOT_FILES_DIR/.$DOT_FILES_ENV.gitignore_global $HOME/.gitignore_global
  link_if_possible $DOT_FILES_DIR/.$DOT_FILES_ENV.gitconfig $HOME/.gitconfig
else
  link_if_possible $DOT_FILES_DIR/.gitignore_global $HOME/.gitignore_global
  link_if_possible $DOT_FILES_DIR/.gitconfig $HOME/.gitconfig
fi

echo ""
echo "${BLUE}${BOLD}Miscellany ...${NORMAL}"
echo ""
link_if_possible $DOT_FILES_DIR/.rgignore $HOME/.rgignore
echo ""

mk_expected_dir $HOME/.config/nvim
link_if_possible $DOT_FILES_DIR/.nvim.init.vim $HOME/.config/nvim/init.vim
echo ""

link_if_possible $DOT_FILES_DIR/.alacritty.yml $HOME/.alacritty.yml
link_if_possible $DOT_FILES_DIR/.ackrc $HOME/.ackrc
link_if_possible $DOT_FILES_DIR/.pryrc $HOME/.pryrc
link_if_possible $DOT_FILES_DIR/.tigrc $HOME/.tigrc
echo ""

link_if_possible $DOT_FILES_DIR/nice-noise-loops $HOME/nice-noise-loops

link_if_possible $DOT_FILES_DIR/bin $HOME/bin

if [ ! -z "$DOT_FILES_ENV" ] && [ -e $DOT_FILES_DIR/$DOT_FILES_ENV-bin ]; then
  echo ""
  echo "${DOT_FILES_ENV_DISPLAY} ${BLUE}${BOLD}bin directory${NORMAL}"
  link_if_possible $DOT_FILES_DIR/$DOT_FILES_ENV-bin $HOME/$DOT_FILES_ENV-bin
fi

echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "${BLUE}${BOLD}Installing iTerm2 shell integration ...${NORMAL}"
  curl -L https://iterm2.com/misc/install_shell_integration.sh | bash

  echo ""
  echo "iTerm2 Setup ${BLUE}Complete${NORMAL}!"
  echo ""
fi

echo ""

echo "${BLUE}${BOLD}Installing ViM plugins ...${NORMAL}"
zsh -c "nvim -u $DOT_FILES_DIR/vim_plugin_install.vimrc +PluginInstall +qall"

echo ""
echo ""

echo "  [${BLUE}${BOLD}RECOMMENDATIONS${NORMAL}]:"
echo ""
echo "     \`brew install fzf ag ccat coreutils ctags cabal ghc\`"
echo "     \`cabal install cabal-install Cabal\`"
echo "     \`cabal install happy alex fast-tags hindent stylish-hashell hlint\`"
echo "     \`[rbenv exec] gem install ripper-tags\`"
echo ""
echo "     ... you may require \`sudo\`"
echo "     ... there may be more"
echo ""
echo "     \`~/.hiren/.osx\`"
echo "     ... sets up OS X in a nice way"
echo ""
# TODO build/test this stuff
if [ ! -z "$DOT_FILES_ENV" ] && [ -e "setup.$DOT_FILES_ENV.sh" ]; then
  echo "  $DOT_FILES_ENV_DISPLAY:"
  echo ""
  echo "     You can run \`~/.hiren/setup.$DOT_FILES_ENV.sh\`"
  echo "     ... sets up the devbox in a nice way"
  echo ""
fi
echo "Done!"
echo ""
