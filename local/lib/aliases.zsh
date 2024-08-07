#!/bin/zsh
#
# to be sourced from zshrc or bashrc
alias grep='grep --exclude="*.pyc" --exclude="*.swp" --exclude="*.tfstate.backup" --color=auto --exclude-dir=.terraform --exclude-dir=.git'
alias pip='python -m pip' # always use current pipenv's python for pip
alias please='sudo'
alias vi='nvim'  # some things just like vi
alias vim='nvim' # nvim nvim nvim.  for when the system override is wrong :)
if bat -V >/dev/null 2>&1; then
        alias cat='bat --style=plain'
elif pygmentize -V ; then
        alias cat="pygmentize -g -O style=monokai"
fi

# Detect which `ls` flavor is in use
if ls --color -d >/dev/null 2>&1; then # GNU `ls`
        colorflag="--color"
        export LS_COLORS='no=00:fi=00:di=01;31:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
else # macOS `ls`
        colorflag="-FG"
        export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
fi

# Always use color output for `ls`
alias ls="command ls ${colorflag}"

if [[ "$OSTYPE" =~ darwin* ]]; then
        # Empty the Trash on all mounted volumes and the main HDD.
        # Also, clear Apple’s System Logs to improve shell startup speed.
        # Finally, clear download history from quarantine. https://mths.be/bum
        alias emptytrash="( sudo rm -rfv /Volumes/*/.Trashes ) ; ( sudo rm -rfv ~/.Trash ) ; ( sudo rm -rfv /private/var/log/asl/*.asl ) ; ( sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent' )"

        # Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
        alias update='sudo softwareupdate -i -a; sudo gem update --system; sudo gem cleanup; brew update; brew upgrade; brew cleanup; npm update -g npm; npm update -g; gem update;'

        if command -v finch &>/dev/null; then
                alias docker=finch
                export CDK_DOCKER=finch
        fi
fi

if ! [[ "$OSTYPE" =~ darwin* ]]; then
        alias fd='fdfind'
fi

function sudo() {
        if [[ ${1} == "vim" ]]; then
                shift
                command sudo -E vim "${@}"
        else
                command sudo "${@}"
        fi
}

if command -v /opt/cisco/anyconnect/bin/vpn &>/dev/null; then
        alias vpn='~/.local/bin/vpn-onetouch'
        alias vpns='/opt/cisco/anyconnect/bin/vpn status'
        alias vpnd='/opt/cisco/anyconnect/bin/vpn disconnect'
fi

if command -v isengardcli &>/dev/null; then
        eval "$(isengardcli shell-profile)"
fi
