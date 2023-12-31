#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

(
	# clone return value False = new or changed  (True = unchanged)
	if ! clone_or_pull https://github.com/wting/autojump.git ~/src/autojump shallow; then
		pushd . >/dev/null || exit
		cd ~/src/autojump || exit
		popd >/dev/null || exit
	fi
)

scriptfooter "${BASH_SOURCE:-$_}"
