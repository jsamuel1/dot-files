#!/usr/bin/env bash
# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

(
	#Get or update github repo
	if ! clone_or_pull https://github.com/dylanaraps/neofetch ~/src/neofetch; then
		pushd . >/dev/null || exit
		cd ~/src/neofetch || exit
		sudo make install PREFIX=/usr/local
		popd >/dev/null || exit
	fi
)

scriptfooter "${BASH_SOURCE:-$_}"
