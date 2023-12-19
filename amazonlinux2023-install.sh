#!/usr/bin/env bash

# setup extra tools for AmazonLinux 2023
# shellcheck source=helpers.sh
source helpers.sh

is_amazonlinux2 || is_amazonlinux2023 || exit

. install_neovim_to_amazonlinux.sh
. install_neofetch_to_amazonlinux.sh
. install_autojump_to_amazonlinux.sh
