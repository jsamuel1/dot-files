#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

if ! type brew >/dev/null; then
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
brew doctor
if ! type mas >/dev/null; then
	brew install mas
fi
if ! type xcode-select >/dev/null; then
	mas install 497799835 #xcode
fi

if ! type xcodebuild >/dev/null; then
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

subheading "Installing brew bundle"
ACCEPT_EULA=y brew bundle --file="dependencies/Brewfile"

if [ ! -f "${HOME}/.iterm2_shell_integration.zsh" ]; then
	curl -L https://iterm2.com/shell_integration/zsh \
		-o ~/.iterm2_shell_integration.zsh
fi

./macdefaults.sh

# set /usr/local/bin/zsh as the default shell on macos using dscl, if it exists
if [ -f "/usr/local/bin/zsh" ] && [[ ! "$(dscl . -read "/Users/${USER}" UserShell)" =~ "UserShell:".*"/usr/local/bin/zsh"$ ]]; then
	sudo dscl . -create "/Users/${USER}" UserShell /usr/local/bin/zsh
	subheading "Default shell set to /usr/local/bin/zsh" "Restart your terminal to apply changes"
fi

if [ ! -d "/Applications/Google Chrome.app" ]; then
	subheading "Installing Google Chrome"
	temp=$TMPDIR$(uuidgen)
	curl https://dl.google.com/chrome/mac/stable/accept_tos%3Dhttps%253A%252F%252Fwww.google.com%252Fintl%252Fen_ph%252Fchrome%252Fterms%252F%26_and_accept_tos%3Dhttps%253A%252F%252Fpolicies.google.com%252Fterms/googlechrome.pkg >"$temp/googlechrome.pkg"
	sudo installer -pkg "$temp/googlechrome.pkg" -target /
	rm -r "$temp"
fi

subheading "iTerm2 config files"

if [ -f "${PWD}/iTerm2/com.googlecode.iterm2.plist" ]; then
	# Specify the preferences directory
	defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "${PWD}/iTerm2"
	# Tell iTerm2 to use the custom preferences in the directory
	defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
fi

for SOURCEDIR in "${PWD}/iTerm2"/*/; do
	TARGETDIR="${HOME}/Library/Application Support/iTerm2/$(basename "${SOURCEDIR}")"
	if [ ! -d "${TARGETDIR}" ]; then
		mkdir -p "${TARGETDIR}"
		for FILE in "${SOURCEDIR}"/*; do
			ln -sf "${FILE}" "${TARGETDIR}/$(basename "${FILE}")"
		done
	fi
done

scriptfooter "${BASH_SOURCE:-$_}"
