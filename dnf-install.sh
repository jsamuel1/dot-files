#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

subheading "installing base dnf packages"

sudo dnf -y install dnf-plugins-core
sudo dnf -y install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://rtx.pub/rpm/rtx.repo
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

if is_amazonlinux2023; then
	sudo dnf -y install docker
	sudo systemctl enable docker
	sudo systemctl start docker
	sudo usermod -aG docker "$(whoami)"
fi

if [[ $GUI -eq 1 ]]; then
	subheading "installing vscode"
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
		sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
		sudo dnf check-update
	fi
	sudo dnf -y install code
fi


arkxargs "dnfrequirements.txt" sudo dnf -y install

scriptfooter "${BASH_SOURCE:-$_}"