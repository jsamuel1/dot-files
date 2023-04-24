#!/bin/bash -x

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
ACCEPT_EULA=y brew bundle -v

if ! type it2check > /dev/null ; then
    curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
fi

./macdefaults.sh

if [ ! -d "/Applications/Google Chrome.app" ]; then
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

