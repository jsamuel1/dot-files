#!/bin/bash

# Install base apt packages
echo ============================
echo installing base apt packages
echo ============================
xargs -a <(awk '! /^ *(#|$)/' "aptrequirements.txt") -r -- sudo apt -y install

echo =====================================
echo ensure nvim is our default vim editor
echo =====================================
sudo update-alternatives --set vim /usr/bin/nvim

# Install pyenv.  zshrc already setup to run it.
echo =================
echo downloading pyenv
echo =================
if [ ! -d ~/.pyenv ]; then
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
else
  echo already downloaded
fi

echo ====================
echo installing oh-my-zsh
echo ====================
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
  echo oz-my-zsh already installed
fi

echo zsh-autocompletion
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

echo zsh-syntax-highlighting
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

echo =====================
echo installing nerd-fonts
echo =====================
if [ ! -d ~/src/nerd-fonts ]; then
  git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1 ~/src/nerd-fonts/
  echo running nerd-fonts installer
  ~/src/nerd-fonts/install.sh
else
  echo nerd-fonts already exists
fi

echo =======================================================
echo installing latest hyper terminal from https://hyper.is/
echo =======================================================
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' hyper | grep "install ok installed" )
if [ "" == "$PKG_OK" ]; then
  wget https://releases.hyper.is/download/deb -O hyper.deb
  sudo apt -y install ./hyper.deb
  rm hyper.deb
else
  echo already installed
fi

echo ================================================
echo installing gitrocket into hyper terminal plugins
echo ================================================
if [ ! -d ~/.config/hyper/.hyper_plugins/node_modules/gitrocket ]; then
  mkdir -p ~/.config/hyper/.hyper_plugins/node_modules
  npm install --prefix ~/.config/hyper/.hyper_plugins gitrocket
fi

echo =================
echo installing vscode
echo =================
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

./settings.py

echo ========================
echo DONE
echo ========================
