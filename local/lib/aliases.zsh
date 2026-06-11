#!/bin/zsh
#
# to be sourced from zshrc or bashrc
alias grep="$(command -v ggrep >/dev/null 2>&1 && echo ggrep || echo grep)"' --exclude="*.pyc" --exclude="*.swp" --exclude="*.tfstate.backup" --color=auto --exclude-dir=.terraform --exclude-dir=.git'
alias pip='python -m pip' # always use current pipenv's python for pip
alias please='sudo'
alias vi='nvim'  # some things just like vi
alias vim='nvim' # nvim nvim nvim.  for when the system override is wrong :)

# Use bun for npm/npx in interactive shells only.
# Scripts and build tools still resolve the real npm/npx via mise shims.
if (( $+commands[bun] )); then
        alias npx='bunx'
        alias npm='bun'
fi

# Use (( $+commands[x] )) instead of command -v to avoid forking
if (( $+commands[bat] )); then
        alias cat='bat --style=plain -P --strip-ansi=always'
elif (( $+commands[pygmentize] )); then
        alias cat="pygmentize -g -O style=monokai"
fi

# Detect which `ls` flavor is in use
if ls --color -d / >/dev/null 2>&1; then # GNU `ls`
        colorflag="--color"
        export LS_COLORS='no=00:fi=00:di=01;31:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
else # macOS `ls`
        colorflag="-FG"
        export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
fi

# eza configuration for dark terminal theme
if (( $+commands[eza] )); then
        # Set eza colors for dark terminal theme
        export EZA_COLORS="di=1;36:ln=35;3:pi=33:so=1;35:bd=1;33:cd=1;33:ex=1;32:mp=36;4:sp=1;34:or=1;31;4:uu=37;2:ur=32;2:uw=32;2:ux=32;2:ue=32;2:gr=33;2:gw=33;2:gx=33;2:tr=31;2:tw=31;2:tx=31;2:su=1;35:sf=35:xa=36:sn=32:sb=32:df=31:ds=31:uu=37;2:un=37:uR=1;31:gu=37:gn=37:gR=31:lc=36:lm=1;36:ga=1;32:gm=1;33:gd=1;31:gv=1;34:gt=1;36:gi=37;2:gc=1;31;4:Gm=1;32:Go=1;36:Gc=32:Gd=1;33:xx=37;2:da=37;2:in=37;2:bl=37;2:hd=1;37:lp=36:cc=1;31:bO=31;4:mp=36;4:im=1;35:vi=1;35;4:mu=1;34:lo=34:cr=1;32:do=33:co=31:tm=37;2:cm=33;2:bu=33;4:sc=1;33:ic=33:Sn=37:Su=32:Sr=33:St=34:Sl=35:ff=33"
        
        # Replace ls with eza
        alias ls='eza --git --icons=auto --all -lh -s newest'
else
        # Always use color output for `ls`
        alias ls="command ls ${colorflag}"
fi

if [[ "$OSTYPE" =~ darwin* ]]; then
        # Empty the Trash on all mounted volumes and the main HDD.
        # Also, clear Apple's System Logs to improve shell startup speed.
        # Finally, clear download history from quarantine. https://mths.be/bum
        alias emptytrash="( sudo rm -rfv /Volumes/*/.Trashes ) ; ( sudo rm -rfv ~/.Trash ) ; ( sudo rm -rfv /private/var/log/asl/*.asl ) ; ( sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent' )"

        # Get macOS Software Updates, and update installed Ruby gems, Homebrew, mise tools, and their installed packages
        alias update='sudo softwareupdate -i -a; sudo gem update --system; sudo gem cleanup; brew update; HOMEBREW_ACCEPT_EULA=Y brew upgrade; brew cleanup; mise up -y; gem update; uv tool upgrade --all; uv cache prune || true; mise prune || true; update-zsh-plugins.sh'

        # List and update bunx cached packages
        alias bunx-list='ls ~/.bun/install/cache/ 2>/dev/null | head -20'

        if (( $+commands[finch] )); then
                alias docker=finch
                export CDK_DOCKER=finch
        fi
fi

if ! [[ "$OSTYPE" =~ darwin* ]]; then
        # Debian/Ubuntu package fd as fdfind; only alias when the real fd is absent
        # (cargo/mise installs provide a real `fd` binary)
        if ! (( $+commands[fd] )) && (( $+commands[fdfind] )); then
                alias fd='fdfind'
        fi

        # Linux equivalent of the macOS `update` alias
        if (( $+commands[apt-get] )); then
                alias update='sudo apt-get update && sudo apt-get -y upgrade; mise up -y; uv tool upgrade --all || true; mise prune || true; update-zsh-plugins.sh'
        elif (( $+commands[dnf] )); then
                alias update='sudo dnf -y upgrade; mise up -y; uv tool upgrade --all || true; mise prune || true; update-zsh-plugins.sh'
        fi
fi

function sudo() {
        if [[ ${1} == "vim" ]]; then
                shift
                command sudo -E vim "${@}"
        else
                command sudo "${@}"
        fi
}

if [[ -x /opt/cisco/anyconnect/bin/vpn ]]; then
        alias vpn='~/.local/bin/vpn-onetouch'
        alias vpns='/opt/cisco/anyconnect/bin/vpn status'
        alias vpnd='/opt/cisco/anyconnect/bin/vpn disconnect'
fi

# isengardcli shell-profile is loaded by isengardcli.zsh — not duplicated here

if (( $+commands[figlet] )) && (( $+commands[lolcat] )); then
  function lolbanner() {
      echo
      figlet -c -f ~/.local/share/fonts/figlet-fonts/3d.flf "$@" | lolcat
      echo
  }
fi
