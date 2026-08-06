#!/usr/bin/env bash
# mobile-dev-skills — installer shim.
#
# Thin wrapper that loads the standard `skills` CLI and installs these skills.
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/OMIXEC/Mobile-dev-skills/main/install.sh | bash
#
# Local clone:
#   bash install.sh [flags]

set -euo pipefail

PACKAGE="omixec/Mobile-dev-skills"

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found on PATH. Install Node.js (includes npx): https://nodejs.org" >&2
  exit 1
fi

# The `skills` CLI is interactive (selecting skills / agents). Under
# `curl ... | bash`, stdin is the piped install.sh script — leaving this
# script's trailing bytes on the pipe. When we `exec` the CLI it inherits
# that pipe as stdin, so its TUI reads the leftover bytes as fake keystrokes
# and crashes.
#
# Fix: when stdin is a pipe but a controlling terminal exists, re-attach the
# CLI to the real terminal (/dev/tty) for its interactive prompts. In a true
# TTY or CI environment (no /dev/tty) we run normally / non-interactively.
if [ ! -t 0 ] && [ -e /dev/tty ]; then
  exec npx -y skills@latest add "$PACKAGE" "$@" </dev/tty
fi

exec npx -y skills@latest add "$PACKAGE" "$@"
