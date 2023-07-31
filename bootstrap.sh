#!/bin/bash -x

# Ask for the administrator password upfront
sudo true
MACOS=0
APT=0
DNF=0
GUI=1
YUM=0

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
    ./macos.sh
    MACOS=1
  elif [[ -f /etc/os-release && `grep al2023 /etc/os-release` ]]; then
    DNF=1
    YUM=0
    APT=0
    GUI=0
  elif [ "`hostnamectl | grep 'Amazon Linux 2'`" != "" ]; then
    DNF=0
    YUM=1
    APT=0
  elif [ "`hostnamectl | grep Debian`" != "" ]; then
    echo ${bold}
    echo ============================
    echo upgrade debian to buster
    echo ============================
    echo ${normal}
    APT=1
    DNF=0
    YUM=0
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
    APT=1
    DNF=0
    YUM=0
  else
    echo ==
    echo Standard APT install
    echo ==
    APT=1
    DNF=0
    YUM=0
  fi

# Install base apt packages
if [[ $APT -ne 0 ]]; then
  echo ${bold}
  echo ============================
  echo installing base apt packages
  echo ============================
  echo ${normal}

  . ./apt-install.sh
fi

if [[ $YUM -ne 0 ]]; then
    echo ${bold}
    echo ============================
    echo installing base yum packages
    echo ============================
    echo ${normal}
  	xargs -a <(awk '! /^ *(#|$)/' "yumrequirements.txt") -r -- sudo yum -y install
fi

if [[ $DNF -ne 0 ]]; then
  echo ${bold}
  echo ============================
  echo installing base dnf packages
  echo ============================
  echo ${normal}
  . ./dnf-install.sh
fi

if [[ -x /usr/bin/nvim ]]; then
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

if [[ $MACOS -eq 0 ]]; then
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
python3 -m pip install --upgrade -r requirements.txt
pyenv activate neovim3
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade -r neovim-requirements.txt
pyenv deactivate

echo ${bold}
echo ================================
echo ensure latest npm and modules
echo ================================
echo ${normal}
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install 'lts/*' --latest-npm --reinstall-packages-from=current
awk '! /^ *(#|$)/' "npmrequirements.txt" | xargs sudo npm install -g

if [[ $GUI -eq 1 && $MACOS -eq 0 ]]; then
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

if [[ $MACOS -eq 0 ]]; then
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
fi

if [[ $GUI -eq 1 ]]; then
  ## get list of extensions with code --list-extensions
  if type code > /dev/null; then
    code --list-extensions | grep -v -f - "vscodeextensions.txt" | awk '! /^ *(#|$)/' - | xargs -L1 code --force --install-extension
  fi
  if type code-insiders > /dev/null; then
    code-insiders --list-extensions | grep -v -f - "vscodeextensions.txt" | awk '! /^ *(#|$)/' - | xargs -L1 code-insiders --force --install-extension
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

awk '! /^ *(#|$)/' "cargorequirements.txt"  | xargs -r -- cargo install

echo ${bold}
echo ===================================
echo ensure nvim Packer is up to date
echo ===================================
echo ${normal}
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
nvim --headless +PackerInstall +qa
nvim --headless +PackerUpdate +qa
nvim --headless +PackerClean +qa
nvim --headless +PackerCompile +qa
nvim --headless +TSUpdate +qa
echo ${bold}
echo ================================
echo ensure neovim ruby gem installed
echo ================================
echo ${normal}
eval "$(curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer)"
# for first time.   .zshrc will take care of this later
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# install last version without a dash in its name, skipping existing
rbenv install -s $(rbenv install -l | grep -v - | tail -1)
rbenv global $(rbenv install -l | grep -v - | tail -1)
xargs -a <(awk '! /^ *(#|$)/' "gemrequirements.txt") -r -- gem install
gem environment

echo ${bold}
echo ================================
echo fzf install / upgrade
echo ================================
echo ${normal}

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
else
  cd ~/.fzf && git pull && ./install && cd -
fi

sudo chsh $USER -s /bin/zsh

echo ${bold}
echo ========================
echo DONE
echo ========================
echo ${normal}
