---
name: skillcli-installer
description: >
  This skill should be used when the user asks to "make your skills installable via npx skills",
  "create a skill CLI like Vercel", "set up the curl | bash one-liner that runs npx skills add",
  "publish skills through the standard skills CLI", "make my repo work with npx skills add owner/repo",
  "add the GitHub raw one-liner installation link", or "turn my skill collection into an npx package".
  Provides the workflow for publishing a skills collection through the standard Vercel-Labs `skills`
  CLI and wiring up a `curl | bash` one-liner that delegates to it.
---

# Skill CLI Installer (Vercel-style)

Publish a collection of agent skills as a standard, `npx`-installable package and wire up a
one-line `curl | bash` installer. The goal is to install skills with the community-standard command

```
npx skills add <owner>/<repo>
```

plus a GitHub raw one-liner that delegates to it:

```
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash
```

## When to Use

- Making a `skills/` collection consumable through the official `skills` CLI.
- Adding a Vercel-style one-liner (`curl ... | bash`) to a skill repo.
- Wiring an `install.sh` shim that forwards to `npx skills add`.
- Documenting the standard install commands in a README.

## Core Idea

The official **`skills` CLI** (github.com/vercel-labs/skills) is the community-standard installer
for AI agent skills. It scans any repository's `skills/*/SKILL.md` layout, auto-detects installed
agents (Claude Code, Cursor, Copilot, etc.), and installs each skill into the correct directory.
No custom installer logic is required — a repo is installable simply by having the standard
`skills/` + `SKILL.md` structure.

`install.sh` should therefore be a **thin shim** that just runs the standard command, not a
reimplementation of platform detection and copying.

## Step 1 — Confirm the Repo Follows the Standard Skill Layout

Ensure skills live in `skills/<skill-name>/SKILL.md` with valid frontmatter (`name` + `description`).
Validate that the `skills` CLI discovers them:

```bash
npx skills add <owner>/<repo> --list
```

This prints every discovered skill with its description. If it lists them correctly, the repo is
already installable — no custom installer needed.

## Step 2 — Write the `install.sh` Shim

Create `install.sh` as a minimal delegating shim. It must run the standard command and forward
all flags:

```bash
#!/usr/bin/env bash
set -euo pipefail

PACKAGE="<owner>/<repo>"

if command -v npx >/dev/null 2>&1; then
  exec npx -y skills@latest add "$PACKAGE" "$@"
fi

echo "npx not found on PATH. Install Node.js (includes npx): https://nodejs.org" >&2
exit 1
```

Key rules:
- **Forward all arguments** with `"$@"` — every `skills add` flag (`-g`, `-a <agent>`,
  `-s <skill>`, `-y`, `--all`, `--list`) passes through unchanged.
- **Do NOT pass a literal `--`** to npx. npm 7+ already forwards trailing args; a literal `--`
  can trip the CLI's arg parser.
- **Require npx** (ships with Node ≥18). Fail loudly with an install hint otherwise.
- Keep the body tiny — avoid re-implementing platform detection, symlinking, or copying.

## Step 3 — Wire Up the One-Liner

The one-liner fetches `install.sh` from the raw GitHub URL and pipes it to bash:

```
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash
```

Add the `--all` variant for a fully non-interactive install of every skill to every agent:

```
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash -s -- --all
```

### Critical: Commit and Push

`curl | bash` reads the file from `main` **on GitHub**, not the local clone. An un-pushed
`install.sh` change is invisible to the one-liner — it keeps serving the old file. Always commit
and push before testing the one-liner:

```bash
git add install.sh README.md
git commit -m "refactor(install): delegate to standard npx skills CLI"
git push origin main
```

### Raw CDN Caching

`raw.githubusercontent.com` is behind a CDN that can serve a stale copy briefly after a push.
Verify the live content with the exact commit SHA (bypasses cache) rather than `main`:

```bash
SHA=$(git rev-parse HEAD)
curl -sL "https://raw.githubusercontent.com/<owner>/<repo>/$SHA/install.sh"
```

The `main` URL refreshes on its own shortly after the push.

## Step 4 — Document the Install Commands in the README

Make `npx skills add` the primary method and show the one-liner explicitly. Do **not** label the
`curl | bash` path "legacy" — it is the same npx skills install.

```markdown
## Quick Install
### Direct install (npx skills add)
npx skills add <owner>/<repo>

### Fast one-liner (curl | bash)
This downloads install.sh, which runs the exact same `npx skills add` command:
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash
```

Add the common variants (specific skill, specific agent, global, non-interactive, list) so users
self-serve. See `examples/README-install-section.md`.

## Step 5 — Validate and Test

- Confirm `npx skills add <owner>/<repo> --list` discovers all skills.
- Run the shim locally: `bash install.sh --list` delegates to `npx skills add`.
- Verify the remote file after push: `curl -sL .../main/install.sh` shows the shim, not old code.
- Check the one-liner end-to-end with `--list` or `--all`.

## Common Mistakes

1. **An un-pushed installer.** The one-liner reads `main` on GitHub; commit and push changes.
2. **Re-implementing the installer.** The `skills` CLI already handles detection and install;
   `install.sh` should only delegate.
3. **Passing a literal `--` to npx.** Breaks the CLI's arg parser on npm 7+.
4. **Labeling `curl | bash` as "legacy."** It's the same standard install; frame it as such.
5. **Forgetting the raw CDN cache.** Verify with the commit SHA after a push.

## Additional Resources

### Reference Files
- **`references/skills-cli.md`** — Full `npx skills` command and flag reference.

### Example Files
- **`examples/install.sh`** — Working minimal delegating shim (copy and adapt).
- **`examples/README-install-section.md`** — README install documentation to copy.
