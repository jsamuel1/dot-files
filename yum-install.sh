#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

subheading "installing base yum packages"


sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rtx.pub/rpm/rtx.repo
sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
	sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	sudo yum check-update
fi
sudo yum -y install code

awkxargs "dependencies/yumrequirements.txt" sudo yum -y install

scriptfooter "${BASH_SOURCE:-$_}"
