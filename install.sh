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

# Load the standard `skills` CLI via npx, which auto-detects your installed
# AI agents (Claude Code, Cursor, Copilot, etc.) and installs the skills.
if command -v npx >/dev/null 2>&1; then
  exec npx -y skills@latest add "$PACKAGE" "$@"
fi

# Fallback: run npx from PATH variants if not found directly
echo "npx not found on PATH. Install Node.js (includes npx): https://nodejs.org" >&2
exit 1
