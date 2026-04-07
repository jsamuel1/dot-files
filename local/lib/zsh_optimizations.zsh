#!/bin/zsh
#
# ZSH Optimizations - Custom aliases and functions to improve workflow
# Created: 2025-04-23

# Directory jumping with z (if installed)
if [ -f /opt/homebrew/etc/profile.d/z.sh ]; then
  source /opt/homebrew/etc/profile.d/z.sh
fi

# Modern ls replacement with exa (if installed)
if (( $+commands[eza] )); then
  alias ll='eza -la'
  alias lt='eza -T'  # Tree view
  alias lg='eza -la --git'  # Show git status
fi

# Utility functions
mkcd() {
  mkdir -p "$1" && cd "$1" || return
}

# Extract various archive formats
extract() {
  if [ -f "$1" ]; then
    case $1 in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Smart tip system - loads tips from ~/.local/share/zsh_tips.json
show_smart_tip() {
  local tips_file="$HOME/.local/share/zsh_tips.json"
  if [ -f "$tips_file" ]; then
    # Get a weighted random tip based on usage statistics
    if command -v jq &>/dev/null; then
      local tip_count
      tip_count=$(jq '. | length' "$tips_file")
      if [ "$tip_count" -gt 0 ]; then
        local random_index=$((RANDOM % tip_count))
        jq -r ".[$random_index].tip" "$tips_file"
      fi
    else
      echo "Install jq for smart tips: brew install jq"
    fi
  else
    echo "Tip: Run 'analyze_zsh_history' to generate personalized command tips"
  fi
}

# Show a tip when this file is sourced
# show_smart_tip
# call this from .zshrc 
