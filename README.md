# dot-files

Run bootstrap.sh to setup common tools, required packages and symlink dot-files to your home directory.
This script is designed to run on Mac OSX, Linux (Amazon Linux 2/2023, Debian, Ubuntu) and Windows (WSL and Powershell setup)

The scripts will install operating system packages, along with [neovim](https://github.com/neovim/neovim), [oh-my-zsh](https://ohmyz.sh/), [rtx](https://github.com/jdx/rtx) and default languages via rtx.

## Installation

Run from internet:

git and curl must be installed.

```sh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/jsamuel1/dot-files/master/bootstrap.sh)"
```

Run from local:

```sh
    ./bootstrap.sh
```

To update and run from local:

```sh
    UPDATE=1 ./bootstrap.sh
```

## Mac

- AppStore must be logged in before running `bootstrap.sh`, otherwise xcode won't install correctly
- Installs [Homebrew](https://brew.sh/), along with AppStore packages via `brew mas`.  
*BrewFile* defines the packages to install.
- Installs default settings for macos, defined in *macdefaults.sh*
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
