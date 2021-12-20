if whence -pv isengardcli &>/dev/null ; then
  isengardcli_load() {
    unset -f isengardcli
    eval "$(isengardcli shell-profile)"
  }

isengardcli() {
  lazy_load_isengardcli()
  isengardcli $@
}

fi

