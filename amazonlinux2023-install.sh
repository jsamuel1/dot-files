#!/usr/bin/env bash

# setup extra tools for AmazonLinux 2023
# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

is_amazonlinux2 || is_amazonlinux2023 || exit

source ./install_neovim_from_source.sh
source ./install_neofetch_to_amazonlinux.sh
source ./install_autojump_to_amazonlinux.sh

scriptfooter "${BASH_SOURCE:-$_}"
