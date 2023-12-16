#!/bin/bash

# shellcheck source=helpers.sh
source helpers.sh

heading "Setup zsh environment"

if [ ! -d $HOME/.fzf ]; then
	git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
	$HOME/.fzf/install --bin --completion --no-key-bindings --no-update-rc --no-bash --no-fish
else
	git -C $HOME/.fzf pull
	$HOME/.fzf/install --bin --completion --no-key-bindings --no-update-rc --no-bash --no-fish
fi

#
if [ ! -d $HOME/.oh-my-zsh ]; then
	subheading "installing Oh-My-Zsh"
	git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh
elif [ -d "$ZSH/tools" ]; then
	subheading "updating Oh-My-Zsh"
	"$ZSH/tools/upgrade.sh" -vminimal
fi

if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" ]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
else
	git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" pull
fi

if [ ! -d $HOME/.local/lib/zsh-completions ]; then
	git clone https://github.com/zsh-users/zsh-completions.git $HOME/.local/lib/zsh-completions
else
	git -C $HOME/.local/lib/zsh-completions pull
fi

sudo chsh -s "$(which zsh)" "$USER" || true

heading ""
