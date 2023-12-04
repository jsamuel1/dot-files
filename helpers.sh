#!/bin/bash
# source me - don't execute.

bold="$(tput bold)"
normal="$(tput sgr0)"
readonly bold
readonly normal

function heading() {
    readonly title=${1:?""}
    echo "${bold}"
    echo "============================"
    echo "${title}"
    echo "============================"
    echo "${normal}"
}

function subheading() {
    readonly title=${1:?""}
    echo "${bold}"
    echo " "
    echo "${title}"
    echo "----------------------------"
    echo "${normal}"
}
