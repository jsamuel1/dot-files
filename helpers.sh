#!/usr/bin/env bash

# Prevent script from being executed directly.  Must be used via source
# ref: https://tldp.org/LDP/abs/html/parameter-substitution.html -- search for "# Name of script"
if [ "${BASH_SOURCE[0]##*/}" = "${0##*/}" ]; then
	echo "This script must be sourced, not executed."
	exit 1
fi

[ -n "$HELPERSSH_SOURCES" ] && return
HELPERSSH_SOURCES=1

TERM=${TERM:-dumb} # ensure tput does sensible values if non-interactive
bold="$(tput bold)"
normal="$(tput sgr0)"

command -v mise >/dev/null && eval "$(mise activate bash)"
command -v mise >/dev/null && eval "$(mise hook-env)"

function heading {
	echo "${bold}"
	echo "=============================================================================="
	while [ -n "${1}" ]; do
		col=$(((78 - ${#1}) / 2))
		printf '%*s%s\n' "${col}" "" "${1}"
		shift 1
	done
	echo "=============================================================================="
	echo "${normal}"
}

function subheading {
	echo "${bold}"
	while [ -n "${1}" ]; do
		col=$(((78 - ${#1}) / 2))
		printf '%*s%s\n' "${col}" "" "${1}"
		shift 1
	done
	echo "------------------------------------------------------------------------------"
	echo "${normal}"
}

function subsubheading {
	echo "${bold}"
	while [ -n "${1}" ]; do
		col=$(((78 - ${#1}) / 2))
		printf '%*s%s\n' "${col}" "" "${1}"
		shift 1
	done
	echo "${normal}"
}

function scriptheader {
	echo -n "${bold}"
	echo "------------------------------------------------------------------------------"
	title="Script: ${1##*/}"
	col=$(((78 - ${#title}) / 2))
	printf '%*s%s\n' "${col}" "" "${title}"
	echo "------------------------------------------------------------------------------"
	echo -n "${normal}"
}

function scriptfooter {
	echo -n "${bold}"
	echo "------------------------------------------------------------------------------"
	title="Done: ${1##*/}"
	col=$(((78 - ${#title}) / 2))
	printf '%*s%s\n' "${col}" "" "${title}"
	echo "------------------------------------------------------------------------------"
	echo -n "${normal}"
}

function clone_or_pull {
	# clone_or_pull <repo> <dest> <options>
	# returns: 0=true= Already up to date, 1=false= Not up to date
	# options:
	# --shallow

	repo="${1}"
	dest="${2}"
	shift 2
	args=("$@")
	OPTIONS=(--no-progress)
	for opt in "${args[@]}"; do
		if [ "${opt}" = "shallow" ] || [ "${opt}" = "--shallow" ]; then
			OPTIONS+=(--depth 1 --no-tags)
		else
			OPTIONS+=("${opt}")
		fi
	done

	if [ -d "${dest}" ]; then
		subsubheading "Updating" "${dest}"
		git -C "${dest}" pull "${OPTIONS[@]}" | grep "Already up to date"
		return $? # 0=true= Already up to date, 1=false= Not up to date
	else
		subsubheading "Cloning" "${repo}" "to" "${dest}"
		git clone "${repo}" "${dest}" "${OPTIONS[@]}"
		return 1 # 1=false= Not up to date
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

function is_like_debian {
	# shellcheck source=/dev/null
	[ -f /etc/os-release ] && source /etc/os-release

	if [ "$ID" = "debian" ] || [ "$ID_LIKE" = "debian" ]; then
		return 0 # 0= true
	fi

	return 1 # 1=false
}

function is_mac {
	if [ "$(uname)" = "Darwin" ]; then
		return 0 # 0=true
	fi

	return 1 # 1=false
}

function is_wsl {
	if [ -n "$WSL_DISTRO_NAME" ]; then
		return 0 # 0=true
	fi

	return 1 # 1=false
}

function awkxargs {
	# product something like:
	# awk '! /^ *(#|$)/' "gemrequirements.txt" | xargs "${MISEX[@]}" gem install
	FILTER='! /^ *(#|$)/'
	if [ "${1}" == "1" ]; then
		XARGOPTS=(-n 1)
		shift
	fi

	FILENAME=${1}
	shift 1
	awk "${FILTER}" "${FILENAME}" | xargs "${XARGOPTS[@]}" -- "$@"
}

function symlink_file {
	shopt | grep extglob >/dev/null && shopt -s extglob
	shopt | grep globstar >/dev/null && shopt -s globstar
	SOURCEFILE="${1%/}" # remove any trailing /
	TARGETFILE="${2%/}" # remove any trailing /

	if [ ! -f "${SOURCEFILE}" ]; then
		echo "ERROR: Sourcepath ${SOURCEFILE} does not exist"
		return
	fi

	SOURCEFILE="$(realpath "${SOURCEFILE}")"
	TARGETFILE="$(realpath "${TARGETFILE}")"
	TARGETDIR="$(dirname "${TARGETFILE}")"

	if [ ! -d "${TARGETDIR}" ]; then
		echo "creating ${TARGETDIR}"
		mkdir -p "${TARGETDIR}"
	fi

	if [[ -L "${TARGETFILE}" && "${SOURCEFILE}" == "$(realpath "${TARGETFILE}")" ]]; then
		return
	fi

	echo "symlinking ${SOURCEFILE} to ${TARGETFILE}"
	ln -sf "${SOURCEFILE}" "${TARGETFILE}"
}

function symlink_all {
	shopt | grep extglob >/dev/null && shopt -s extglob
	shopt | grep globstar >/dev/null && shopt -s globstar
	SOURCEPATH="${1%/}" # remove any trailing /
	TARGETPATH="${2%/}" # remove any trailing /
	shift 2
	FDOPTIONS=("${@}")

	if [ ! -d "${SOURCEPATH}" ]; then
		echo "ERROR: Sourcepath ${SOURCEPATH} does not exist"
		return
	fi
	for SOURCEFILE in $(fd "${FDOPTIONS[@]}" --type file . "${SOURCEPATH}"); do
		if [ -d "${SOURCEFILE}" ]; then
			echo "skipping ${SOURCEFILE}"
			continue
		fi

		TARGETFILE="${TARGETPATH%/}/${SOURCEFILE#"${SOURCEPATH}/"}"
		TARGETDIR="$(dirname "${TARGETFILE}")"

		if [ -f "${SOURCEFILE}" ]; then
			if [ ! -d "${TARGETDIR}" ]; then
				echo "creating ${TARGETDIR}"
				mkdir -p "${TARGETDIR}"
			fi

			if [[ -L "${TARGETFILE}" && "${SOURCEFILE}" == "$(realpath "${TARGETFILE}")" ]]; then
				continue
			fi

			echo "symlinking ${SOURCEFILE} to ${TARGETFILE}"
			ln -sf "${SOURCEFILE}" "${TARGETFILE}"
		fi
	done
}

function cleanup_broken_symlinks {
	TARGETPATH="${1}"
	SHALLOW="${2}"

	if [ ! -d "${TARGETPATH}" ]; then
		echo "ERROR: Targetpath ${TARGETPATH} does not exist"
		return
	fi

	# remove brooken symlinks. Example from "man find"
	FDOPTIONS=(--follow --hidden --type symlink --exclude node_modules --exclude build --exclude site-packages)
	if [ -n "${SHALLOW}" ]; then
		FDOPTIONS+=(--max-depth=1)
	fi
	FILECOUNT="$(fd "${FDOPTIONS[@]}" . "${TARGETPATH}" | wc -l)"
	echo -n "${TARGETPATH}: ${FILECOUNT} broken symlinks found."
	if [ "${FILECOUNT}" -gt 0 ]; then
		fd "${FDOPTIONS[@]}" . "${TARGETPATH}" --batch-size 10 --exec-batch rm --
		echo "Fixed."
		return
	fi
	echo " " # Newline for "broken symlinks echo with \c above"
}

# top of script function to keep sudo alive.
# Note - brew / sudo -K will reset this.
function sudo_alive {
	# Ask for the administrator password upfront
	# note - sudo -v doesn't work when passwordless sudo
	sudo true

	# Keep-alive: update existing `sudo` time stamp until script has finished
	# Note & on while loop for background
	while true; do
		sleep 60
		sudo -n true
		kill -0 "$$" || exit
	done 2>/dev/null &
}
