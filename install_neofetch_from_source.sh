#!/usr/bin/env bash
# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

(
	#Get or update github repo
	clone_or_pull https://github.com/dylanaraps/neofetch ~/src/neofetch

	pushd . >/dev/null || exit
	cd ~/src/neofetch || exit
	sudo make install PREFIX=/usr/local
	popd >/dev/null || exit
)

scriptfooter "${BASH_SOURCE:-$_}"