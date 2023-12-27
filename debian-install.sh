#!/usr/bin/env bash

# setup extra tools for AmazonLinux 2023
# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

is_like_debian || exit

source ./install_neovim_from_source.sh

scriptfooter "${BASH_SOURCE:-$_}"