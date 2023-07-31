#!/bin/bash

sudo apt install software-properties-common

# git-core PPA doesn't work with Debian Buster
if [ "`hostnamectl | grep Debian`" == "" ]; then
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key E1DD270288B4E6030699E45FA1715D88E1DF1F24
sudo add-apt-repository ppa:git-core/ppa --yes 
fi
sudo add-apt-repository ppa:neovim-ppa/stable --yes

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C99B11DEB97541F0
sudo apt-add-repository https://cli.github.com/packages --yes --update

sudo apt -y upgrade

xargs -a <(awk '! /^ *(#|$)/' "aptrequirements.txt") -r -- sudo apt -y install

if [ -z "$WSL_DISTRO_NAME" ]; then
  echo ${bold}
  echo =================
  echo installing vscode
  echo =================
  echo ${normal}
  if [ ! -f /etc/apt/trusted.gpg.d/microsoft.gpg ]; then
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
  fi
  if [ ! -f /etc/apt/sources.list.d/vscode.list  ]; then
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo apt update
  fi
  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' code | grep "install ok installed" )
  if [ "" == "$PKG_OK" ]; then
    sudo apt -y install code
  fi
fi

echo ${bold}
echo =================
echo installing powershell
echo =================
echo ${normal}
if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
    wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    sudo apt install ./packages-microsoft-prod.deb -y
    sudo apt update
fi
if [ ! -x /usr/bin/pwsh ]; then
    sudo apt install -y powershell
fi
