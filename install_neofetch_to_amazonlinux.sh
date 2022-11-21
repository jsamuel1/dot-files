#!/usr/bin/env bash
(
  cd "$(mktemp -d)"
  git clone https://github.com/dylanaraps/neofetch
  cd neofetch
  sudo make install
)

