#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

MISEX=( mise x -- )
MISEUSE= (mise use -g -y )

heading "installing local tools with mise"

# first ensure config.toml is in place 
symlink_file "config/mise/config.toml" "${HOME}/.config/mise/config.toml" 
mise -q -y trust 1> /dev/null 2>&1
mise -y install
command -v mise >/dev/null && eval "$(mise activate bash)"
command -v mise >/dev/null && eval "$(mise hook-env)"

subheading "installing latest python for user"
symlink_file "dependencies/default-python-packages" "$HOME/.default-python-packages"
"${MISEUSE[@]}" python

"${MISEX[@]}" python3 -m pip install --upgrade pip | grep -v 'already satisfied'
"${MISEX[@]}" python3 -m pip install --upgrade -r "dependencies/requirements.txt" | grep -v 'already satisfied'

"${MISEUSE[@]}" poetry

subheading "ensure latest npm and modules"

symlink_file "dependencies/default-npm-packages" "$HOME/.default-npm-packages"

"${MISEUSE[@]}" node@lts
awkxargs "dependencies/default-npm-packages" "${MISEX[@]}" npm install -g

# symlink default go packages to ~/.default-go-package.  
# Mise will use this to install them on new version of go
# see: https://mise.jdx.dev/lang/go.html#default-packages
symlink_file "dependencies/default-go-packages" "$HOME/.default-go-packages"

"${MISEUSE[@]}" go@latest
subheading "ensure latest go modules"
awkxargs 1 "dependencies/default-go-packages" "${MISEX[@]}" go install -a

subheading "ensure neovim ruby gem installed"

# Note - requires zlib and sqlite Brew cellars on Macos
# workaround compile bug with ruby if those cellars are not yet present
[ -d /usr/local/opt/sqllite ] || sudo mkdir -p /usr/local/opt/sqllite
[ -d /usr/local/opt/zlib/lib ] || sudo mkdir -p /usr/local/opt/zlib/lib

# install latest stable version and use globbaly
symlink_file "dependencies/default-gems" "$HOME/.default-gems"

"${MISEUSE[@]}" ruby@latest
awkxargs "dependencies/default-gems" "${MISEX[@]}" gem install

"${MISEUSE[@]}" terraform@latest
"${MISEUSE[@]}" terraform-ls@latest
"${MISEUSE[@]}" tree-sitter@latest
"${MISEUSE[@]}" pre-commit@latest

scriptfooter "${BASH_SOURCE:-$_}"
