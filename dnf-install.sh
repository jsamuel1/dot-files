#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

sudo dnf install -y dnf-plugins-core
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://rtx.pub/rpm/rtx.repo
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

xargs -a <(awk '! /^ *(#|$)/' "dnfrequirements.txt") -r -- sudo dnf -y install

sudo usermod -aG docker "$(whoami)"

if [[ $GUI -eq 1 ]]; then
	echo "${bold}"
	echo =================
	echo installing vscode
	echo =================
	echo "${normal}"
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
		sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
		sudo dnf check-update
	fi
	sudo dnf -y install code
fi

scriptfooter "${BASH_SOURCE:-$_}"