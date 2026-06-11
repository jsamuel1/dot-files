#!/usr/bin/env bash

# setup extra tools for From source
# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

subsubheading "installing tools from source"

if is_like_debian || is_amazonlinux2023 || is_amazonlinux2; then
  source ./install_neovim_from_source.sh
fi

scriptfooter "${BASH_SOURCE:-$_}"
