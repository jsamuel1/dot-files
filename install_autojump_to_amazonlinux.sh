#!/usr/bin/env bash
(
	cd "$(mktemp -d)"
	git clone https://github.com/wting/autojump.git
	cd autojump
	./install.py
)
