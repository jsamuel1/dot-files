#!/usr/bin/env bash
# derived from
#from https://gist.github.com/kawaz/393c7f62fe6e857cc3d9
#and https://gist.github.com/darcyparker/153124662b05c679c417

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

if is_amazonlinux2; then
	sudo yum groups install -y Development\ tools
	sudo yum install openssl11-devel wget -y

	(
		if ! command -v cmake; then
			cd "$(mktemp -d)" || exit
			wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1.tar.gz
			tar -xvzf cmake-3.22.1.tar.gz
			cd cmake-3.22.1 || exit
			./bootstrap
			make
			sudo make install || exit
		fi
	)
elif is_amazonlinux2023; then
	sudo yum groups install -y Development\ tools
	sudo yum install openssl-devel wget cmake python python-devel python-pip -y
elif is_like_debian; then
	sudo apt-get -y install ninja-build gettext cmake unzip curl lua5.4 luarocks aspell
else
	heading "ERROR - Unknown OS" "Bailing" "neovim installation aborted"
	exit 1
fi

pip3 install pynvim setuptools --upgrade
gem install neovim
npm install -g neovim

(
	if ! clone_or_pull https://github.com/neovim/neovim ~/src/neovim; then
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
	fi
)

scriptfooter "${BASH_SOURCE:-$_}"
