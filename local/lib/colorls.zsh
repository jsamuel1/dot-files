alias lc='colorls -lA --sd'
alias lct='colorls --tree'
alias lcg='colorls --gs --tree'

alias cls='colorls -lA --sd'
alias clst='colorls --tree'
alias clsg='colorls --gs --tree'

zsh-defer source $(dirname $(gem which colorls))/tab_complete.sh
