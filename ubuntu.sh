sudo apt-get install software-properties-common

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

curl -sS https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google.list

sudo add-apt-repository ppa:hvr/ghc

sudo apt-get update

bash -c  "$(wget -qO- https://git.io/vQgMr)"

curl https://sh.rustup.rs -sSf | sh

sudo apt-get install -y dconf-cli uuid-runtime golang ctags yarn ghc neovim rbenv
