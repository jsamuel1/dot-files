#!/bin/sh
# to be sourced from bash or zsh
#export AWS_DEFAULT_REGION="ap-southeast-2"
#export AWS_REGIONS="ap-southeast-2 us-west-2"
export FZF_DEFAULT_COMMAND="fd --type file --hidden --follow --exclude .git --color=always"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"
export GOPROXY=direct
export GREP_COLORS="mt=01;31"
export DEFAULT_USER="${USER}"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
if [ -x /usr/libexec/java_home ]; then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

if [[ "$TERM_PROGRAM" == "vscode" ]] || [[ "$TERM_PROGRAM" == "kiro" ]]; then
  unset PAGER
  unset AWS_PAGER
elif command -v moor >/dev/null 2>&1; then
  export PAGER="moor"
  alias more="moor"
  export AWS_PAGER="moor"
elif command -v bat >/dev/null 2>&1; then
  alias more="bat"
  export PAGER="bat"
  export AWS_PAGER="bat"
else
  alias more="less"
  export PAGER="less"
  export AWS_PAGER="less"
fi
export LESS="-EFiMQR~X --tabs=4"
#export AWS_PAGER="less"
if [ -x /opt/homebrew/bin/brew ]; then
  export HOMEBREW_PREFIX=/opt/homebrew
  export RUBY_CONFIGURE_OPTS="--with-openssl-dir=${HOMEBREW_PREFIX}/opt/openssl"
  export HOMEBREW_NO_ENV_HINTS=1
fi

# Google Application Default Credentials — only when the file exists,
# otherwise Google SDKs hard-fail instead of falling back to other auth
if [ -f "$HOME/.config/gcloud/application_default_credentials.json" ]; then
  export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"
fi

# Slack
export SLACK_DM_CHANNEL="D092HG7S63W"
