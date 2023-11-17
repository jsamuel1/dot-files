#!/bin/bash

dnf install -y dnf-plugins-core
dnf config-manager --add-repo https://rtx.pub/rpm/rtx.repo

xargs -a <(awk '! /^ *(#|$)/' "dnfrequirements.txt") -r -- sudo dnf -y install

if [[ $GUI -eq 1 ]]; then
    echo ${bold}
    echo =================
    echo installing vscode
    echo =================
    echo ${normal}
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    if [ ! -f /etc/yum.repos.d/vscode.repo  ]; then
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        dnf check-update
    fi
    sudo dnf -y install code
fi

