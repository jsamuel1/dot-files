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

function clone_or_pull {
    repo="${1}"
    dest="${2}"
    shift 2
    args=("$@")
    options=""
    for opt in "${args[@]}"; do
        if [ "${opt}" = "shallow" ] || [ "${opt}" = "--shallow" ]; then
            options="${options} --depth 1 --no-tags --single-branch"
        else
            options="${options} ${opt}"
        fi
    done

    if [ -d "${dest}" ]; then
        subheading "Updating ${dest}"
        git -C "${dest}" pull "${options}"
        cd - || exit 1
        return
    else
        subheading "Cloning ${repo} to ${dest}"
        git clone "${repo}" "${dest}" "${options}"
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