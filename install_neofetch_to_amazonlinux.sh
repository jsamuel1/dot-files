#!/usr/bin/env bash
(

	#Get or update github repo
	clone_or_pull https://github.com/dylanaraps/neofetch ~/src/neofetch

	pushd . >/dev/null || exit
	cd ~/src/neofetch || exit
	sudo make install
	popd >/dev/null || exit
)
