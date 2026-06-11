#!/usr/bin/env bash

# This script can either be run locally, or via curl as such:
#  sh -c "$(curl -fsSL https://raw.githubusercontent.com/jsamuel1/dot-files/main/bootstrap.sh)"
#
# Or if running via ssm/remote run commands, add in nohup
#  nohup sh -c "$(curl -fsSL https://raw.githubusercontent.com/jsamuel1/dot-files/main/bootstrap.sh)"

# Ensure USER and HOME are set -- when running first-time w/ SSM or in a container, these may not be.
export USER=${USER:-$(id -u -n)}
export HOME="${HOME:-$(eval echo "~${USER}")}"

GITREPO=${GITREPO:-dot-files}
GITORG=${GITORG:-jsamuel1}
GITREMOTE=${GITREMOTE:-https://github.com/${GITORG}/${GITREPO}.git}
BRANCH=${BRANCH:-main}
UPDATE=${UPDATE:-1}

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
	exec bash -c "UPDATE=0 ./bootstrap.sh" "${@}"
fi

echo "running from $(pwd)"
echo "home: ${HOME}"
echo "user: ${USER}"

if [ "${UPDATE}" -ne 0 ]; then
	echo "updating"
	git pull origin "${BRANCH}"
	exec bash -c "UPDATE=0 ./bootstrap.sh" "${@}"
fi

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

# Keep-alive: update existing `sudo` time stamp until script has finished
sudo_alive

# Ask for the administrator password upfront
APT=0
DNF=0
YUM=0
SKIPAWSCLI=0

if is_wsl; then
	subsubheading "Windows Subsystem for Linux (WSL) detected"
fi

if is_mac; then
	subsubheading "MacOS detected"
	./macos.sh
elif is_amazonlinux2023; then
	subsubheading "Amazon Linux 2023 detected"
	DNF=1
	YUM=0
	APT=0
	SKIPAWSCLI=1
elif is_amazonlinux2; then
	subsubheading "Amazon Linux 2 detected"
	DNF=0
	YUM=1
	APT=0
elif [ -v SOMMELIER_VERSION ]; then
	subsubheading "Linux on chromebook detected"
	# run to fix some ubuntu issues
	./fix-cros-ui-config-pkg.sh
	APT=1
	DNF=0
	YUM=0
elif command -v dnf >/dev/null; then
	APT=0
	DNF=1
	YUM=0
elif command -v apt >/dev/null; then
	APT=1
	DNF=0
	YUM=0
fi

# Install base apt packages
[[ $APT -ne 0 ]] && source ./apt-install.sh
[[ $YUM -ne 0 ]] && source ./yum-install.sh
[[ $DNF -ne 0 ]] && source ./dnf-install.sh

source ./mise-tools-install.sh

# rust must be after ruby and node
source ./rust-install.sh

source ./tools_install_from_source.sh

if [[ -x /usr/bin/nvim ]]; then
	subheading "ensure nvim is our default vim editor"
	sudo update-alternatives --set vim /usr/bin/nvim
fi

if ! is_mac && ! is_wsl; then
	heading "installing nerd-fonts"
	if ! clone_or_pull https://github.com/ryanoasis/nerd-fonts.git ~/src/nerd-fonts/ shallow; then
		~/src/nerd-fonts/install.sh
	fi
fi

if ! is_mac && [[ $SKIPAWSCLI -eq 0 ]]; then
	if [ "$UPDATE" -eq 1 ] || ! command -v aws >/dev/null || [[ "$(aws --version)" != *"aws-cli/2"* ]]; then
		heading "Installing/Updating AWS Cli 2"
		curl "https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip" -o "awscliv2.zip"
		unzip -q awscliv2.zip
		sudo ./aws/install --update
		rm -rf ./aws
		rm awscliv2.zip
	fi
fi

# MacOS will handle VSCode extension withs Brew
# All other OS will install with code --install-extension
if ! is_mac && ! is_wsl; then
	## get list of extensions with code --list-extensions
	if command -v code >/dev/null; then
		code --list-extensions | grep -v -f - "dependencies/vscodeextensions.txt" | awk '!/^[[:space:]]*(#|$)/' - | xargs -r -L1 code --force --install-extension
	fi
	if command -v code-insiders >/dev/null; then
		code-insiders --list-extensions | grep -v -f - "dependencies/vscodeextensions.txt" | awk '!/^[[:space:]]*(#|$)/' - | xargs -r -L1 code-insiders --force --install-extension
	fi
fi

scriptheader "settings.py"
./settings.py --no-dryrun
scriptfooter "settings.py"

subheading "Searching for broken symlinks"
cleanup_broken_symlinks "${HOME}" true
cleanup_broken_symlinks "${HOME}/.config"
cleanup_broken_symlinks "${HOME}/.local"
cleanup_broken_symlinks "${HOME}/.zsh"
cleanup_broken_symlinks "${HOME}/.ssh"
cleanup_broken_symlinks "${HOME}/.pyenv"
cleanup_broken_symlinks "${HOME}/.docker"

subheading "git config stub"
# ~/.gitconfig is a real, machine-local file (user.email etc.) that includes
# the shared config via ~/.gitconfig-shared. This keeps `git config --global`
# writes on the machine instead of polluting the repo.
# Migrate from the old setup where ~/.gitconfig was a symlink into this repo.
if [ -L "${HOME}/.gitconfig" ]; then
	rm "${HOME}/.gitconfig"
fi
if [ ! -f "${HOME}/.gitconfig" ]; then
	cat >"${HOME}/.gitconfig" <<-'EOF'
		# Machine-local git config — safe target for `git config --global`.
		# Shared settings come from the include below (symlinked from dot-files).
		[include]
			path = ~/.gitconfig-shared
	EOF
	echo "Created ~/.gitconfig stub."
fi
if [ -z "$(git config --global user.email || true)" ]; then
	subsubheading "NOTE: no git email set for this machine." "Run: git config --global user.email <you@example.com>"
fi

subheading "Installing Shell integrations"

mise trust "${HOME}/.config/mise/config.toml"

if [ -f "${HOME}/.iterm2_shell_integration.zsh" ]; then
	subheading "installing iterm2 integrations"
	curl -sL https://iterm2.com/shell_integration/install_shell_integration.sh | SHELL=zsh bash >/dev/null
fi

subheading "Installing zsh plugins and theme"
"${HOME}/.local/bin/update-zsh-plugins.sh"

# Set zsh as default shell
if ! is_mac && [[ "$(awk -F: -v u="${USER}" 'u==$1&&$0=$NF' /etc/passwd)" != "$(which zsh)" ]]; then
  sudo chsh -s "$(which zsh)" "$(whoami)" || true
elif is_mac && [[ "$(dscl . -read /Users/"$USER" UserShell | cut -d' ' -f2)" != "$(which zsh)" ]]; then
  sudo dscl . -create "/Users/${USER}" UserShell "$(which zsh)"
fi

scriptfooter "${BASH_SOURCE:-$_}"
