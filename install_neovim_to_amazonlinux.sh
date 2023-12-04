#!/usr/bin/env bash
#from https://gist.github.com/kawaz/393c7f62fe6e857cc3d9

VERSION=0

# shellcheck disable=SC1091
[ -f /etc/os-release ] && source /etc/os-release

sudo yum groups install -y Development\ tools

if [ "$VERSION" = "2" ]; then
    sudo yum install openssl11-devel wget -y

    (
        cd "$(mktemp -d)" || exit
        wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1.tar.gz
        tar -xvzf cmake-3.22.1.tar.gz
        cd cmake-3.22.1 || exit
        ./bootstrap
        make 
        sudo make install || exit
    )
else
    sudo yum install openssl-devel wget cmake python-devel -y
fi

sudo pip3 install neovim --upgrade

(
    cd "$(mktemp -d)" || exit
    git clone https://github.com/neovim/neovim.git
    cd neovim || exit
    make CMAKE_BUILD_TYPE=Release
    sudo make install
)
