#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

if ! clone_or_pull https://github.com/junegunn/fzf.git ~/.fzf shallow; then
  ~/.fzf/install --bin --completion --no-key-bindings --no-update-rc --no-bash --no-fish
fi
#
if [ ! -d ~/.oh-my-zsh ]; then
  subheading "installing Oh-My-Zsh"
  clone_or_pull https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh shallow
elif [ -d ~/.oh-my-zsh/tools ]; then
  subheading "updating Oh-My-Zsh"
  ~/.oh-my-zsh/tools/upgrade.sh -vminimal
fi

clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

clone_or_pull https://github.com/zsh-users/zsh-completions.git ~/.local/lib/zsh-completions

if ! is_mac && [[ "$(awk -F: -v u="${USER}" 'u==$1&&$0=$NF' /etc/passwd)" != "$(which zsh)" ]]; then
  sudo chsh -s "$(which zsh)" "$(whoami)" || true
elif is_mac && [[ "$(dscl . -read /Users/"$USER" UserShell | cut -d' ' -f2)" != "$(which zsh)" ]]; then
  sudo dscl . -create "/Users/${USER}" UserShell "$(which zsh)"
fi

scriptfooter "${BASH_SOURCE:-$_}"
