#!/usr/bin/env bash

source helpers.sh

#
# see https://github.com/rust-lang/rustup#other-installation-methods for options
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -y

# add rust to the path before proceeding
# shellcheck source=/dev/null
source ~/.cargo/env

rustup component add rust-src

if [ ! -d ~/src/rust-analyzer ]; then
  git clone https://github.com/rust-analyzer/rust-analyzer --depth 1 ~/src/rust-analyzer/
  echo running rust-analyzer installer
  ( cd ~/src/rust-analyzer && cargo xtask install )
else
  echo rust-analyzer already exists
fi

awk '! /^ *(#|$)/' "cargorequirements.txt"  | xargs -r -- cargo install
