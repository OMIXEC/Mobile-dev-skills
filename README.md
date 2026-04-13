# Mobile Skills

Cross-platform mobile development skills for AI coding agents (Claude, OpenCode, Cursor, Codex).

## Available Skills

| Skill | Description |
|-------|-------------|
| `ios-swift-development` | Native iOS development with Swift, SwiftUI, Combine, MVVM |
| `flutter-development` | Cross-platform Flutter/Dart with Riverpod, GoRouter, Dio |
| `refactor-swift-to-flutter` | Convert Swift/iOS code to Flutter/Dart |
| `flutter-sdk-to-swift` | Convert Flutter/Dart code to Swift/iOS |

## Quick Install (One Command)

### Claude Code / Claude Desktop

```bash
# Clone and link skills
cd ~/Library/Application\ Support/Claude/Skills && \
git clone https://github.com/omixec/mobile-skills.git mobile-skills && \
ln -sf mobile-skills/skills/* .
```

### OpenCode

```bash
# Clone and link skills
mkdir -p ~/.opencode/skills && \
cd ~/.opencode/skills && \
git clone https://github.com/omixec/mobile-skills.git mobile-skills
```

### Cursor

```bash
# Clone and link skills
mkdir -p ~/.cursor/skills && \
cd ~/.cursor/skills && \
git clone https://github.com/omixec/mobile-skills.git mobile-skills
```

### Codex CLI

```bash
# Clone and link skills
mkdir -p ~/.codex/skills && \
cd ~/.codex/skills && \
git clone https://github.com/omixec/mobile-skills.git mobile-skills
```

## Detailed Installation

### Claude Code (macOS)

```bash
# Find Claude config directory
CLAUDE_CONFIG_DIR=$(find ~/Library/Application\ Support -name "Claude" -type d 2>/dev/null | head -1)

# Create skills directory
mkdir -p "$CLAUDE_CONFIG_DIR/Skills"

# Clone skills
git clone https://github.com/omixec/mobile-skills.git "$CLAUDE_CONFIG_DIR/Skills/mobile-skills"

# Link individual skills
cd "$CLAUDE_CONFIG_DIR/Skills"
for dir in mobile-skills/skills/*/; do
  skill_name=$(basename "$dir")
  ln -sf "$dir" "skill-$skill_name"
done
```

### OpenCode

```bash
# Create skills directory
mkdir -p ~/.opencode/skills

# Clone repository
git clone https://github.com/omixec/mobile-skills.git ~/.opencode/skills/mobile-skills

# Verify installation
ls ~/.opencode/skills/mobile-skills/skills/
```

### Cursor

```bash
# Create cursor extensions directory
mkdir -p ~/.cursor/extensions/skills

# Clone skills
git clone https://github.com/omixec/mobile-skills.git ~/.cursor/extensions/skills/mobile-skills
```

### Codex CLI

```bash
# Create codex skills directory
mkdir -p ~/.codex/skills

# Clone skills
git clone https://github.com/omixec/mobile-skills.git ~/.codex/skills/mobile-skills
```

## Curl Install Scripts

### One-liner for Claude Code
```bash
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-claude.sh | bash
```

### One-liner for OpenCode
```bash
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-opencode.sh | bash
```

### One-liner for Cursor
```bash
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-cursor.sh | bash
```

### One-liner for Codex
```bash
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-codex.sh | bash
```

## Verify Installation

After installation, test by asking your agent:

> "Create a simple Flutter app with a counter using Riverpod"

or

> "Convert this Swift code to Flutter"

## Skill Details

### ios-swift-development
- MVVM architecture with ObservableObject
- SwiftUI for declarative UI
- URLSession for networking
- Combine for reactive programming
- Core Data persistence

### flutter-development  
- Riverpod state management
- GoRouter navigation
- Dio HTTP client
- REST API integration
- Flutter Secure Storage

### refactor-swift-to-flutter
- SwiftUI to Flutter widget mapping
- Combine to Riverpod conversion
- URLSession to Dio migration
- Core Data to Hive/SQLite
- Complete code transformation

### flutter-sdk-to-swift
- Flutter widget to SwiftUI conversion
- Riverpod to Combine migration
- Dio to URLSession
- Hive to Core Data
- Complete Dart to Swift conversion

## Update Skills

```bash
# Navigate to skills directory
cd ~/Library/Application\ Support/Claude/Skills/mobile-skills  # Claude
# or
cd ~/.opencode/skills/mobile-skills  # OpenCode

# Pull latest
git pull origin main
```

## Troubleshooting

### Skill not loading
- Verify skill directory exists in correct location
- Check skill has `SKILL.md` file
- Restart the AI agent

### Skill triggers but doesn't work
- Check skill description is properly loaded
- Verify references directory exists if skill uses it
- Check for syntax errors in SKILL.md

## Contributing

To add new skills:
1. Create `skills/<skill-name>/SKILL.md`
2. Add YAML frontmatter with name and description
3. Add reference guides in `references/` subdirectory
4. Update this README with new skill

## License

MIT