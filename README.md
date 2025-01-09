# dot-files

Run bootstrap.sh to setup the common tools and packages and then
symlink dot-files to your home directory.
This script has worked at various points in time on my machine, running one of:

- Mac OS
- Linux (Amazon Linux 2/2023, Debian, Ubuntu)
- Windows (WSL and Powershell setup)

The scripts will install operating system packages, along with:

- [neovim](https://github.com/neovim/neovim)
- [oh-my-zsh](https://ohmyz.sh/)
- [mise](https://github.com/jdx/mise) and default languages via mise.

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
- Sets up **magnet** tiled window manager.
- Will change the Mac default shell to the Homebrew zsh version at /usr/local/bin/zsh

### Setup iTerm default profile

- Load iTerm2
- Navigate to Settings -> Profiles -> Import JSON
- Import iterm-default.json from this repo.

## Windows

### Windows Subsystem for Linux

- Outside WSL
- install scoop, then:

```PowerShell
scoop bucket add anurse "https://github.com/anurse/scoop-bucket"
scoop install win32yank # clipboard support for neovim
```
