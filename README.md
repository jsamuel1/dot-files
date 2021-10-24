run bootstrap.sh to setup common tools, required packages and symlink dotfiles.

###
- Zsh
- Git
- neovim
- pyenv
- and more

### Mac
- Ensure logged into AppStore before running bootstrap.sh, otherwise xcode won't install correctly.
- Installs Brew, along with AppStore packages through Brew mas.
- Installs customized defaults
- Sets up yabi tiled window manager.

    To change zsh to Homebrew version:
    sudo dscl . -create /Users/$USER UserShell /usr/local/bin/zsh

### Windows Subsystem for Linux
- ensure upgraded to Disco or newer

- Outsite WSL:
* install scoop
* scoop bucket add anurse https://github.com/anurse/scoop-bucket
* scoop install win32yank     # clipboard support for neovim
