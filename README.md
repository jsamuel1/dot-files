run bootstrap.sh to setup common tools, required packages and symlink dotfiles.

###
- Zsh
- Git
- neovim
- rtx
- and more

### Mac
- Ensure logged into AppStore before running bootstrap.sh, otherwise xcode won't install correctly.
- Installs Brew, along with AppStore packages through Brew mas.
- Installs customized defaults
- Sets up yabi tiled window manager.

#### To change zsh to Homebrew version:
Execute from the zsh shell: 
```bash
sudo dscl . -create /Users/"$(whoami)" UserShell /usr/local/bin/zsh 
```

#### To setup iterm to nice default profile:
- Load iTerm2 
- Navigate to Settings -> Profiles -> Import JSON.   
- Import iterm-default.json from this repo.

### Windows Subsystem for Linux
- ensure upgraded to Disco or newer

- Outsite WSL:
* install scoop
* scoop bucket add anurse https://github.com/anurse/scoop-bucket
* scoop install win32yank     # clipboard support for neovim
