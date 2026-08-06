# `npx skills` CLI Reference

The official `skills` CLI is the standard installer for AI agent skills. It is developed by
Vercel Labs (with context7) and lives at github.com/vercel-labs/skills. More info:
https://skills.sh

The npm package name is `skills`. It exposes two binaries: `skills` and `add-skill`.

## Package

```bash
npx -y skills@latest <command>   # run the latest version ephemerally (no global install)
npm install -g skills            # install globally, then call `skills` directly
```

## Add a Skill Package

```bash
npx skills add <owner/repo>                  # basic; auto-detect agents
npx skills add https://github.com/owner/repo # full URL also accepted
```

### Add Options

| Flag | Description |
|------|-------------|
| `-g, --global` | Install globally (user-level) instead of project-level |
| `-a, --agent <agents>` | Target specific agents (`*` = all agents) |
| `-s, --skill <skills>` | Target specific skills (`*` = all skills) |
| `-l, --list` | List available skills in the repo without installing |
| `-y, --yes` | Skip confirmation prompts (non-interactive) |
| `--copy` | Copy files instead of symlinking |
| `--all` | Shorthand for `--skill '*' --agent '*' -y` (non-interactive, everything) |
| `--subagent <names>` | Install to Eve subagents |
| `--metadata <json>` | Attach JSON to the install telemetry event |
| `--full-depth` | Search all subdirectories even when a root SKILL.md exists |

## Common Install Commands

```bash
npx skills add owner/repo                        # basic
npx skills add owner/repo --skill skill-name     # one skill
npx skills add owner/repo -a claude-code         # one agent
npx skills add owner/repo -g                     # global (user-level)
npx skills add owner/repo --skill skill-name -g -y   # non-interactive/CI
npx skills add owner/repo --list                 # list, don't install
npx skills add owner/repo --all                  # everything, no prompts
```

## Use One Skill Without Installing

```bash
npx skills use owner/repo@skill-name
npx skills use owner/repo --skill skill-name --agent claude-code
```

Generates a prompt for using one skill without installing it.

## Manage Installed Skills

```bash
npx skills find [query]      # search for skills (interactive)
npx skills find mobile --owner vercel   # search within an owner
npx skills list, ls          # list installed skills (default: project)
npx skills list -g           # list global skills
npx skills list --json       # JSON output
npx skills remove [skills]   # remove installed skills
npx skills remove web-design # remove by name
npx skills rm --global frontend-design
```

## Update Skills

```bash
npx skills update              # update all installed skills
npx skills update my-skill     # update one skill
npx skills update -g           # update global skills only
npx skills update -p           # update project skills only
npx skills update -y           # skip scope prompt
```

## Project / Sync

```bash
npx skills experimental_install    # restore from skills-lock.json
npx skills init [name]             # initialize a skill (creates <name>/SKILL.md)
npx skills experimental_sync       # sync skills from node_modules into agent dirs
npx skills experimental_sync -y    # sync without prompts
```

## Non-Interactive Behavior

`npx skills add <owner/repo>` is **interactive by default**: with no TTY it shows a
"Select skills to install" prompt that hangs. For scripts, CI, and `curl | bash` one-liners,
pass `-y` or `--all` so the command completes without input.

## Discovery Behavior

The CLI discovers skills by scanning a repository for `SKILL.md` files (recursively, following
the Agent Skills standard at agentskills.io). A plain `skills/*/SKILL.md` layout works without
any custom configuration.
