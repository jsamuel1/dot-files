#!/usr/bin/env bash

# setup extra tools for AmazonLinux 2023
# shellcheck source=./helpers.sh
source ./helpers.sh

is_amazonlinux2 || is_amazonlinux2023 || exit

source ./install_neovim_to_amazonlinux.sh
source ./install_neofetch_to_amazonlinux.sh
source ./install_autojump_to_amazonlinux.sh
