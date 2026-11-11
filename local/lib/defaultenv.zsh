#!/bin/zsh
# Sourced from zshrc. zsh only: uses $+commands and zsh tests to avoid
# running subprocesses on every shell start.
#export AWS_DEFAULT_REGION="ap-southeast-2"
#export AWS_REGIONS="ap-southeast-2 us-west-2"
export FZF_DEFAULT_COMMAND="fd --type file --hidden --follow --exclude .git --color=always"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"
export GOPROXY=direct
export GREP_COLORS="mt=01;31"
export DEFAULT_USER="${USER}"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# macOS: java_home takes ~30 ms, so cache its answer and only rerun it when
# the installed JDKs change (the JVM folder is newer than the cache).
if [[ -x /usr/libexec/java_home ]]; then
  _jh_cache="$HOME/.cache/java_home"
  if [[ ! -s "$_jh_cache" || /Library/Java/JavaVirtualMachines -nt "$_jh_cache" ]]; then
    [[ -d "${_jh_cache:h}" ]] || mkdir -p "${_jh_cache:h}"
    /usr/libexec/java_home >| "$_jh_cache" 2>/dev/null
  fi
  export JAVA_HOME="$(<"$_jh_cache")"
  unset _jh_cache
fi

if [[ "$TERM_PROGRAM" == "vscode" ]] || [[ "$TERM_PROGRAM" == "kiro" ]]; then
  unset PAGER
  unset AWS_PAGER
elif (( $+commands[moor] )); then
  export PAGER="moor"
  alias more="moor"
  export AWS_PAGER="moor"
elif (( $+commands[bat] )); then
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
