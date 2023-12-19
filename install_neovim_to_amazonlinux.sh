#!/usr/bin/env bash
# derived from
#from https://gist.github.com/kawaz/393c7f62fe6e857cc3d9
#and https://gist.github.com/darcyparker/153124662b05c679c417

# shellcheck source=./helpers.sh
source ./helpers.sh

is_amazonlinux2 || is_amazonlinux2023 || exit

sudo yum groups install -y Development\ tools

if is_amazonlinux2; then
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
	sudo yum install openssl-devel wget cmake python python-devel python-pip -y
fi

pip3 install pynvim setuptools --upgrade
gem install neovim
npm install -g neovim

(
	clone_or_pull https://github.com/neovim/neovim ~/src/neovim

	# don't build if installed nvim is same git hash
	if which nvim &&
		nvim -v | grep -q "$(git -C ~/src/neovim rev-parse --short HEAD)"; then
		exit 0
	fi

	pushd . >/dev/null || exit
	cd ~/src/neovim || exit
	git checkout
	make distclean
	make CMAKE_BUILD_TYPE=Release
	sudo make install

	popd >/dev/null || exit
)
