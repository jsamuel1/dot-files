#!/bin/zsh
# Cached completions loader — regenerates in background when binary changes.
# Files are placed in fpath so compinit lazy-loads them on first tab-complete.
#
# NOTE: git, gh, kubectl, kubectx, kubens already have completions via
# /opt/homebrew/share/zsh/site-functions/ — no need to generate those.

local _comp_cache_dir=~/.zsh/cache/completions
mkdir -p "$_comp_cache_dir"

typeset -A _comp_generators=(
  mise      "completion zsh"
  bun       "completions"
  uv        "generate-shell-completion zsh"
  rustup    "completions zsh"
)

for cmd gen in ${(kv)_comp_generators}; do
  (( $+commands[$cmd] )) || continue
  local _bin="${commands[$cmd]}"
  local _cache="$_comp_cache_dir/_${cmd}"
  if [[ ! -f "$_cache" || "$_bin" -nt "$_cache" ]]; then
    { $cmd ${=gen} >| "$_cache" 2>/dev/null } &|
  fi
done

# Add to fpath so compinit picks them up lazily
fpath=("$_comp_cache_dir" $fpath)
