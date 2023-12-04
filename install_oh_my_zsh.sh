#!/bin/bash

# shellcheck source=helpers.sh
source helpers.sh

heading "Setup zsh environment"

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --bin --completion --no-key-bindings --no-update-rc --no-bash --no-fish
else
  git -C ~/.fzf pull
  ~/.fzf/install --bin --completion --no-key-bindings --no-update-rc --no-bash --no-fish
fi

#
if [ ! -d ~/.oh-my-zsh ]; then
  subheading "installing Oh-My-Zsh"
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
elif [ -d "$ZSH/tools" ]; then
  subheading "updating Oh-My-Zsh"
  "$ZSH/tools/upgrade.sh" -vminimal
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
else
  git -C "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}" pull
fi

if [ ! -d ~/.local/lib/zsh-completions ]; then
  git clone https://github.com/zsh-users/zsh-completions.git ~/.local/lib/zsh-completions
else
  git -C ~/.local/lib/zsh-completions pull
fi

sudo chsh -s "$(which zsh)" "$USER" || true

heading ""
