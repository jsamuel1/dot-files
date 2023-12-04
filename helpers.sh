#!/bin/bash
# source me - don't execute.
[ -n "$HELPERSSH_SOURCES" ] && return
HELPERSSH_SOURCES=1
readonly HELPERSSH_SOURCES

bold="$(tput bold)"
normal="$(tput sgr0)"
readonly bold
readonly normal

function heading {
    title="${1}"
    echo "${bold}"
    echo "=========================================="
    col=$(( ( 42 - ${#title} ) / 2 ))
    tput cuf $col
    echo "${title}"
    echo "=========================================="
    echo "${normal}"
}

function subheading {
    title="${1}"
    echo "${bold}"
    echo " "
    col=$(( ( 42 - ${#title} ) / 2 ))
    tput cuf $col
    echo "${title}"
    echo "-------------------------------------------"
    echo "${normal}"
}

function is_amazonlinux2 {
    # shellcheck disable=SC1091
    [ -f /etc/os-release ] && source /etc/os-release

    if [ "$ID" = "amzn" ] && [ "$VERSION_ID" = "2" ]; then
        return 0 # 0= true
    fi

    return 1 # 1=false
}

function is_amazonlinux2023 {
    # shellcheck disable=SC1091
    [ -f /etc/os-release ] && source /etc/os-release

    if [ "$ID" = "amzn" ] && [ "$VERSION_ID" = "2023" ]; then
        return 0 # 0=true
    fi

    return 1 # 1=false
}