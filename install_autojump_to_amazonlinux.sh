#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

(

	clone_or_pull https://github.com/wting/autojump.git ~/src/autojump shallow

	pushd . >/dev/null || exit
	cd ~/src/autojump || exit
	sudo ./install.py

	popd >/dev/null || exit
)

scriptfooter "${BASH_SOURCE:-$_}"
