#!/usr/bin/env bash
# <repo-name> — installer shim.
#
# Thin wrapper that loads the standard `skills` CLI and installs these skills.
#
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash -s -- --all
#
# Local clone:
#   bash install.sh [flags]

set -euo pipefail

PACKAGE="<owner>/<repo>"

# Load the standard `skills` CLI via npx, which auto-detects your installed
# AI agents (Claude Code, Cursor, Copilot, etc.) and installs the skills.
# Every flag passed (e.g. -g, -a <agent>, -s <skill>, -y, --all, --list) is
# forwarded unchanged to `skills add`.
#
# NOTE: do NOT pass a literal `--` to npx — npm 7+ already forwards trailing
# args, and a literal `--` can trip the CLI's arg parser.
if command -v npx >/dev/null 2>&1; then
  exec npx -y skills@latest add "$PACKAGE" "$@"
fi

echo "npx not found on PATH. Install Node.js (includes npx): https://nodejs.org" >&2
exit 1
