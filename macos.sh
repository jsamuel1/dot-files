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

# Default shell is set to zsh by bootstrap.sh (dscl, works on Intel and Apple Silicon)

if [ ! -d "/Applications/Google Chrome.app" ]; then
	subheading "Installing Google Chrome"
	temp=$TMPDIR$(uuidgen)
	curl https://dl.google.com/chrome/mac/stable/accept_tos%3Dhttps%253A%252F%252Fwww.google.com%252Fintl%252Fen_ph%252Fchrome%252Fterms%252F%26_and_accept_tos%3Dhttps%253A%252F%252Fpolicies.google.com%252Fterms/googlechrome.pkg >"$temp/googlechrome.pkg"
	sudo installer -pkg "$temp/googlechrome.pkg" -target /
	rm -r "$temp"
fi

# Chrome extensions (my own). Failures warn and continue -- never abort macos.sh.
CHROME_APP="/Applications/Google Chrome.app"
COPYURL_EXTENSION_ID="gnikeakejfmpheocchndnmdkgcbflcdo" # Copy Page URL (Chrome Web Store)
TABSAGE_REPO="jsamuel1/chrome-tab-decider"              # TabSage (unpublished, GitHub release "latest")
TABSAGE_DIR="${HOME}/.local/share/chrome-extensions/tabsage"

# Download the TabSage zip from the "latest" GitHub release into $1 (a scratch dir)
# and stage it at ${TABSAGE_DIR}.new with manifest.json at its root.
function _fetch_tabsage {
	local scratch="${1}" url="" manifest
	if command -v gh >/dev/null; then
		url="$(gh api "repos/${TABSAGE_REPO}/releases/tags/latest" \
			--jq '[.assets[] | select(.name | test("^tabsage-.*\\.zip$"))][0].browser_download_url // empty' 2>/dev/null)"
	fi
	if [ -z "${url}" ]; then
		url="$(curl -fsSL "https://api.github.com/repos/${TABSAGE_REPO}/releases/tags/latest" |
			python3 -c 'import json, re, sys
for a in json.load(sys.stdin).get("assets", []):
    if re.match(r"tabsage-.*\.zip$", a["name"]):
        print(a["browser_download_url"])
        break' 2>/dev/null)"
	fi
	[ -n "${url}" ] || { echo "WARNING: could not resolve a tabsage-*.zip asset from ${TABSAGE_REPO} release 'latest'"; return 1; }

	echo "Downloading ${url}"
	curl -fsSL -o "${scratch}/tabsage.zip" "${url}" || return 1
	unzip -q "${scratch}/tabsage.zip" -d "${scratch}/extract" || return 1

	# manifest.json may be at the zip root or inside a single top-level folder
	manifest="${scratch}/extract/manifest.json"
	[ -f "${manifest}" ] || manifest="$(find "${scratch}/extract" -mindepth 2 -maxdepth 2 -name manifest.json -print -quit)"
	[ -n "${manifest}" ] || { echo "WARNING: manifest.json not found in ${url}"; return 1; }

	mkdir -p "$(dirname "${TABSAGE_DIR}")" || return 1
	rm -rf "${TABSAGE_DIR}.new"
	mv "$(dirname "${manifest}")" "${TABSAGE_DIR}.new"
}

# Swap a freshly downloaded TabSage into ${TABSAGE_DIR}; a failed download leaves the old copy intact.
function install_tabsage {
	local scratch
	scratch="$(mktemp -d)" || return 1
	if _fetch_tabsage "${scratch}"; then
		rm -rf "${TABSAGE_DIR}.old"
		[ -d "${TABSAGE_DIR}" ] && mv "${TABSAGE_DIR}" "${TABSAGE_DIR}.old"
		mv "${TABSAGE_DIR}.new" "${TABSAGE_DIR}" && rm -rf "${TABSAGE_DIR}.old"
	else
		echo "WARNING: TabSage download failed; keeping existing copy (if any) at ${TABSAGE_DIR}"
		rm -rf "${TABSAGE_DIR}.new"
	fi
	rm -rf "${scratch}"
}

if [ -d "${CHROME_APP}" ]; then
	subheading "Chrome extensions"

	# Copy Page URL: per-user external extension file pointing at the Web Store.
	# Chrome installs it on next launch and asks once to enable it. If it's later
	# uninstalled manually, Chrome won't reinstall it from this file.
	# ref: https://developer.chrome.com/docs/extensions/how-to/distribute/install-extensions
	CHROME_EXTERNAL_DIR="${HOME}/Library/Application Support/Google/Chrome/External Extensions"
	if mkdir -p "${CHROME_EXTERNAL_DIR}" &&
		printf '%s\n' '{"external_update_url": "https://clients2.google.com/service/update2/crx"}' \
			>"${CHROME_EXTERNAL_DIR}/${COPYURL_EXTENSION_ID}.json"; then
		echo "Copy Page URL: ${CHROME_EXTERNAL_DIR}/${COPYURL_EXTENSION_ID}.json"
	else
		echo "WARNING: could not write Copy Page URL external extension file"
	fi

	# TabSage: unpublished, so it must be loaded unpacked by hand once. This can't be
	# automated: branded Chrome removed --load-extension in Chrome 137, and on macOS
	# external extension files must point at the Web Store.
	install_tabsage
	if [ -f "${TABSAGE_DIR}/manifest.json" ]; then
		echo "TabSage: first time only, chrome://extensions -> Developer mode -> Load unpacked -> ${TABSAGE_DIR}"
		echo "         Re-running bootstrap updates the files; Chrome loads the new version on restart."
	fi
fi

subheading "iTerm2 config files"

# Redirect iTerm2 to use the plist in our dot-files project
if [ -f "${PWD}/iTerm2/com.googlecode.iterm2.plist" ]; then
	# Specify the preferences directory
	defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "${PWD}/iTerm2"
	# Tell iTerm2 to use the custom preferences in the directory
	defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
fi

SOURCEPATH="${PWD}/iTerm2"
TARGETPATH="${HOME}/Library/Application Support/iTerm2"
symlink_all "${SOURCEPATH}" "${TARGETPATH}" --exclude \*.plist

cleanup_broken_symlinks "${TARGETPATH}"

subheading "LaunchAgents"
mkdir -p "${HOME}/Library/LaunchAgents"
for plist in "${PWD}"/LaunchAgents/*.plist; do
	target="${HOME}/Library/LaunchAgents/$(basename "$plist")"
	if [[ -L "$target" && "$(realpath "$target")" == "$(realpath "$plist")" ]]; then
		continue
	fi
	symlink_file "$plist" "$target"
	launchctl unload "$target" 2>/dev/null || true
	launchctl load "$target"
done

# Amazon Only install - won't work elsewhere.
# authenticate with mwinit first
# One-time only install
if command -v /usr/local/amazon/bin/acme_amazon_enterprise_access >/dev/null; then
	if [ ! -x /usr/local/sbin/homebrew-amazon-credential.sh ]; then
		subheading "Installing Amazon tap"
		# Install the Amazon tap (one time setup)
		python3 -c "$(curl -fsS https://m.media-amazon.com/images/G/01/homebrew/bootstrap.py)"
		brew install amzn/amzn/env-improvement
		brew install amzn/amzn/isengard-cli
		brew install amzn/amzn/brazil-recursive-cmd-parallel
	fi
fi

scriptfooter "${BASH_SOURCE:-$_}"
