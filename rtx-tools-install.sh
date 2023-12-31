#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

RTXX=( rtx x -- )

heading "installing local tools with rtx"

# first ensure config.toml is in place 
ln -sf "$(pwd)/config/rtx/config.toml" "${HOME}/.config/rtx/config.toml" 
rtx -q -y trust 1> /dev/null 2>&1
rtx -y install
command -v rtx >/dev/null && eval "$(rtx activate bash)"
command -v rtx >/dev/null && eval "$(rtx hook-env)"

subheading "installing latest python for user"
rtx use -g python

subsubheading "installing base python3 packages"
"${RTXX[@]}" python3 -m pip install --upgrade pip | grep -v 'already satisfied'
"${RTXX[@]}" python3 -m pip install --upgrade -r "dependencies/requirements.txt" | grep -v 'already satisfied'

subheading "ensure latest npm and modules"

rtx use -g nodejs@lts
awkxargs "dependencies/npmrequirements.txt" "${RTXX[@]}" npm install -g

rtx use -g go@latest
subheading "ensure latest go modules"
awkxargs 1 "dependencies/gorequirements.txt" "${RTXX[@]}" go install -a

subheading "ensure neovim ruby gem installed"

# Note - requires zlib and sqlite Brew cellars on Macos
# workaround compile bug with ruby if those cellars are not yet present
[ -d /usr/local/opt/sqllite ] || sudo mkdir -p /usr/local/opt/sqllite
[ -d /usr/local/opt/zlib/lib ] || sudo mkdir -p /usr/local/opt/zlib/lib

# install latest stable version and use globbaly
rtx use -g ruby@latest
awkxargs "dependencies/gemrequirements.txt" "${RTXX[@]}" gem install

scriptfooter "${BASH_SOURCE:-$_}"
