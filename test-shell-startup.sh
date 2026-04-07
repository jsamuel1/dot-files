#!/bin/sh
# test-shell-startup.sh — Measure zsh startup times across shell modes.
# Useful for diagnosing GUI app env resolution (QuickWork, VS Code, etc.)
# that probe the login shell with a timeout (typically 5s).

SHELL_CMD="${SHELL:-/bin/zsh}"
PROBE='echo "PATH=$PATH"; echo "HOME=$HOME"'

echo "Shell: $SHELL_CMD"
echo "============================================"
echo ""

echo "1) zsh -lic (login + interactive) — with PTY (real terminal)"
echo "   Sources: .zshenv → .zprofile → .zshrc → .zlogin"
time script -q /dev/null env -i HOME="$HOME" USER="$USER" SHELL="$SHELL_CMD" "$SHELL_CMD" -lic "$PROBE" >/dev/null 2>&1
echo ""

echo "2) zsh -lic (login + interactive) — no TTY (QuickWork probe)"
echo "   Sources: .zshenv (early exit if no TTY)"
time env -i HOME="$HOME" USER="$USER" SHELL="$SHELL_CMD" "$SHELL_CMD" -lic "$PROBE" >/dev/null 2>&1
echo ""

echo "3) zsh -lc (login, non-interactive)"
echo "   Sources: .zshenv → .zprofile → .zlogin"
time env -i HOME="$HOME" USER="$USER" SHELL="$SHELL_CMD" "$SHELL_CMD" -lc "$PROBE" >/dev/null 2>&1
echo ""

echo "4) zsh -c (non-interactive, non-login)"
echo "   Sources: .zshenv only"
time env -i HOME="$HOME" USER="$USER" SHELL="$SHELL_CMD" "$SHELL_CMD" -c "$PROBE" >/dev/null 2>&1
echo ""

echo "============================================"
echo "QuickWork shell_env.py timeout: 5 seconds"
echo "Mode 1 = real terminal startup time."
echo "Mode 2 = what QuickWork sees (should be <1s)."
