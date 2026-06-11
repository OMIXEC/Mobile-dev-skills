# Mobile Development Skills

A curated collection of 27 AI agent skills for building native and cross-platform mobile applications. Works with Claude Code, OpenCode, Codex CLI, and Cursor.

## Quick Install

```bash
# Auto-detect your AI agent and install all skills globally
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install.sh | bash
```

After installing, restart your AI agent to start using the skills.

### More Install Options

```bash
# Install interactively (pick which skills you want)
./install.sh --interactive

# Force a specific platform
./install.sh --platform opencode

# Install into a project directory (not global)
./install.sh --project ./my-mobile-app

# List all available skills without installing
./install.sh --list
```

---

## Available Skills

### Core Mobile

| Skill | Description |
|-------|-------------|
| `ios-swift-development` | Native iOS with Swift, SwiftUI, Combine, MVVM, Core Data |
| `flutter-development` | Cross-platform Flutter with Riverpod, GoRouter, Dio, Firebase |
| `mobile-development` | Platform decision guide (iOS, Android, Flutter, React Native, Games) |
| `app-store-preflight` | Scan iOS/macOS projects for App Store rejection patterns before submission |
| `app-store-screenshots` | Generate App Store marketing screenshots programmatically |
| `app-icon-generator` | Generate app icons in all required sizes for iOS, Android, PWA |

### Code Conversion

| Skill | Description |
|-------|-------------|
| `refactor-swift-to-flutter` | Convert Swift/iOS code to Flutter/Dart patterns |
| `flutter-sdk-to-swift` | Convert Flutter/Dart code to Swift/iOS native patterns |

### Architecture & Code Quality

| Skill | Description |
|-------|-------------|
| `clean-architecture` | Clean Architecture principles from Robert C. Martin |
| `clean-code` | Clean Code best practices for maintainable code |
| `senior-architect` | Architecture decision records, system design, diagram generation |
| `coding-guidelines` | Rust code style and best practices |
| `ai-coding-discipline` | Rules that prevent common AI coding anti-patterns |

### Development Practices

| Skill | Description |
|-------|-------------|
| `systematic-debugging` | Root-cause-first debugging methodology |
| `wisdom-driven` | Inner motivation methodology for AI agents |
| `deep-research` | Comprehensive multi-source research methodology |

### Design & Frontend

| Skill | Description |
|-------|-------------|
| `frontend-design` | Production-grade frontend interfaces with high design quality |
| `high-end-visual-design` | Agency-tier UI/UX with motion, depth, and micro-interactions |
| `liquid-glass-design` | iOS 26 Liquid Glass design system for SwiftUI and UIKit |
| `design-taste-frontend` | Metric-based design engineering with strict component rules |
| `senior-frontend` | React, Next.js, TypeScript, Tailwind patterns |

### Backend & DevOps

| Skill | Description |
|-------|-------------|
| `api-design-principles` | REST and GraphQL API design best practices |
| `postgresql-table-design` | PostgreSQL schema design, indexing, and performance |
| `devops-engineer` | Docker, CI/CD, Kubernetes, Terraform, platform engineering |
| `optimize-cicd-pipeline` | CI/CD pipeline analysis and optimization |
| `openapi-spec-generation` | OpenAPI 3.1 specification generation and validation |

### Testing

| Skill | Description |
|-------|-------------|
| `e2e-testing-patterns` | End-to-end testing with Playwright, Cypress, and mobile frameworks |

---

## Repository Structure

```
mobile-dev-skills/
├── install.sh              # Unified installer for all platforms
├── README.md
├── scripts/                # Shared utility scripts
│   ├── test-mobile.sh      # Adaptive test runner (iOS/Flutter/Android)
│   └── validate-skill.sh   # Validate skill structure and frontmatter
├── hooks/                  # Reusable hook patterns for mobile skills
│   └── hooks.md            # PreToolUse and PostToolUse patterns
├── references/             # Shared reference documentation
│   └── testing-patterns.md # Test frameworks and best practices by platform
└── skills/                 # 27 individual skill directories
    ├── ios-swift-development/
    ├── flutter-development/
    ├── app-store-preflight/
    └── ...
```

---

## Testing & Hooks

### Adaptive Test Runner

The `scripts/test-mobile.sh` script auto-detects your mobile platform and runs the right tests:

```bash
# Run from any mobile project root
bash scripts/test-mobile.sh

# Force a specific platform
bash scripts/test-mobile.sh --platform flutter
```

It detects:
- **iOS** — looks for `.xcodeproj`, `.xcworkspace`, or `.swift` files; runs `xcodebuild test`
- **Flutter** — looks for `pubspec.yaml` with flutter dependency; runs `flutter analyze` + `flutter test`
- **Android** — looks for `build.gradle` or `.kt` files; runs `./gradlew lint` + `./gradlew test`

### Hooks

See `hooks/hooks.md` for PreToolUse and PostToolUse patterns that can be integrated into skills to automatically run tests before/after code changes.

### Skill Validation

```bash
# Validate a single skill
bash scripts/validate-skill.sh skills/ios-swift-development

# Validate all skills
for d in skills/*/; do bash scripts/validate-skill.sh "$d"; done
```

---

## Manual Installation

If you prefer to install manually:

```bash
# Clone the repo
git clone https://github.com/omixec/mobile-skills.git ~/mobile-skills

# Link into your agent's skills directory (example: Claude Code)
mkdir -p "$HOME/Library/Application Support/Claude/Skills"
cd "$HOME/Library/Application Support/Claude/Skills"
for dir in ~/mobile-skills/skills/*/; do
    ln -sf "$dir" "skill-$(basename "$dir")"
done
```

---

## Updating

```bash
cd ~/mobile-skills
git pull origin main
```

Or if installed via `install.sh`:

```bash
cd "$(find "$HOME" -path "*/Skills/mobile-skills" -type d 2>/dev/null | head -1)"
git pull origin main
```

---

## Contributing

To add a new skill:

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter (`name` and `description` fields)
2. Add optional `references/`, `scripts/`, or `assets/` directories inside your skill folder
3. Validate with `bash scripts/validate-skill.sh skills/<skill-name>`
4. Add the skill to the table above in this README
5. Submit a PR

**Skill frontmatter format:**

```markdown
---
name: my-skill
description: >
  What this skill does and when it should be triggered. Be concrete about
  the contexts where the agent should load this skill.
---
```

## License

MIT
