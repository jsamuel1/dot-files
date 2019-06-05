#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

if [[ "$OSTYPE" =~ darwin* ]]; then
  echo ${bold}
  echo ============================
  echo prepare MacOS
  echo ============================
  echo ${normal}
  sudo xcode-select --install
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
  xargs -a <(awk '! /^ *(#|$)/' "brewrequirements.txt") -r -- brew install
  xargs -a <(awk '! /^ *(#|$)/' "caskrequirements.txt") -r -- brew cask install
elif [ "`hostnamectl | grep Debian`" != "" ]; then
  echo ${bold}
  echo ============================
  echo upgrade debian to buster
  echo ============================
  echo ${normal}
  sudo sed -i s/stretch/buster/g /etc/apt/sources.list
  sudo sed -i s/stretch/buster/g /etc/apt/sources.list.d/cros.list
  sudo sed -i s/stretch/buster/g /etc/apt/sources.list.d/cros-gpu.list
  sudo apt update
  sudo apt upgrade -y
  sudo apt full-upgrade -y
  sudo apt auto-remove -y
elif [ -v SOMMELIER_VERSION ]; then
  echo ${bold}
  echo ===============================
  echo chromebook preconfig for ubuntu
  echo ===============================
  echo ${normal}
  ./fix-cros-ui-config-pkg.sh
fi

# Install base apt packages
if ! [[ "$OSTYPE" =~ darwin* ]]; then
  echo ${bold}
  echo ============================
  echo installing base apt packages
  echo ============================
  echo ${normal}
  xargs -a <(awk '! /^ *(#|$)/' "aptrequirements.txt") -r -- sudo apt -y install

  echo ${bold}
  echo =====================================
  echo ensure nvim is our default vim editor
  echo =====================================
  echo ${normal}
  sudo update-alternatives --set vim /usr/bin/nvim
fi

# Install pyenv.  zshrc already setup to run it.
echo ${bold}
echo =================
echo downloading pyenv
echo =================
echo ${normal}
if [ ! -d ~/.pyenv ]; then
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  # temporary - zshrc will have these already for persistence
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
else
  echo ${bold}already downloaded${normal}
fi

if [ ! -d ~/.pyenv/plugins/xxenv-latest ]; then
  git clone https://github.com/momo-lab/xxenv-latest.git $(pyenv root)/plugins/xxenv-latest
fi

if [ ! -d ~/.pyenv/plugins/pyenv-virtualenv ]; then
  git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv
fi

eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init - bash)"

echo ${bold}
echo =================================
echo installing latest python for user
echo =================================
echo ${normal}

if ! [[ "$OSTYPE" =~ darwin* ]]; then
  export LDFLAGS="${LDFLAGS} -L/usr/local/opt/zlib/lib"
  export CPPFLAGS="${CPPFLAGS} -I/usrlocal/opt/zlib/include"
  export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/zlib/lib/pkgconfig"

  export LDFLAGS="${LDFLAGS} -L/usr/local/opt/sqllite/lib"
  export CPPFLAGS="${CPPFLAGS} -I/usrlocal/opt/sqllite/include"
  export PKG_CONFIG_PATH="${PKG_CONFIG_PATH} /usr/local/opt/sqllite/lib/pkgconfig"
fi
pyenv latest install 2 -s
pyenv latest install 3 -s
pyenv latest global
pyenv virtualenv `pyenv latest --print 3` neovim3
pyenv virtualenv `pyenv latest --print 2` neovim2

echo ${bold}
echo ================================
echo installing base python3 packages
echo ================================
echo ${normal}
python3 -m pip install --upgrade pip

if ! [[ "$OSTYPE" =~ darwin* ]]; then
  python3 -m pip install --upgrade -r requirements.txt
fi
pyenv activate neovim3
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade -r neovim-requirements.txt
pyenv deactivate
pyenv activate neovim2
python -m pip install --upgrade pip
python -m pip install --upgrade -r neovim-requirements.txt
pyenv deactivate

echo ${bold}
echo =================
echo ensure latest npm
echo =================
echo ${normal}
sudo npm install -g npm@latest
sudo npm install -g neovim

echo ${bold}
echo ================================
echo ensure neovim ruby gem installed
echo ================================
echo ${normal}
sudo gem install neovim
sudo gem environment

echo ${bold}
echo ====================
echo installing oh-my-zsh
echo ====================
echo ${normal}
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
else
  echo oz-my-zsh already installed
fi

echo ${bold}
echo zsh-autocompletion
echo ${normal}
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

echo ${bold}
echo zsh-syntax-highlighting
echo ${normal}
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

echo ${bold}
echo =====================
echo installing nerd-fonts
echo =====================
echo ${normal}
if [ ! -d ~/src/nerd-fonts ]; then
  git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1 ~/src/nerd-fonts/
  echo running nerd-fonts installer
  ~/src/nerd-fonts/install.sh
else
  echo nerd-fonts already exists
fi


if ! [[ "$OSTYPE" =~ darwin* ]]; then
  echo ${bold}
  echo =======================================================
  echo installing latest hyper terminal from https://hyper.is/
  echo =======================================================
  echo ${normal}

  PKG_OK=$(dpkg-query -W --showformat='${Status}\n' hyper | grep "install ok installed" )
  if [ "" == "$PKG_OK" ]; then
    wget https://releases.hyper.is/download/deb -O hyper.deb
    sudo apt -y install ./hyper.deb
    rm hyper.deb
  else
    echo ${bold}already installed${normal}
  fi
  echo ${bold}
  echo ================================================
  echo installing gitrocket into hyper terminal plugins
  echo ================================================
  echo ${normal}
  if [ ! -d ~/.config/hyper/.hyper_plugins/node_modules/gitrocket ]; then
    mkdir -p ~/.config/hyper/.hyper_plugins/node_modules
    npm install --prefix ~/.config/hyper/.hyper_plugins gitrocket
  fi
fi

if ! [[ "$OSTYPE" =~ darwin* ]]; then
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
echo ========================
echo updating Dot Files
echo ========================
echo ${normal}
./settings.py --no-dryrun

echo ${bold}
echo ===================================
echo ensure nvim vim-plug is up to date
echo ===================================
echo ${normal}
nvim --headless +PlugUpgrade +qa
nvim --headless +PlugInstall +qa
nvim --headless +UpdateRemotePlugins +qa

echo ${bold}
echo ========================
echo DONE
echo ========================
echo ${normal}
