#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

if ! command -v rustup >/dev/null; then  
  # see https://github.com/rust-lang/rustup#other-installation-methods for options
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path -q -y
fi
# add rust to the path before proceeding
# shellcheck source=/dev/null
source ~/.cargo/env

# remove any existing rust-analyzer installed via Cargo instead of rustup
if [ -x "${HOME}/.cargo/bin/rust-analyzer" ]; then
  rm -f "${HOME}/.cargo/bin/rust-analyzer"
fi

rustup -q update
rustup -q component add rust-src
rustup -q component add rust-analyzer
rustup -q component add rustfmt
rustup -q component add clippy

# re-source the environment
source "$HOME/.cargo/env"

awkxargs "cargorequirements.txt" cargo -q install

scriptfooter "${BASH_SOURCE:-$_}"
