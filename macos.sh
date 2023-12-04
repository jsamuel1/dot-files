#!/bin/bash

if ! type brew >/dev/null; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi
brew doctor
if ! type mas >/dev/null; then
	brew install mas
fi
mas install 497799835 #xcode

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
ACCEPT_EULA=y brew bundle

if [ ! -f "$HOME/.iterm2_shell_integration.zsh" ]; then
	curl -L https://iterm2.com/shell_integration/zsh \
		-o ~/.iterm2_shell_integration.zsh
fi

./macdefaults.sh

if [ ! -d "/Applications/Google Chrome.app" ]; then
	temp=$TMPDIR$(uuidgen)
	mkdir -p "$temp/mount"
	curl https://dl.google.com/chrome/mac/beta/googlechrome.dmg >"$temp/1.dmg"
	yes | hdiutil attach -noverify -nobrowse -mountpoint "$temp/mount" "$temp/1.dmg"
	cp -r "$temp/mount/*.app" /Applications
	hdiutil detach "$temp/mount"
	rm -r "$temp"
fi
