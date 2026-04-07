#!/bin/sh
# update-zsh-plugins.sh — Clone/update p10k, fzf, and zsh-completions.
# Called from bootstrap.sh and the update alias.
# Plugins (sudo, magic-enter, zsh-interactive-cd) are vendored in dot-files/zsh/plugins/.

set -e

PLUGIN_DIR="$HOME/.zsh/plugins"
mkdir -p "$PLUGIN_DIR"

clone_or_pull() {
  local repo="$1" dir="$2"
  if [ -d "$dir/.git" ]; then
    echo "Updating $repo..."
    git -C "$dir" pull --quiet
  else
    echo "Cloning $repo..."
    git clone --depth 1 --quiet "https://github.com/$repo.git" "$dir"
  fi
}

clone_or_pull "romkatv/powerlevel10k" "$PLUGIN_DIR/powerlevel10k"
clone_or_pull "zsh-users/zsh-completions" "$HOME/.local/lib/zsh-completions"

clone_or_pull "junegunn/fzf" "$HOME/.fzf"
"$HOME/.fzf/install" --bin --completion --no-key-bindings --no-update-rc --no-bash --no-fish 2>/dev/null

echo "Zsh plugins updated."
