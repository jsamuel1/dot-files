# dot-files

Run bootstrap.sh to setup the common tools and packages and then
symlink dot-files to your home directory.
This script has worked at various points in time on my machine, running one of:

- Mac OS
- Linux (Amazon Linux 2023, Debian, Ubuntu — including WSL)

The scripts will install operating system packages, along with:

- [neovim](https://github.com/neovim/neovim)
- zsh with [Powerlevel10k](https://github.com/romkatv/powerlevel10k) and vendored plugins
- [mise](https://github.com/jdx/mise) and default languages/tools via mise
  (node, python, ruby, go, terraform, bun, fastfetch, ...)

## Git configuration

`~/.gitconfig` is a machine-local file (created by `bootstrap.sh`) holding
per-machine settings like `user.email` — `git config --global` writes there.
Shared settings live in `~/.gitconfig-shared`, symlinked from
`dots/gitconfig-shared` in this repo.

On a new machine, set your email once:

```sh
git config --global user.email you@example.com
```

If a `~/.gitconfig-src` file exists, it is applied as overrides for repos
under `~/src/` only (and silently skipped when absent).

## Installation

Run from internet:

git and curl must be installed.

```sh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/jsamuel1/dot-files/main/bootstrap.sh)"
```

Run from local:

```sh
    UPDATE=0 ./bootstrap.sh
```

To update and run from local:

```sh
    ./bootstrap.sh
```

## Mac

- AppStore must be logged in before running `bootstrap.sh`
- xcode must be installable
- Installs [Homebrew](https://brew.sh/), along with AppStore packages via brew  
  _BrewFile_ defines the packages to install.
- Installs default settings for macos, defined in _macdefaults.sh_
- Installs **rectangle** for window tiling.
- Changes the default login shell to zsh

### Setup iTerm default profile

iTerm2 preferences are loaded automatically from the `iTerm2/` folder in this
repo (configured by `macos.sh` via `PrefsCustomFolder`).
