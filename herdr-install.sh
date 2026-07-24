#!/usr/bin/env bash

# shellcheck source=./helpers.sh
source ./helpers.sh
scriptheader "${BASH_SOURCE:-$_}"

# herdr — terminal workspace manager for AI coding agents (https://herdr.dev).
# macOS installs the binary from Homebrew (see dependencies/Brewfile); other
# platforms fetch the release binary into ~/.local/bin. Workflow plugins are
# installed via `herdr plugin install` on every platform (idempotent).

HERDR_RELEASE="${HERDR_RELEASE:-latest}" # a tag like v0.7.5, or "latest"

# Plugins to install, as GitHub OWNER/REPO. Add more over time.
HERDR_PLUGINS=(
	persiyanov/herdr-reviewr               # code-review + file-viewer sidebar
	iurysza/herdr-tab-smart-rename         # context-aware tab/workspace names
	ogulcancelik/herdr-plugin-github-start # start Codex/Claude from a GH issue/PR
	ribbons-digital/pi-herd                # Pi session orchestration with herdr panes + worktrees
)

install_herdr_binary() {
	local arch
	case "$(uname -m)" in
	x86_64 | amd64) arch="x86_64" ;;
	aarch64 | arm64) arch="aarch64" ;;
	*)
		subsubheading "unsupported arch for herdr: $(uname -m)"
		return 1
		;;
	esac
	local base="https://github.com/ogulcancelik/herdr/releases"
	local url
	if [ "${HERDR_RELEASE}" = "latest" ]; then
		url="${base}/latest/download/herdr-linux-${arch}"
	else
		url="${base}/download/${HERDR_RELEASE}/herdr-linux-${arch}"
	fi
	mkdir -p "${HOME}/.local/bin"
	subheading "downloading herdr (${arch}) from ${url}"
	curl -fSL "${url}" -o "${HOME}/.local/bin/herdr" && chmod +x "${HOME}/.local/bin/herdr"
}

# 1) Ensure the herdr binary is available.
if ! command -v herdr >/dev/null 2>&1; then
	if is_mac; then
		subheading "installing herdr via Homebrew"
		brew install herdr || true
	else
		install_herdr_binary || subsubheading "herdr install failed; skipping plugins"
	fi
fi

# 2) Install workflow plugins (idempotent).
if command -v herdr >/dev/null 2>&1; then
	heading "installing herdr plugins"
	# `herdr plugin list` prints each plugin with its source as [github:owner/repo@sha].
	installed="$(herdr plugin list 2>/dev/null || true)"
	for repo in "${HERDR_PLUGINS[@]}"; do
		if printf '%s\n' "${installed}" | grep -qF "${repo}"; then
			subsubheading "already installed: ${repo}"
		else
			subheading "herdr plugin install ${repo}"
			# --yes must follow the OWNER/REPO positional (non-interactive install).
			herdr plugin install "${repo}" --yes || subsubheading "failed to install: ${repo}"
		fi
	done
else
	subsubheading "herdr not found on PATH; skipped plugin install"
fi

scriptfooter "${BASH_SOURCE:-$_}"
