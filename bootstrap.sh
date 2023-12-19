#!/usr/bin/env bash

# This script can either be run locally, or via curl as such:
#  sh -c "$(curl -fsSL https://raw.githubusercontent.com/jsamuel1/dot-files/master/bootstrap.sh)"

# Ensure USER and HOME are set -- when running first-time w/ SSM or in a container, these may not be.
USER=${USER:-$(id -u -n)}
HOME="${HOME:-$(eval echo "~${USER}")}"

GITREPO=${GITREPO:-dot-files}
GITORG=${GITORG:-jsamuel1}
GITREMOTE=${GITREMOTE:-https://github.com/${GITORG}/${GITREPO}.git}
BRANCH=${BRANCH:-master}
UPDATE=${UPDATE:-0}

# if current directory is a git repo, use it.
# if not, is there a git repo in $HOME/src/$GITREPO?
# if not, we'll clone to a new directory
# then run from that directory
if [ ! -d .git ]; then
	if [ ! -d "${HOME}/src/${GITREPO}/.git" ]; then
		echo "cloning ${GITREMOTE}"
		git clone "${GITREMOTE}" "${HOME}/src/${GITREPO}" --branch "${BRANCH}" --depth 1
	fi
	echo "cd ${HOME}/src/${GITREPO}"
	cd "${HOME}/src/${GITREPO}" || exit 1
fi

echo "running from $(pwd)"

if [ "${UPDATE}" -ne 0 ]; then
	echo "updating"
	git pull origin "${BRANCH}"
	git submodule update --init --recursive
	git submodule foreach git pull origin "${BRANCH}"
fi

# shellcheck source=./helpers.sh
source ./helpers.sh

# Ask for the administrator password upfront
sudo true
MACOS=0
APT=0
DNF=0
GUI=1
YUM=0
SKIPAWSCLI=0

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

if is_mac; then
	heading "prepare MacOS"
	./macos.sh
	MACOS=1
elif is_amazonlinux2023; then
	DNF=1
	YUM=0
	APT=0
	GUI=0
	SKIPAWSCLI=1
elif is_amazonlinux2; then
	DNF=0
	YUM=1
	APT=0
elif [ "$(hostnamectl | grep Debian)" != "" ]; then
	APT=1
	DNF=0
	YUM=0
elif [ -v SOMMELIER_VERSION ]; then
	heading "chromebook preconfig for ubuntu"
	./fix-cros-ui-config-pkg.sh
	APT=1
	DNF=0
	YUM=0
else
	subheading "Standard APT install"
	APT=1
	DNF=0
	YUM=0
fi

# Install base apt packages
if [[ $APT -ne 0 ]]; then
	subheading "installing base apt packages"

	. ./apt-install.sh
fi

if [[ $YUM -ne 0 ]]; then
	subheading "installing base yum packages"
	yum install -y yum-utils
	yum-config-manager --add-repo https://rtx.pub/rpm/rtx.repo
	xargs -a <(awk '! /^ *(#|$)/' "yumrequirements.txt") -r -- sudo yum -y install
fi

if [[ $DNF -ne 0 ]]; then
	subheading "installing base dnf packages"
	. ./dnf-install.sh
fi

heading "installing local tools with rtx"
rtx install

heading "installing latest python for user"
rtx use -g python

subheading "installing base python3 packages"
rtx x -- python3 -m pip install --upgrade pip | grep -v 'already satisfied'
rtx x -- python3 -m pip install --upgrade -r requirements.txt | grep -v 'already satisfied'

heading "ensure latest npm and modules"
rtx use -g nodejs@lts
awk '! /^ *(#|$)/' "npmrequirements.txt" | xargs rtx x -- npm install -g

rtx use -g go
heading "ensure latest go modules"
awk '! /^ *(#|$)/' "gorequirements.txt" | xargs go install

subheading "ensure neovim ruby gem installed"

sudo mkdir -p /usr/local/opt/sqllite
sudo mkdir -p /usr/local/opt/zlib/lib

# install latest stable version and use globbaly
rtx use -g ruby
xargs -a <(awk '! /^ *(#|$)/' "gemrequirements.txt") -r -- rtx x -- gem install
rtx x -- gem environment

# rust must be after ruby and node
heading "installing rust"
. ./rust-install.sh

if is_amazonlinux2023; then
	subheading "installing base amazonlinux2023 tools"
	. ./amazonlinux2023-install.sh
fi

if [[ -x /usr/bin/nvim ]]; then
	subheading "ensure nvim is our default vim editor"
	sudo update-alternatives --set vim /usr/bin/nvim
fi

if [[ $GUI -eq 1 && $MACOS -eq 0 ]]; then
	heading "installing nerd-fonts"
	if [ ! -d ~/src/nerd-fonts ]; then
		git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1 ~/src/nerd-fonts/
		subheading "running nerd-fonts installer"
		~/src/nerd-fonts/install.sh
	else
		subheading "running nerd-fonts installer"
	fi
fi

if [[ $MACOS -eq 0 && $SKIPAWSCLI -eq 0 ]]; then
	heading "Installing/Updating AWS Cli 2"
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

heading "update submodules"
git submodule update --init
git submodule foreach "(git checkout master; git pull; cd ..; git add \$path; git commit -m 'Submodule sync')"

heading "updating Dot Files"
./settings.py --no-dryrun

. ./install_oh_my_zsh.sh

heading "DONE"
