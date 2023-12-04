#!/bin/env zsh 

bold=$(tput bold)
normal=$(tput sgr0)

#
if [ ! -d ~/.oh-my-zsh ]; then
  echo "${bold}"
  echo "============================"
  echo "installing Oh-My-Zsh"
  echo "============================"
  echo "${normal}"

  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
elif [ -d $ZSH/tools ]; then
  echo "${bold}"
  echo "============================"
  echo "updating Oh-My-Zsh"
  echo "============================"
  echo "${normal}"

  $ZSH/tools/upgrade.sh -vminimal
fi

if [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom} ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
  git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom} pull
fi

if [ ! -d ~/.local/lib/zsh-completions ]; then
  git clone https://github.com/zsh-users/zsh-completions.git ~/.local/lib/zsh-completions
else
  git -C ~/.local/lib/zsh-completions pull
fi

sudo chsh -s $(which zsh) "$USER" || true

echo "${bold}"
echo "============================"
echo "${normal}"
