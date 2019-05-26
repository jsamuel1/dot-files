#!/bin/sh
# From chromebook only - ensure qt4 and gtk packages can install
# this script removes the conflicting files from the ChromeOS config package
apt download cros-ui-config # ignore any warning messages
ar x cros-ui-config_0.12_all.deb data.tar.gz
gunzip data.tar.gz
tar f data.tar --delete ./etc/gtk-3.0/settings.ini ./etc/xdg/Trolltech.conf
gzip data.tar
ar r cros-ui-config_0.12_all.deb data.tar.gz
rm -rf data.tar.gz
sudo apt install -y cros-guest-tools ./cros-ui-config_0.12_all.deb
sudo apt install -y adwaita-icon-theme-full
