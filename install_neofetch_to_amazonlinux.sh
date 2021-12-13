#!/usr/bin/env bash
set +e
echo fetchin neofetch
if ! [ -d neofetch ]; then
  git clone https://github.com/dylanaraps/neofetch
fi
cd neofetch
sudo make install
echo done.
