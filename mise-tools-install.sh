#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

MISEX=( mise x -- )

heading "installing local tools with mise"

# first ensure config.toml is in place 
ln -sf "$(pwd)/config/mise/config.toml" "${HOME}/.config/mise/config.toml" 
mise -q -y trust 1> /dev/null 2>&1
mise -y install
command -v mise >/dev/null && eval "$(mise activate bash)"
command -v mise >/dev/null && eval "$(mise hook-env)"

subheading "installing latest python for user"
mise use -g python

subsubheading "installing base python3 packages"
"${MISEX[@]}" python3 -m pip install --upgrade pip | grep -v 'already satisfied'
"${MISEX[@]}" python3 -m pip install --upgrade -r "dependencies/requirements.txt" | grep -v 'already satisfied'

subheading "ensure latest npm and modules"

mise use -g nodejs@lts
awkxargs "dependencies/npmrequirements.txt" "${MISEX[@]}" npm install -g

mise use -g go@latest
subheading "ensure latest go modules"
awkxargs 1 "dependencies/gorequirements.txt" "${MISEX[@]}" go install -a

subheading "ensure neovim ruby gem installed"

# Note - requires zlib and sqlite Brew cellars on Macos
# workaround compile bug with ruby if those cellars are not yet present
[ -d /usr/local/opt/sqllite ] || sudo mkdir -p /usr/local/opt/sqllite
[ -d /usr/local/opt/zlib/lib ] || sudo mkdir -p /usr/local/opt/zlib/lib

# install latest stable version and use globbaly
mise use -g ruby@latest
awkxargs "dependencies/gemrequirements.txt" "${MISEX[@]}" gem install

scriptfooter "${BASH_SOURCE:-$_}"
