#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

APTGET=(apt-get --option=Dpkg::Options::=--force-confold
	--option=Dpkg::options::=--force-unsafe-io
	--option=DPkg::Lock::Timeout=60
	--option=Dpkg::Use-Pty=0
	--assume-yes
	--quiet=2)

sudo install -dm 755 /etc/apt/keyrings
sudo "${APTGET[@]}" install software-properties-common

function install_key {
	# mode -- dearmor keyserver download
	mode="$1"
	key="$2"
	url="$2"
	filename="$3"

	if [ ! -f "/etc/apt/keyrings/${filename}" ]; then
		echo "creating /etc/apt/keyrings/${filename}"
		if [ "$mode" == "keyserver" ]; then
			gpg --no-default-keyring --keyring "./${filename}" --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key"
		elif [ "$mode" == "dearmor" ]; then
			wget -qO- "$url" | gpg --dearmor >"$filename"
		elif [ "$mode" == "download" ]; then
			wget -qO- "$url" >"$filename"
		fi
		sudo install -D -o root -g root -m 644 "$filename" "/etc/apt/keyrings/${filename}"
		rm -f "$filename"
		rm -f "$filename"'~'
	fi
}

function install_source_url {
	url="$1"
	listfile="$2"
	gpgfile="$3"
	distrover="${4:-stable}"
	branch="${5:-main}"
	if [ ! -f "/etc/apt/sources.list.d/${listfile}" ]; then
		echo "creating /etc/apt/sources.list.d/${listfile}"
		echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/${gpgfile}] ${url} ${distrover} ${branch}" |
			sudo tee "/etc/apt/sources.list.d/${listfile}" >/dev/null
	fi
}

function install_source_ppa {
	# eg. install_source_ppa git-core ppa
	# becomes:
	# git-core-ubuntu-ppa-jammy.list
	# deb https://ppa.launchpadcontent.net/git-core/ppa/ubuntu/ jammy main
	[ -f /etc/os-release ] && source /etc/os-release
	url="http://ppa.launchpad.net/$1/$2/$ID/"
	listfile="${1}-${ID}-${2}-${VERSION_CODENAME}.list"
	gpgfile="$1.gpg"
	install_source_url "$url" "$listfile" "$gpgfile" "$VERSION_CODENAME"
}

subheading "installing APT sources"

# git-core PPA doesn't work with Debian Buster
if [ "$(hostnamectl | grep Debian)" == "" ]; then
	install_key keyserver E1DD270288B4E6030699E45FA1715D88E1DF1F24 git-core.gpg
	install_source_ppa git-core ppa
fi
#sudo add-apt-repository ppa:neovim-ppa/stable --yes

install_key download https://cli.github.com/packages/githubcli-archive-keyring.gpg githubcli-archive-keyring.gpg
install_source_url https://cli.github.com/packages github-cli.list githubcli-archive-keyring.gpg

install_key dearmor https://rtx.pub/gpg-key.pub rtx-archive-keyring.gpg
install_source_url https://rtx.pub/deb rtx.list rtx-archive-keyring.gpg

install_key dearmor https://download.docker.com/linux/ubuntu/gpg docker.gpg
install_source_url https://download.docker.com/linux/ubuntu docker.list docker.gpg "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable

if [ ! -f /etc/apt/sources.list.d/microsoft-prod.list ]; then
	wget -q "https://packages.microsoft.com/config/${ID}/${VERSION_ID}/packages-microsoft-prod.deb"
	sudo "${APTGET[@]}" install ./packages-microsoft-prod.deb
fi

if [ -z "$WSL_DISTRO_NAME" ]; then
	subheading "installing vscode"
	install_key dearmor https://packages.microsoft.com/keys/microsoft.asc packages.microsoft.gpg
	install_source_url https://packages.microsoft.com/repos/code vscode.list packages.microsoft.gpg
	sudo "${APTGET[@]}" update >/dev/null
	sudo "${APTGET[@]}" install code
fi

subheading "Updating and upgrading packages"

sudo "${APTGET[@]}" update >/dev/null
sudo "${APTGET[@]}" upgrade

# docker-ce install instructions
if [ -z "$SKIP_DOCKER" ]; then
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo usermod -aG docker "$(whoami)"
fi
xargs -a <(awk '! /^ *(#|$)/' "aptrequirements.txt") -r -- sudo "${APTGET[@]}" install

scriptfooter "${BASH_SOURCE:-$_}"
