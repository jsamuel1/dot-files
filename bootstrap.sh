#!/usr/bin/env bash

# This script can either be run locally, or via curl as such:
#  sh -c "$(curl -fsSL https://raw.githubusercontent.com/jsamuel1/dot-files/master/bootstrap.sh)"
#
# Or if running via ssm/remote run commands, add in nohup
#  nohup sh -c "$(curl -fsSL https://raw.githubusercontent.com/jsamuel1/dot-files/master/bootstrap.sh)"

# Ensure USER and HOME are set -- when running first-time w/ SSM or in a container, these may not be.
export USER=${USER:-$(id -u -n)}
export HOME="${HOME:-$(eval echo "~${USER}")}"

GITREPO=${GITREPO:-dot-files}
GITORG=${GITORG:-jsamuel1}
GITREMOTE=${GITREMOTE:-https://github.com/${GITORG}/${GITREPO}.git}
BRANCH=${BRANCH:-master}
UPDATE=${UPDATE:-0}
GLOBAL=${GLOBAL:-0} # for installing global tools/packages only, not user prefs

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
echo "home: ${HOME}"
echo "user: ${USER}"


if [ "${UPDATE}" -ne 0 ]; then
	echo "updating"
	git pull origin "${BRANCH}"
	git submodule update --init --recursive
	git submodule foreach git pull origin "${BRANCH}"
fi

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

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
	source ./apt-install.sh
fi

if [[ $YUM -ne 0 ]]; then
	source ./yum-install.sh
fi

if [[ $DNF -ne 0 ]]; then
	source ./dnf-install.sh
fi

source ./rtx-tools-install.sh

# rust must be after ruby and node
heading "installing rust"
source ./rust-install.sh

if is_amazonlinux2023; then
	subheading "installing base amazonlinux2023 tools"
	source ./amazonlinux2023-install.sh
fi

if is_like_debian; then
	subheading "installing base debian/ubuntu tools"
	source ./debian-install.sh
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
	unzip -q awscliv2.zip
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

scriptheader "settings.py"
./settings.py --no-dryrun
scriptfooter "settings.py"

rtx trust "${HOME}/.config/rtx/config.toml"

source ./install_oh_my_zsh.sh

scriptfooter "${BASH_SOURCE:-$_}"
