#!/usr/bin/env bash
#from https://gist.github.com/kawaz/393c7f62fe6e857cc3d9
sudo yum groups install -y Development\ tools

sudo yum install openssl11-devel wget -y

(
cd "$(mktemp -d)"
wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1.tar.gz
tar -xvzf cmake-3.22.1.tar.gz
cd cmake-3.22.1
./bootstrap
make
sudo make install
)

sudo pip3 install neovim --upgrade --user

(
cd "$(mktemp -d)"
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=Release
sudo make install
)
