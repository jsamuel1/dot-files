#!/bin/bash

# Ask for the administrator password upfront
sudo true
MACOS=0
APT=0
DNF=0
GUI=1
YUM=0

if [ -n "$WSL_DISTRO_NAME" ]; then
	echo "${bold}"
	echo "Windows Subsystem for Linux (WSL) detection"
	echo "${normal}"
	GUI=0
fi

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

bold=$(tput bold)
normal=$(tput sgr0)

if [[ "$OSTYPE" =~ darwin* ]]; then
	echo "${bold}"
	echo ============================
	echo prepare MacOS
	echo ============================
	echo "${normal}"
	./macos.sh
	MACOS=1
elif [[ -f /etc/os-release && $(grep al2023 /etc/os-release) ]]; then
	DNF=1
	YUM=0
	APT=0
	GUI=0
elif [ "$(hostnamectl | grep 'Amazon Linux 2')" != "" ]; then
	DNF=0
	YUM=1
	APT=0
elif [ "$(hostnamectl | grep Debian)" != "" ]; then
	echo "${bold}"
	echo ============================
	echo upgrade debian to buster
	echo ============================
	echo "${normal}"
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
	echo "${bold}"
	echo ===============================
	echo chromebook preconfig for ubuntu
	echo ===============================
	echo "${normal}"
	./fix-cros-ui-config-pkg.sh
	APT=1
	DNF=0
	YUM=0
else
	echo '=='
	echo Standard APT install
	echo '=='
	APT=1
	DNF=0
	YUM=0
fi

# Install base apt packages
if [[ $APT -ne 0 ]]; then
	echo "${bold}"
	echo ============================
	echo installing base apt packages
	echo ============================
	echo "${normal}"

	. ./apt-install.sh
fi

if [[ $YUM -ne 0 ]]; then
	echo "${bold}"
	echo ============================
	echo installing base yum packages
	echo ============================
	echo "${normal}"
	yum install -y yum-utils
  yum-config-manager --add-repo https://rtx.pub/rpm/rtx.repo
	xargs -a <(awk '! /^ *(#|$)/' "yumrequirements.txt") -r -- sudo yum -y install
fi

if [[ $DNF -ne 0 ]]; then
	echo "${bold}"
	echo ============================
	echo installing base dnf packages
	echo ============================
	echo "${normal}"
	. ./dnf-install.sh
fi

echo "${bold}"
echo ========================
echo installing rust
echo ========================
echo "${normal}"

. ./rust-install.sh

if [[ -x /usr/bin/nvim ]]; then
	echo "${bold}"
	echo =====================================
	echo ensure nvim is our default vim editor
	echo =====================================
	echo "${normal}"
	sudo update-alternatives --set vim /usr/bin/nvim
fi

echo "${bold}"
echo =================================
echo installing latest python for user
echo =================================
echo "${normal}"

rtx use -g python@3.12

echo "${bold}"
echo ================================
echo installing base python3 packages
echo ================================
echo "${normal}"
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade -r requirements.txt

echo "${bold}"
echo ================================
echo ensure latest npm and modules
echo ================================
echo "${normal}"
rtx install nodejs@lts
rtx global nodejs@lts
awk '! /^ *(#|$)/' "npmrequirements.txt" | xargs sudo npm install -g

echo "${bold}"
echo ================================
echo ensure latest go modules
echo ================================
echo "${normal}"
awk '! /^ *(#|$)/' "gorequirements.txt" | xargs go install

if [[ $GUI -eq 1 && $MACOS -eq 0 ]]; then
	echo "${bold}"
	echo =====================
	echo installing nerd-fonts
	echo =====================
	echo "${normal}"
	if [ ! -d ~/src/nerd-fonts ]; then
		git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1 ~/src/nerd-fonts/
		echo running nerd-fonts installer
		~/src/nerd-fonts/install.sh
	else
		echo nerd-fonts already exists
	fi
fi

if [[ $MACOS -eq 0 ]]; then
	echo "${bold}"
	echo ====================
	echo Installing/Updating AWS Cli 2
	echo ====================
	echo "${normal}"
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install --update
	rm -rf ./aws
	rm awscliv2.zip
fi

if [[ $GUI -eq 1 ]]; then
	## get list of extensions with code --list-extensions
	if type code >/dev/null; then
		code --list-extensions | grep -v -f - "vscodeextensions.txt" | awk '! /^ *(#|$)/' - | xargs -L1 code --force --install-extension
	fi
	if type code-insiders >/dev/null; then
		code-insiders --list-extensions | grep -v -f - "vscodeextensions.txt" | awk '! /^ *(#|$)/' - | xargs -L1 code-insiders --force --install-extension
	fi
fi

echo "${bold}"
echo ========================
echo update submodules
echo ========================
echo "${normal}"
git submodule update --init
git submodule foreach "(git checkout master; git pull; cd ..; git add \$path; git commit -m 'Submodule sync')"

echo "${bold}"
echo ========================
echo updating Dot Files
echo ========================
echo "${normal}"
./settings.py --no-dryrun

echo "${bold}"
echo ================================
echo ensure neovim ruby gem installed
echo ================================
echo "${normal}"

sudo mkdir -p /usr/local/opt/sqllite
sudo mkdir -p /usr/local/opt/zlib/lib

# install latest stable version and use globbaly
rtx use -g ruby
xargs -a <(awk '! /^ *(#|$)/' "gemrequirements.txt") -r -- gem install
gem environment

sudo chsh "$USER" -s /bin/zsh || true

echo "${bold}"
echo ========================
echo DONE
echo ========================
echo "${normal}"
