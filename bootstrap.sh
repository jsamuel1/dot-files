#!/bin/bash

# Ask for the administrator password upfront
sudo true

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  bold=$(tput bold)
  normal=$(tput sgr0)

  if [[ "$OSTYPE" =~ darwin* ]]; then
    echo ${bold}
    echo ============================
    echo prepare MacOS
    echo ============================
    echo ${normal}
    if ! type brew > /dev/null; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    brew doctor
    brew install mas
    mas install 497799835   #xcode

    if ! type xcodebuild > /dev/null; then
      sudo xcode-select --install
    fi
    if ! xcodebuild -checkFirstLaunchStatus; then
      # enable developer mode
      sudo /usr/sbin/DevToolsSecurity -enable
      sudo /usr/sbin/dseditgroup -o edit -t group -a staff _developer
      # ensure first launch of xcode, otherwise commandline tools don't work
      sudo xcodebuild -license accept
      sudo xcodebuild -runFirstLaunch
    fi
    HOMEBREW_NO_ENV_FILTERING=1 ACCEPT_EULA=y brew bundle -v

    curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash

    ./macdefaults.sh

    if [ ! -d "/Applications/Google Chrome" ]; then
      temp=$TMPDIR$(uuidgen)
      mkdir -p $temp/mount
      curl https://dl.google.com/chrome/mac/beta/googlechrome.dmg > $temp/1.dmg
      yes | hdiutil attach -noverify -nobrowse -mountpoint $temp/mount $temp/1.dmg
      cp -r $temp/mount/*.app /Applications
      hdiutil detach $temp/mount
      rm -r $temp
    fi

    echo ${bold}
    echo ==============================
    echo Installing/Updating AWS CLI v2
    echo ==============================
    echo ${normal}
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
    sudo installer -pkg AWSCLIV2.pkg -target /
    rm AWSCLIV2.pkg

  elif [ "`hostnamectl | grep Debian`" != "" ]; then
    echo ${bold}
    echo ============================
    echo upgrade debian to buster
    echo ============================
    echo ${normal}
    sudo sed -i s/stretch/buster/g /etc/apt/sources.list
    sudo sed -i s/stretch/buster/g /etc/apt/sources.list.d/cros.list
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
  sudo apt install software-properties-common

  # git-core PPA doesn't work with Debian Buster
  if [ "`hostnamectl | grep Debian`" == "" ]; then
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key E1DD270288B4E6030699E45FA1715D88E1DF1F24
    sudo add-apt-repository ppa:git-core/ppa --yes --update
  fi
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0
  sudo apt-add-repository https://cli.github.com/packages
  sudo apt update

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
pyenv latest install 3 -s
pyenv latest global
pyenv virtualenv `pyenv latest --print 3` neovim3

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

echo ${bold}
echo ================================
echo ensure latest npm and modules
echo ================================
echo ${normal}
awk '! /^ *(#|$)/' "npmrequirements.txt" | xargs sudo npm install -g

if ! [[ "$OSTYPE" =~ darwin* ]]; then
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
fi

if ! [[ "$OSTYPE" =~ darwin* ]]; then
  echo ${bold}
  echo ====================
  echo Installing/Updating AWS Cli 2
  echo ====================
  echo ${normal}
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install --update
  rm -rf ./aws
  rm awscliv2.zip

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
    sudo apt -y install code code-insiders
  fi
fi


## get list of extensions with code --list-extensions
if type code > /dev/null; then
  awk '! /^ *(#|$)/' "vscodeextensions.txt" | xargs -L1 code --force --install-extension
fi
if type code-insiders > /dev/null; then
  awk '! /^ *(#|$)/' "vscodeextensions.txt" | xargs -L1 code-insiders --force --install-extension
fi

if ! [[ "$OSTYPE" =~ darwin* ]]; then
  echo ${bold}
  echo =================
  echo installing powershell
  echo =================
  echo ${normal}
  if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
    sudo apt install ./packages-microsoft-prod.deb -y
    sudo apt update
  fi
  if [ ! -x /usr/bin/pwsh ]; then
    sudo apt install -y powershell
  fi
fi
echo ${bold}
echo ========================
echo update submodules
echo ========================
echo ${normal}
git submodule update --init
git submodule foreach "(git checkout master; git pull; cd ..; git add \$path; git commit -m 'Submodule sync')"

echo ${bold}
echo ========================
echo updating Dot Files
echo ========================
echo ${normal}
./settings.py --no-dryrun

echo ${bold}
echo ========================
echo installing rust
echo ========================
echo ${normal}
# see https://github.com/rust-lang/rustup#other-installation-methods for options
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y
# add rust to the path before proceeding
source ~/.cargo/env

rustup component add rust-src

if [ ! -d ~/src/rust-analyzer ]; then
  git clone https://github.com/rust-analyzer/rust-analyzer --depth 1 ~/src/rust-analyzer/
  echo running rust-analyzer installer
  ( cd ~/src/rust-analyzer && cargo xtask install )
else
  echo rust-analyzer already exists
fi

echo ${bold}
echo ===================================
echo ensure nvim vim-plug is up to date
echo ===================================
echo ${normal}
nvim --headless +PlugUpgrade +qa
nvim --headless +PlugInstall +qa
nvim --headless +UpdateRemotePlugins +qa

echo ${bold}
echo ================================
echo ensure neovim ruby gem installed
echo ================================
echo ${normal}
eval "$(curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer)"
# for first time.   .zshrc will take care of this later
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# install last version without a dash in its name, skipping existing
rbenv install -s $(rbenv install -l | grep -v - | tail -1)
rbenv global $(rbenv install -l | grep -v - | tail -1)
gem install bundler
gem install neovim
gem environment

sudo chsh $USER -s /bin/zsh

echo ${bold}
echo ========================
echo DONE
echo ========================
echo ${normal}
