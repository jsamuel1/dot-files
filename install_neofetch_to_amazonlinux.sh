#!/usr/bin/env bash
(
	pushd . >/dev/null || exit

	#Get or update github repo
	mkdir -p ~/src
	cd ~/src || exit
	if [ ! -e ~/src/neovim ]; then
		git clone https://github.com/dylanaraps/neofetch
	else
		cd neofetch || exit
		git pull origin master

		# don't build if installed nvim is same git hash
		# shellcheck disable=SC2143
		[[ $(which neofetch) &&
		"$(neofetch --version)" -eq "$(./neofetch --version)" ]] &&
			exit
	fi

	cd ~/src/neofetch || exit
  sudo make install
)

