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

heading "installing latest python for user"
rtx use -g python

subheading "installing base python3 packages"
"${RTXX[@]}" python3 -m pip install --upgrade pip | grep -v 'already satisfied'
"${RTXX[@]}" python3 -m pip install --upgrade -r requirements.txt | grep -v 'already satisfied'

heading "ensure latest npm and modules"
# rtx env-vars npm_config_progress=false
# rtx env-vars npm_config_update_notifier=false
# rtx env-vars npm_config_update_all=true
# rtx env-vars npm_config_loglevel=warn
# rtx env-vars npm_config_unsafe_perm=true

rtx use -g nodejs@lts
awkxargs "npmrequirements.txt" "${RTXX[@]}" npm install -g

rtx use -g go@latest
heading "ensure latest go modules"
awkxargs 1 "gorequirements.txt" "${RTXX[@]}" go install -a

subheading "ensure neovim ruby gem installed"

# workaround compile bug with ruby
sudo mkdir -p /usr/local/opt/sqllite
sudo mkdir -p /usr/local/opt/zlib/lib

# install latest stable version and use globbaly
rtx use -g ruby@latest
awkxargs "gemrequirements.txt" "${RTXX[@]}" gem install


scriptfooter "${BASH_SOURCE:-$_}"
