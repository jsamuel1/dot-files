#!/usr/bin/env bash

# Prevent script from being executed directly.  Must be used via source
# ref: https://tldp.org/LDP/abs/html/parameter-substitution.html -- search for "# Name of script"
if [ "${BASH_SOURCE[0]##*/}" = "${0##*/}" ]; then
    echo "This script must be sourced, not executed."
    exit 1
fi

[ -n "$HELPERSSH_SOURCES" ] && return
HELPERSSH_SOURCES=1

bold="$(tput bold)"
normal="$(tput sgr0)"

function heading {
    title="${1}"
    echo "${bold}"
    echo "============================================================"
    col=$(( ( 80 - ${#title} ) / 2 ))
    tput cuf $col
    echo "${title}"
    echo "============================================================"
    echo "${normal}"
}

function subheading {
    title="${1}"
    echo "${bold}"
    echo " "
    col=$(( ( 80 - ${#title} ) / 2 ))
    tput cuf $col
    echo "${title}"
    echo "-----------------------------------------------------------"
    echo "${normal}"
}

function clone_or_pull {
    repo="${1}"
    dest="${2}"
    shift 2
    args=("$@")
    options=""
    for opt in "${args[@]}"; do
        if [ "${opt}" = "shallow" ] || [ "${opt}" = "--shallow" ]; then
            options="${options} --depth 1 --no-tags"
        else
            options="${options} ${opt}"
        fi
    done

    if [ -d "${dest}" ]; then
        subheading "Updating ${dest}"
        # shellcheck disable=SC2086
        git -C "${dest}" pull ${options}
        cd - || exit 1
        return
    else
        subheading "Cloning ${repo} to ${dest}"
        # shellcheck disable=SC2086
        git clone "${repo}" "${dest}" ${options}
        return
    fi
}
function is_amazonlinux2 {
    # shellcheck source=/dev/null
    [ -f /etc/os-release ] && source /etc/os-release

    if [ "$ID" = "amzn" ] && [ "$VERSION_ID" = "2" ]; then
        return 0 # 0= true
    fi

    return 1 # 1=false
}

function is_amazonlinux2023 {
    # shellcheck source=/dev/null
    [ -f /etc/os-release ] && source /etc/os-release

    if [ "$ID" = "amzn" ] && [ "$VERSION_ID" = "2023" ]; then
        return 0 # 0=true
    fi

    return 1 # 1=false
}

function is_mac {
    if [ "$(uname)" = "Darwin" ]; then
        return 0 # 0=true
    fi

    return 1 # 1=false
}