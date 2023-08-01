#!/bin/sh
# to be sourced from bash or zsh
export AWS_DEFAULT_REGION="ap-southeast-2"
export AWS_REGIONS="ap-southeast-2 us-west-2"
export FZF_DEFAULT_COMMAND="fd --type file --hidden --follow --exclude .git --color=always"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"
#export GOPATH="${HOME}/goprojects"
#export GOROOT="${HOME}/go"
export GREP_COLORS="mt=01;31"
export PATH="${PATH}:${GOPATH}:${PYENV_ROOT}/bin"
export PYENV_ROOT="${HOME}/.pyenv"
export DEFAULT_USER=`whoami`
export DOTNET_CLI_TELEMETRY_OPTOUT=1
if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi
export PAGER="less"
export LESS="-EFiMQR~ --tabs=4"
export AWS_PAGER="less"
if [ -x brew ]; then
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
fi
