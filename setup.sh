#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren
source "$DOT_FILES_DIR/util.sh"

if ! command -v zsh >/dev/null 2>&1; then
  echo "${RED}${BOLD}Zsh is not installed!${NORMAL} Please install zsh first!"
  exit
fi

TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
  echo "${BLUE}${BOLD}Time to change your default shell to zsh!${NORMAL}"
  echo "  \`chsh -s $(grep /zsh$ /etc/shells | tail -1) $USER\`"
  exit 1
fi

echo "${BLUE}${BOLD}..random directories..${NORMAL}"
mk_expected_dir "$DOT_FILES_DIR/.local/share/fzf-history"
mk_expected_dir "$DOT_FILES_DIR/logs"
echo ""

echo "${BLUE}${BOLD}\`made-bin\` directory${NORMAL}"
mkdir_if_not_exists "$DOT_FILES_DIR/made-bin"
echo ""

echo "${BLUE}${BOLD}Cleanup \`vim\` directories${NORMAL}"
mkdir_if_not_exists "$DOT_FILES_DIR/.vim/sessions"
mkdir_if_not_exists "$DOT_FILES_DIR/.vim/tmp"
mkdir_if_not_exists "$DOT_FILES_DIR/.vim/backup"
mkdir_if_not_exists "$DOT_FILES_DIR/.vim/bundle"
mkdir_if_not_exists "$DOT_FILES_DIR/.vim/undodir"
mkdir_if_not_exists "$DOT_FILES_DIR/.vim/scratch"
echo ""

printf "${BLUE}${BOLD}Download \`vim-plug\`${NORMAL}"
print_symbol_for_status "vim" "curl -fLo $DOT_FILES_DIR/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
print_symbol_for_status "nvim" "curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
echo ""
echo ""

echo "${BLUE}${BOLD}\`.vim[rc]\` and \`coc-settings.json\`${NORMAL}"
link_if_possible "$DOT_FILES_DIR/vimrc" "$HOME/.vimrc"
link_if_possible "$DOT_FILES_DIR/.vim" "$HOME/.vim"
link_if_possible "$DOT_FILES_DIR/vim/syntax" "$HOME/.vim/syntax"
link_if_possible "$DOT_FILES_DIR/vim/ftdetect" "$HOME/.vim/ftdetect"
link_if_possible "$DOT_FILES_DIR/coc-settings.json" "$HOME/.vim/coc-settings.json"
echo ""

echo "${BLUE}${BOLD}vim -> neovim${NORMAL}"
mk_expected_dir "$HOME/.config/nvim"
link_if_possible "$DOT_FILES_DIR/nvim-init.vim" "$HOME/.config/nvim/init.vim"
link_if_possible "$DOT_FILES_DIR/vim/syntax" "$HOME/.config/nvim/syntax"
link_if_possible "$DOT_FILES_DIR/vim/ftdetect" "$HOME/.config/nvim/ftdetect"
link_if_possible "$DOT_FILES_DIR/coc-settings.json" "$HOME/.config/nvim/coc-settings.json"
echo ""

echo "${BLUE}${BOLD}Linking UltiSnips${NORMAL}"
link_if_possible "$DOT_FILES_DIR/UltiSnips" "$HOME/.vim/UltiSnips"
echo ""

echo "ViM Setup ${BLUE}${BOLD}Complete${NORMAL}!"
echo ""

echo "${BLUE}${BOLD}Various Installs${NORMAL}:"
printf "  - ${BLUE}Installing \`fzf\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/junegunn/fzf.git $DOT_FILES_DIR/fzf"
print_symbol_for_status "build" "$DOT_FILES_DIR/fzf-install.sh > $DOT_FILES_DIR/logs/fzf-install-log 2> $DOT_FILES_DIR/logs/fzf-install-log"
echo ""

printf "  - ${BLUE}Installing \`ripgrep\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/BurntSushi/ripgrep.git $DOT_FILES_DIR/ripgrep"
print_symbol_for_status "build" "$DOT_FILES_DIR/ripgrep-install.sh > $DOT_FILES_DIR/logs/ripgrep-install-log 2> $DOT_FILES_DIR/logs/ripgrep-install-log"
echo ""

printf "  - ${BLUE}Installing \`bat\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/sharkdp/bat.git $DOT_FILES_DIR/bat"
print_symbol_for_status "build" "$DOT_FILES_DIR/bat-install.sh > $DOT_FILES_DIR/logs/bat-install-log 2> $DOT_FILES_DIR/logs/bat-install-log"
echo ""

printf "  - ${BLUE}Installing \`fd\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/sharkdp/fd.git $DOT_FILES_DIR/fd"
print_symbol_for_status "build" "$DOT_FILES_DIR/fd-install.sh > $DOT_FILES_DIR/logs/fd-install-log 2> $DOT_FILES_DIR/logs/fd-install-log"
echo ""

printf "  - ${BLUE}Installing \`oh-my-zsh\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/robbyrussell/oh-my-zsh.git $DOT_FILES_DIR/.oh-my-zsh"
echo ""

printf "  - ${BLUE}Installing \`zsh-autosuggestions\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/zsh-users/zsh-autosuggestions $DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
echo ""

printf "  - ${BLUE}Installing \`zsh-syntax-highlighting\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
echo ""

printf "  - ${BLUE}Installing \`zsh-completions\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/zsh-users/zsh-completions.git $DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-completions"
echo ""

printf "  - ${BLUE}Installing \`pure\` ...${NORMAL}"
print_symbol_for_status "clone" "git clone https://github.com/sindresorhus/pure.git $DOT_FILES_DIR/pure"
echo ""

echo ""

# TODO change this setup to append to existing file (and create an empty one if it exists)
# TODO what happens if the file's changed after you've patched it
echo "${BLUE}${BOLD}Linking ZSH Setup${NORMAL}"
link_if_possible "$DOT_FILES_DIR/zshrc" "$HOME/.zshrc"
link_if_possible "$DOT_FILES_DIR/.oh-my-zsh" "$HOME/.oh-my-zsh"
echo ""

echo "${DOT_FILES_ENV_DISPLAY} ${BLUE}${BOLD}git configurations${NORMAL}"
if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/gitignore_global" ]; then
  link_if_possible "$DOT_FILES_DIR/$DOT_FILES_ENV/gitignore_global" "$HOME/.gitignore_global"
else
  link_if_possible "$DOT_FILES_DIR/gitignore_global" "$HOME/.gitignore_global"
fi
if [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/gitconfig" ]; then
  link_if_possible "$DOT_FILES_DIR/$DOT_FILES_ENV/gitconfig" "$HOME/.gitconfig"
else
  link_if_possible "$DOT_FILES_DIR/gitconfig" "$HOME/.gitconfig"
fi
echo ""

echo "${BLUE}${BOLD}Miscellany ...${NORMAL}"
mk_expected_dir "$HOME/.config/alacritty"
link_if_possible "$DOT_FILES_DIR/ackrc" "$HOME/.ackrc"
link_if_possible "$DOT_FILES_DIR/alacritty.yml" "$HOME/.alacritty.yml"
link_if_possible "$DOT_FILES_DIR/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
link_if_possible "$DOT_FILES_DIR/ctags" "$HOME/.ctags"
link_if_possible "$DOT_FILES_DIR/inputrc" "$HOME/.inputrc"
link_if_possible "$DOT_FILES_DIR/pryrc" "$HOME/.pryrc"
link_if_possible "$DOT_FILES_DIR/rgignore" "$HOME/.rgignore"
link_if_possible "$DOT_FILES_DIR/tigrc" "$HOME/.tigrc"
link_if_possible "$DOT_FILES_DIR/nice-noise-loops" "$HOME/nice-noise-loops"
echo ""

echo "${BLUE}${BOLD}\`bin\` directory${NORMAL}"
link_if_possible "$DOT_FILES_DIR/bin" "$HOME/bin"
echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
  printf "${BLUE}${BOLD}Installing iTerm2 shell integration ...${NORMAL}"
  print_symbol_for_status "execute" "curl -L https://iterm2.com/misc/install_shell_integration.sh | bash"
  echo ""
  echo ""
fi

echo "${BLUE}${BOLD}Installing ViM plugins${NORMAL}"
if type nvim >/dev/null 2>&1; then
  zsh -c 'nvim -u $DOT_FILES_DIR/vim/includes/plugins.vimrc +PlugUpdate +qall'
else
  zsh -c 'vim -u $DOT_FILES_DIR/vim/includes/plugins.vimrc +PlugUpdate +qall'
fi
echo ""

# TODO call project setup.sh

echo "  [${BLUE}${BOLD}RECOMMENDATIONS${NORMAL}]:"
echo ""
echo "     ... installs dependencies"
echo "     \`brew install ack coreutils ctags cabal ghc neovim rbenv yarn \\"
echo "                   rustup-init go tig python2 python3 swaks htop\`"
echo "      - \`rustup update\` should update rust"
echo "      - \`rbenv install 2.6.5\` installs journal version"
echo ""
echo "     ... optional if doing \`ruby\`"
echo "     \`[rbenv exec] gem install ripper-tags\`"
echo ""
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "  [${BLUE}${BOLD}macOS${NORMAL}]:"
  echo ""
  echo "     ... on macOS"
  echo "     Install \`alacritty\`"
  echo ""
  echo "     ... sets up OS X in a nice way"
  echo "     \`~/.hiren/osx.sh\`"
  echo ""
else
  echo "  [${BLUE}${BOLD}Other POSIX${NORMAL}]: (assumes Ubuntu family)"
  echo ""
  echo "     ... sets up Ubuntu in a nice way"
  echo "     \`sudo apt-get install dconf-cli uuid-runtime golang ctags yarn rustup\`"
  echo ""
fi
echo "     ... ligatures and nice mono-space font"
echo "     Install \`hasklig\` font"
echo ""
echo "     Setup \`iTerm2\` to use the configs in \`$DOT_FILES_DIR/iterm\`"
echo ""
if [ -n "$DOT_FILES_ENV" ] && [ -e "setup.$DOT_FILES_ENV.sh" ]; then
  echo "  $DOT_FILES_ENV_DISPLAY:"
  echo ""
  echo "     For \`$DOT_FILES_ENV\` context specific install, try:"
  echo "       - \`~/.hiren/setup.$DOT_FILES_ENV.sh\`"
  echo ""
fi
echo "Done!"
echo ""
