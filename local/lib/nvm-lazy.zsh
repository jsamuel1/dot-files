if [ -d $HOME/.nvm ]; then
  export NVM_DIR="$HOME/.nvm"

  lazy_load_nvm() {
    unset -f node
    unset -f npm
    unset -f nvm
    export NVM_DIR=~/.nvm
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  }

  nvm() {
    lazy_load_nvm
    nvm $@
  }

  node() {
    lazy_load_nvm
    node $@
  }
  npm() {
    lazy_load_nvm
    npm $@
  }
fi
