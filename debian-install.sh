#!/usr/bin/env bash

# setup extra tools for AmazonLinux 2023
# shellcheck source=./helpers.sh
source ./helpers.sh

is_like_debian || exit

source ./install_neovim_from_source.sh
