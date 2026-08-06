## Quick Install

Install these skills with the standard **`skills` CLI** (github.com/vercel-labs/skills). It
auto-detects the AI agents you have installed (Claude Code, Cursor, Copilot, etc.) and configures
the skills for them.

### Direct install (`npx skills add`)
```bash
npx skills add <owner>/<repo>
```

### Fast one-liner (curl | bash)
This downloads `install.sh`, which runs the exact same `npx skills add <owner>/<repo>` command:
```bash
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash
```

For a fully non-interactive install of every skill to every detected agent:
```bash
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/install.sh | bash -s -- --all
```

### Install a specific skill
```bash
npx skills add <owner>/<repo> --skill skill-name
```

### Target a specific agent
```bash
npx skills add <owner>/<repo> -a claude-code
```

### Global installation (user-level)
```bash
npx skills add <owner>/<repo> -g
```

### Non-interactive / CI-CD mode
```bash
npx skills add <owner>/<repo> --skill skill-name -g -y
```

### List available skills in this repo (without installing)
```bash
npx skills add <owner>/<repo> --list
```

---

After installing, restart your AI agent to start using the skills.

### Manage / find skills
```bash
npx skills find mobile        # search for mobile skills
npx skills update             # update all installed skills
npx skills list               # list installed skills
npx skills remove <skill>    # remove a skill
```
