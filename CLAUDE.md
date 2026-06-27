# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal dotfiles repo that bootstraps a development machine (macOS, Amazon Linux 2023, Debian/Ubuntu including WSL, and ChromeOS Linux) and symlinks config files into `$HOME`. There is no compiled artifact and no test suite — "running" the repo means executing the bootstrap scripts, which mutate the local machine (install packages, change the login shell, write to `$HOME`).

## Common commands

```sh
./bootstrap.sh            # full setup: git pull, install packages, symlink dotfiles
UPDATE=0 ./bootstrap.sh   # skip the self-update/re-exec; run against the working tree as-is
./settings.py --dryrun    # preview which dotfile symlinks would change (no writes)
./settings.py --no-dryrun # apply symlinks only (what bootstrap.sh calls)
./test-shell-startup.sh   # measure zsh startup time across login/interactive/probe modes
```

When iterating on the scripts themselves, always use `UPDATE=0` so bootstrap doesn't `git pull` and re-exec, discarding your uncommitted changes.

Shell scripts are linted with shellcheck (`.shellcheckrc` enables `external-sources`/`check-sources`, so it follows `source` directives). Lint before committing:

```sh
shellcheck bootstrap.sh helpers.sh macos.sh   # etc.
```

## Architecture

### Bootstrap flow (`bootstrap.sh`)

`bootstrap.sh` is the single entry point and is designed to be `curl | sh`-able. It:
1. Self-locates: if not already in a git checkout, clones the repo to `~/src/dot-files` and re-execs from there.
2. Self-updates: `git pull` then re-execs with `UPDATE=0` (unless `UPDATE=0` is already set).
3. Sources `helpers.sh`, detects the OS, and dispatches to the right package installer.
4. Installs tools, then runs `settings.py` to symlink dotfiles, then sets up git config and the zsh shell.

OS detection lives in `helpers.sh` (`is_mac`, `is_wsl`, `is_amazonlinux2023`, `is_like_debian`). The bootstrap branches on these to source the matching installer:
- macOS → `macos.sh` (Homebrew + `dependencies/Brewfile`, `macdefaults.sh`, iTerm2)
- Amazon Linux 2023 / dnf → `dnf-install.sh` (`dependencies/dnfrequirements.txt`)
- Debian/Ubuntu/ChromeOS / apt → `apt-install.sh` (`dependencies/aptrequirements.txt`)

### `helpers.sh` — the shared library

Sourced (never executed — it guards against direct execution) by every other script. Provides OS detection, `heading`/`subheading` pretty-printing, `clone_or_pull`, and the symlink primitives `symlink_file` / `symlink_all` / `cleanup_broken_symlinks`. Note the deliberate comment in the symlink helpers: targets are **not** `realpath`'d, because resolving an already-correct symlink would make `ln -sfn` self-loop.

### Symlinking (`settings.py`)

`settings.py` is the dotfile linker (run by bootstrap, but usable standalone for dry-runs). It maps repo directories to `$HOME` by prefixing each file with `.`:
- `dots/*` (one level only) → `~/.*` (e.g. `dots/zshrc` → `~/.zshrc`)
- `config/**/*` → `~/.config/**/*`
- `local/**/*` → `~/.local/**/*`
- `zsh/**/*` → `~/.zsh/**/*`

To add a new dotfile, place it in the directory matching its `$HOME` destination — do not edit `settings.py`. After bootstrap, `cleanup_broken_symlinks` (in `helpers.sh`) prunes dangling links in `$HOME` and common subdirs.

### Tool installation via mise

`mise-tools-install.sh` installs language runtimes and tools through [mise](https://mise.jdx.dev/) (config symlinked from `config/mise/config.toml`). Per-language default packages are declared in `dependencies/` and symlinked to the dotfiles mise expects (`~/.default-npm-packages`, `~/.default-gems`, `~/.default-go-packages`, `~/.default-python-packages`) so mise reinstalls them on every runtime upgrade. `rust-install.sh` runs after, since Rust tooling depends on node/ruby being present.

### Dependency manifests (`dependencies/`)

Plain-text package lists, one per ecosystem (`Brewfile`, `aptrequirements.txt`, `dnfrequirements.txt`, `cargorequirements.txt`, `default-*` runtime packages, `vscodeextensions.txt`). The installers read these with an awk filter that skips blank lines and `#` comments (`awkxargs` in `helpers.sh`). Add/remove packages here, not inline in the scripts.

### Shell configuration (`dots/zsh*`, `zsh/`)

Zsh is the primary shell. `dots/zshrc` is the main rc; it sources `~/.zshrc-helpers` and `~/.zshrc-optimize` (also from `dots/`). Key behaviors to preserve when editing:
- **Env-probe fast path**: `zshrc` returns early when neither stdin nor stdout is a tty (GUI apps like VS Code / Kiro / QuickWork probe the login shell with a short timeout — a slow rc breaks them). `test-shell-startup.sh` exists to verify this stays fast.
- `_ZSH_PROFILE=1` enables `zprof`; `_ZSH_TRACE=1` prints per-section startup timings.
- The prompt is [starship](https://starship.rs/) (`config/starship.toml`), installed via Brewfile/mise — **not** a cloned plugin. Powerlevel10k was removed; `update-zsh-plugins.sh` actively deletes any leftover p10k clone.
- Plugins in `zsh/plugins/` are **vendored** (committed in-repo). Only fzf and zsh-completions are cloned at install time by `local/bin/update-zsh-plugins.sh`.

### Git configuration

`~/.gitconfig` is a machine-local real file (a stub created by bootstrap), so `git config --global` writes stay on the machine. It `[include]`s `~/.gitconfig-shared` (symlinked from `dots/gitconfig-shared`) for shared settings. An optional `~/.gitconfig-src` applies overrides only to repos under `~/src/`. `dots/gitconfig` is gitignored (machine-local). When editing shared git settings, edit `dots/gitconfig-shared`. Per the README, set `git config --global user.email` once on a new machine.

## Conventions

- Scripts meant to be sourced (like `helpers.sh`) guard against direct execution — keep that guard if you add more.
- Long-output operations and `sudo` keep-alive are handled in `helpers.sh` (`sudo_alive`); reuse it rather than re-prompting.
- Conventional-commit style is used in history (`feat(...)`, `fix(...)`, `chore(deps): ...`).
