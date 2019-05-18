# dot-files
sudo apt install make npm build-essentials libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev fonts-powerline gdebi fortune
default-jdk neovim

make install

### Shells
- Bash
- Zsh

### Version Control
- Git

### Hyper Terminal
- install latest .deb from github
https://github.com/zeit/hyper/releases
- install gitrocket
$ cd ~/.config/Hyper/.hyper_plugins
$ npm install gitrocket

### Editors
- neovim
-- then update-alternatives to make default
sudo update-alternatives --config vim
##Install manually:
### pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv

####Setup neovim virtualenv
See https://github.com/deoplete-plugins/deoplete-jedi/wiki/Setting-up-Python-for-Neovim
- pyenv virtualenv neovim3
ensure neovim init.vim installed

### zsh
### oh-my-zsh
* install oh-my-zsh
* install nerd-fonts
- git clone https://github.com/ryanoasis/nerd-fonts.git --depth 1
- cd nerd-fonts
- install.sh

#### zsh-autocompletion
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#### zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
### okta aws cli pluggin
### gists from github to .local/bin:
https://gist.github.com/jsamuel1/b6bb952552ae23d81d6a3895a6aba456


