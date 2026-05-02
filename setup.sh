#!/usr/bin/env bash

export DOT_FILES_DIR="$HOME/.hiren"
source "$DOT_FILES_DIR/setup_utils.sh"

if [ -f /opt/homebrew/bin/brew ]; then
  echo "${BLUE}Found \`brew\` for Apple Silicon; sourcing...${NORMAL}"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  echo
elif [ -f /usr/local/bin/brew ]; then
  echo "${BLUE}Found \`brew\` for Intel; sourcing...${NORMAL}"
  eval "$(/usr/local/bin/brew shellenv)"
  echo
fi


if ! command -v zsh >/dev/null 2>&1; then
  echo "${RED}${BOLD}Zsh is not installed!${NORMAL} Please install zsh first!"
  exit
fi

TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
  echo "${BLUE}${BOLD}Time to change your default shell to zsh!${NORMAL}"
  echo "  \`chsh -s $(grep '/zsh$' '/etc/shells' | tail -1) $USER\`"
  exit 1
fi

function restore_setup_managed_hhighlighter_rename {
  if [ $# -eq 1 ]; then
    local repo_dir="$1"
    local legacy_status repo_status

    [ -d "$repo_dir/.git" ] || return 0

    legacy_status="$(printf ' D h.sh\n?? h.plugin.zsh')"
    repo_status="$(git -C "$repo_dir" status --short 2>/dev/null)" || return 0

    if [ "$repo_status" = "$legacy_status" ] && git -C "$repo_dir" show HEAD:h.sh | cmp -s - "$repo_dir/h.plugin.zsh"; then
      mv "$repo_dir/h.plugin.zsh" "$repo_dir/h.sh"
    fi
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`restore_setup_managed_hhighlighter_rename\` requires 1 argument"
    return 1
  fi
}

echo "${BLUE}${BOLD}..random directories..${NORMAL}"
mk_expected_dir "$HOME/.backup"
mk_expected_dir "$HOME/.screenlog"
mk_expected_dir "$HOME/.local/share/fzf-history"
mk_expected_dir "$HOME/.local/share/nvim/site/pack/packer/start/"
mk_expected_dir "$DOT_FILES_DIR/logs"
mk_expected_dir "$DOT_FILES_DIR/pyenvs"
echo

echo "${BLUE}${BOLD}\`made\` directory${NORMAL}"
mk_expected_dir "$DOT_FILES_DIR/made"
mk_expected_dir "$DOT_FILES_DIR/made/bin"
mk_expected_dir "$DOT_FILES_DIR/made/doc"
mk_expected_dir "$DOT_FILES_DIR/made/doc/man1"
echo

echo "${BLUE}${BOLD}neovim${NORMAL}"
mk_expected_dir "$HOME/.config/"
link_if_possible "$DOT_FILES_DIR/nvim" "$HOME/.config/nvim"
install_or_update_git_repo "packer.nvim" "git@github.com:wbthomason/packer.nvim" "$HOME/.local/share/nvim/site/pack/packer/start/packer.nvim" "master" "--depth 1"
echo
echo

echo "${BLUE}${BOLD}VS Code${NORMAL}"
VS_CODE_HOME="$HOME/Library/Application Support/Code/User"
mk_expected_dir "$VS_CODE_HOME"
link_if_possible "$DOT_FILES_DIR/code/settings.json" "$VS_CODE_HOME/settings.json"
link_if_possible "$DOT_FILES_DIR/code/keybindings.json" "$VS_CODE_HOME/keybindings.json"
echo

echo "${BLUE}${BOLD}Cursor AI IDE${NORMAL}"
CURSOR_HOME="$HOME/Library/Application Support/Cursor/User"
mk_expected_dir "$CURSOR_HOME"
link_if_possible "$DOT_FILES_DIR/cursor/settings.json" "$CURSOR_HOME/settings.json"
link_if_possible "$DOT_FILES_DIR/cursor/keybindings.json" "$CURSOR_HOME/keybindings.json"
echo

echo "${BLUE}${BOLD}gh-dash configurations${NORMAL} ${DOT_FILES_ENV_DISPLAY}"
link_if_possible "$DOT_FILES_DIR/gh-dash" "$HOME/.config/gh-dash"
echo

echo "${BLUE}${BOLD}IDEA-vim${NORMAL}"
link_if_possible "$DOT_FILES_DIR/ideavimrc" "$HOME/.ideavimrc"
echo

echo "${BLUE}${BOLD}Various Installs${NORMAL}:"
if command_exists fzf; then
  printf "  - ${BLUE}Found \`fzf\` ...${NORMAL}"
  run_and_print_status_symbol "found" "true"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    run_and_print_status_symbol "completions" "/opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc"
  else
    run_and_print_status_symbol "completions" "/usr/local/opt/fzf/install --key-bindings --completion --no-update-rc"
  fi
else
  install_or_update_git_repo "fzf" "git@github.com:junegunn/fzf.git" "$DOT_FILES_DIR/fzf" "master" && \
  run_and_print_status_symbol "build" "$DOT_FILES_DIR/fzf-install.sh > $DOT_FILES_DIR/logs/fzf-install-log 2> $DOT_FILES_DIR/logs/fzf-install-log"
fi
echo

if command_exists rg; then
  printf "  - ${BLUE}Found \`ripgrep\` ...${NORMAL}"
  run_and_print_status_symbol "found" "true"
elif command_exists rgrep; then
  printf "  - ${BLUE}Found \`rgrep\` ...${NORMAL}"
  run_and_print_status_symbol "found" "true"
else
  install_or_update_git_repo "ripgrep" "git@github.com:BurntSushi/ripgrep.git" "$DOT_FILES_DIR/ripgrep" "master" && \
  run_and_print_status_symbol "build" "$DOT_FILES_DIR/ripgrep-install.sh > $DOT_FILES_DIR/logs/ripgrep-install-log 2> $DOT_FILES_DIR/logs/ripgrep-install-log"
fi
echo

if command_exists bat; then
  printf "  - ${BLUE}Found \`bat\` ...${NORMAL}"
  run_and_print_status_symbol "found" "true"
elif command_exists batcat; then
  printf "  - ${BLUE}Found \`batcat\` ...${NORMAL}"
  run_and_print_status_symbol "found" "true"
else
  install_or_update_git_repo "bat" "git@github.com:sharkdp/bat.git" "$DOT_FILES_DIR/bat" "master" && \
  run_and_print_status_symbol "build" "$DOT_FILES_DIR/bat-install.sh > $DOT_FILES_DIR/logs/bat-install-log 2> $DOT_FILES_DIR/logs/bat-install-log"
fi
echo

if command_exists fd; then
  printf "  - ${BLUE}Found \`fd\` ...${NORMAL}"
  run_and_print_status_symbol "found" "true"
elif command_exists fdfind; then
  printf "  - ${BLUE}Found \`fdfind\` ...${NORMAL}"
  run_and_print_status_symbol "found" "true"
else
  install_or_update_git_repo "fd" "git@github.com:sharkdp/fd.git" "$DOT_FILES_DIR/fd" "master" && \
  run_and_print_status_symbol "build" "$DOT_FILES_DIR/fd-install.sh > $DOT_FILES_DIR/logs/fd-install-log 2> $DOT_FILES_DIR/logs/fd-install-log"
fi
echo

if [ -d "$DOT_FILES_DIR/pgdiff" ]; then
  printf "  - ${BLUE}Found \`pgdiff\` ...${NORMAL}"
  run_and_print_status_symbol "found" "true"
else
  printf "  - ${BLUE}Installing \`pgdiff\` ...${NORMAL}"
  run_and_print_status_symbol "mkdir" "mkdir $DOT_FILES_DIR/pgdiff" && \
  run_and_print_status_symbol "wget" "wget -O $DOT_FILES_DIR/pgdiff/pgdiff https://raw.githubusercontent.com/denvaar/pgdiff/main/pgdiff" && \
  run_and_print_status_symbol "chmod" "chmod +x $DOT_FILES_DIR/pgdiff/pgdiff"
fi
echo

install_or_update_git_repo "interactively" "git@github.com:bigH/interactively.git" "$DOT_FILES_DIR/interactively" "main"
echo

install_or_update_git_repo "git-fuzzy" "git@github.com:bigH/git-fuzzy.git" "$DOT_FILES_DIR/git-fuzzy" "main"
echo

install_or_update_git_repo "kube-fuzzy" "git@github.com:bigH/kube-fuzzy.git" "$DOT_FILES_DIR/kube-fuzzy" "main"
echo

install_or_update_git_repo "auto-sized-fzf" "git@github.com:bigH/auto-sized-fzf.git" "$DOT_FILES_DIR/auto-sized-fzf" "master"
echo

install_or_update_git_repo "agents-md" "git@github.com:bigH/agents-md.git" "$DOT_FILES_DIR/agents-md" "main" && \
run_and_print_status_symbol "generate" "\"$DOT_FILES_DIR/agents-md/generate-agent-instructions\""
echo

install_or_update_git_repo "oh-my-zsh" "git@github.com:ohmyzsh/ohmyzsh.git" "$DOT_FILES_DIR/.oh-my-zsh" "master"
echo

HHIGHLIGHTER_DIR="$DOT_FILES_DIR/.oh-my-zsh/custom/plugins/h"
restore_setup_managed_hhighlighter_rename "$HHIGHLIGHTER_DIR"
install_or_update_git_repo "zsh-hhighlighter" "git@github.com:paoloantinori/hhighlighter.git" "$HHIGHLIGHTER_DIR" "master" && \
run_and_print_status_symbol "plugin" "$(hhighlighter_plugin_setup_command "$HHIGHLIGHTER_DIR")" || exit 1
echo

install_or_update_git_repo "zsh-autosuggestions" "git@github.com:zsh-users/zsh-autosuggestions" "$DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-autosuggestions" "master"
echo

install_or_update_git_repo "zsh-syntax-highlighting" "git@github.com:zsh-users/zsh-syntax-highlighting.git" "$DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "master"
echo

install_or_update_git_repo "zsh-completions" "git@github.com:zsh-users/zsh-completions.git" "$DOT_FILES_DIR/.oh-my-zsh/custom/plugins/zsh-completions" "master"
echo

install_or_update_git_repo "pure" "git@github.com:sindresorhus/pure.git" "$DOT_FILES_DIR/pure" "main"
echo

printf "  - ${BLUE}Installing \`cheat.sh\` ...${NORMAL}"
run_and_print_status_symbol "mkdir" "mkdir -p $DOT_FILES_DIR/utils" && \
run_and_print_status_symbol "curl" "curl -o $DOT_FILES_DIR/utils/cht.sh https://cht.sh/:cht.sh" && \
run_and_print_status_symbol "chmod" "chmod +x $DOT_FILES_DIR/utils/cht.sh"
echo

printf "  - ${BLUE}Installing \`markdown2ctags\` ...${NORMAL}"
run_and_print_status_symbol "mkdir" "mkdir -p $DOT_FILES_DIR/utils" && \
run_and_print_status_symbol "curl" "curl -o $DOT_FILES_DIR/utils/markdown-ctags.py https://raw.githubusercontent.com/jszakmeister/markdown2ctags/master/markdown2ctags.py" && \
run_and_print_status_symbol "chmod" "chmod +x $DOT_FILES_DIR/utils/markdown-ctags.py"
echo

install_or_update_git_repo "fzf-tab-completion" "git@github.com:lincheney/fzf-tab-completion.git" "$DOT_FILES_DIR/fzf-tab-completion" "master"
echo

if [[ "$OSTYPE" == "darwin"* ]]; then
  install_or_update_git_repo "bigH/clipboard-listener-macos" "git@github.com:bigH/clipboard-listener-macos.git" "$DOT_FILES_DIR/clipboard-listener-macos" "main" && \
  run_and_print_status_symbol "build" "$(shell_command_in_dir "$DOT_FILES_DIR/clipboard-listener-macos" swift build -c release)"
fi

echo

echo "${BLUE}${BOLD}Linking Bash Setup${NORMAL}"
link_if_possible "$DOT_FILES_DIR/bashrc" "$HOME/.bashrc"
link_if_possible "$DOT_FILES_DIR/bash_profile" "$HOME/.bash_profile"
echo

echo "${BLUE}${BOLD}Linking ZSH Setup${NORMAL}"
link_if_possible "$DOT_FILES_DIR/zshrc" "$HOME/.zshrc"
link_if_possible "$DOT_FILES_DIR/zprofile" "$HOME/.zprofile"
link_if_possible "$DOT_FILES_DIR/.oh-my-zsh" "$HOME/.oh-my-zsh"
echo

echo "${BLUE}${BOLD}git configurations${NORMAL} ${DOT_FILES_ENV_DISPLAY}"
if [ -n "$DOT_FILES_ENV" ] && [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/gitignore_global" ]; then
  link_if_possible "$DOT_FILES_DIR/$DOT_FILES_ENV/gitignore_global" "$HOME/.gitignore_global"
else
  link_if_possible "$DOT_FILES_DIR/gitignore_global" "$HOME/.gitignore_global"
fi
if [ -n "$DOT_FILES_ENV" ] && [ -f "$DOT_FILES_DIR/$DOT_FILES_ENV/gitconfig" ]; then
  link_if_possible "$DOT_FILES_DIR/$DOT_FILES_ENV/gitconfig" "$HOME/.gitconfig"
else
  link_if_possible "$DOT_FILES_DIR/gitconfig" "$HOME/.gitconfig"
fi
echo

echo "${BLUE}${BOLD}Miscellany ...${NORMAL}"
mk_expected_dir "$HOME/.config/alacritty"
link_if_possible "$DOT_FILES_DIR/ackrc" "$HOME/.ackrc"
link_if_possible "$DOT_FILES_DIR/alacritty.yml" "$HOME/.alacritty.yml"
link_if_possible "$DOT_FILES_DIR/alacritty.yml" "$HOME/.config/alacritty/alacritty.yml"
link_if_possible "$DOT_FILES_DIR/clocignore" "$HOME/.clocignore"
link_if_possible "$DOT_FILES_DIR/ctags" "$HOME/.ctags"
link_if_possible "$DOT_FILES_DIR/fdignore" "$HOME/.fdignore"
link_if_possible "$DOT_FILES_DIR/fxrc" "$HOME/.fxrc"
link_if_possible "$DOT_FILES_DIR/inputrc" "$HOME/.inputrc"
link_if_possible "$DOT_FILES_DIR/pryrc" "$HOME/.pryrc"
link_if_possible "$DOT_FILES_DIR/rgignore" "$HOME/.rgignore"
link_if_possible "$DOT_FILES_DIR/tigrc" "$HOME/.tigrc"
link_if_possible "$DOT_FILES_DIR/nice-noise-loops" "$HOME/nice-noise-loops"
echo

echo "${BLUE}${BOLD}\`bin\` directory${NORMAL}"
link_if_possible "$DOT_FILES_DIR/bin" "$HOME/bin"
echo

if [[ "$OSTYPE" == "darwin"* ]]; then
  printf "${BLUE}${BOLD}Installing iTerm2 shell integration ...${NORMAL}"
  run_and_print_status_symbol "download" "curl -SsL https://iterm2.com/misc/zsh_startup.in > ~/.iterm2_shell_integration.zsh && chmod +x ~/.iterm2_shell_integration.zsh"
  echo
  echo
fi

echo
echo "${BLUE}${BOLD}RECOMMENDATIONS${NORMAL}:"
echo
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "  [${BLUE}${BOLD}macOS${NORMAL}]:"
  echo
  echo "     ... installs dependencies"
  echo "     \`brew install ack autojump bat bpytop broot cabal calc \\"
  echo "                   cloc coreutils direnv entr eza fd fzf fx gh \\"
  echo "                   ghc git-deltaglances go hot htop jq lnav \\"
  echo "                   multitail neovim numbat prettyping python3 \\"
  echo "                   rbenv ripgrep rustup-init shellcheck swaks \\"
  echo "                   tldr tig watch wget universal-ctags yq \\"
  echo "                   zsh-completions\`"
  echo "      - \`rustup update\` should update rust"
  echo "      - \`rbenv install 2.6.5\` installs journal version"
  echo
  echo "     ... install neovim plugins"
  echo "       \`nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'\`"
  echo
  echo "     ... optional if doing \`ruby\`"
  echo "       \`[rbenv exec] gem install ripper-tags\`"
  echo
  echo "     ... optional if doing \`node\`"
  echo "       Install \`nvm\`"
  echo
  echo "     ... on macOS"
  echo "       Install \`alacritty\`"
  echo
  echo "     ... sets up OS X in a nice way"
  echo "       \`~/.hiren/osx.sh\`"
  echo
  echo "     Setup \`iTerm2\` to use the configs in \`$DOT_FILES_DIR/iterm\`"
  echo
else
  echo "  [${BLUE}${BOLD}Other POSIX${NORMAL}]: (assumes Ubuntu family)"
  echo
  echo "     ... sets up Ubuntu in a nice way"
  echo "     \`sudo apt-get install -y bat cloc ctags dconf-cli fd-find fzf \\"
  echo "                              glances golang htop libsensors4-dev \\"
  echo "                              neovim ripgrep swaks uuid-runtime yarn\`"
  echo
  echo "     ... install \`rustup\`"
  echo "     \`curl https://sh.rustup.rs -sSf | sh\`"
  echo "      - \`rustup update\` should update rust"
  echo "      - \`cargo install hegemon\`"
  echo
fi
echo "     ... ligatures and nice mono-space font"
echo "     Install \`hasklig\` font"
echo
if [ -n "$DOT_FILES_ENV" ] && [ -e "setup.$DOT_FILES_ENV.sh" ]; then
  echo "  $DOT_FILES_ENV_DISPLAY:"
  echo
  echo "     For \`$DOT_FILES_ENV\` context specific install, try:"
  echo "       - \`~/.hiren/setup.$DOT_FILES_ENV.sh\`"
  echo
fi
echo "Done!"
echo
