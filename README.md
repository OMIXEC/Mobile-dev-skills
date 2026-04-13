# Mobile Development Skills

Curated skills for building native and cross-platform mobile applications with AI coding agents.

---

## Table of Contents

- [Available Skills](#available-skills)
- [Quick Install](#quick-install)
- [Platform-Specific Skills](#platform-specific-skills)
  - [iOS/Swift](#iosswift)
  - [Flutter/Dart](#flutterdart)
  - [Android/Kotlin](#androidkotlin)
  - [Cross-Platform](#cross-platform)
- [Code Conversion Skills](#code-conversion-skills)
- [Development Workflow Skills](#development-workflow-skills)
- [Platform Decision Guide](#platform-decision-guide)
- [Detailed Installation](#detailed-installation)
- [Skill Usage](#skill-usage)

---

## Available Skills

| Skill | Description |
|-------|-------------|
| `ios-swift-development` | Native iOS with Swift, SwiftUI, Combine, MVVM |
| `flutter-development` | Cross-platform Flutter with Riverpod, GoRouter, Dio |
| `mobile-development` | Full mobile development guide (iOS, Android, Flutter, Games) |
| `refactor-swift-to-flutter` | Convert Swift code to Flutter/Dart |
| `flutter-sdk-to-swift` | Convert Flutter/Dart code to Swift/iOS |

---

## Quick Install

### One-Command Install

```bash
# Claude Code
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-claude.sh | bash

# OpenCode
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-opencode.sh | bash

# Cursor
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-cursor.sh | bash

# Codex CLI
curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-codex.sh | bash
```

---

## Platform-Specific Skills

### iOS/Swift

**Skill:** `ios-swift-development`

Build native iOS applications with Apple's modern frameworks.

```
When to use:
- Creating iOS-only apps with optimal performance
- Using SwiftUI for declarative UI
- Implementing Combine for reactive programming
- Working with Core Data persistence
- Building MVVM architecture
```

**Stack (2025):**
- Swift 5.10+
- SwiftUI
- SwiftData / Core Data
- Combine
- Xcode 16

**Reference Guides:**
- `references/mvvm-architecture-setup.md` - MVVM patterns
- `references/network-service-with-urlsession.md` - Networking
- `references/swiftui-views.md` - SwiftUI components

**Example Usage:**
```
> "Create a SwiftUI view that fetches user data from an API and displays it in a list"
> "Set up a Combine publisher to handle API responses"
> "Implement MVVM with SwiftData for a todo app"
```

---

### Flutter/Dart

**Skill:** `flutter-development`

Build cross-platform iOS and Android apps from a single codebase.

```
When to use:
- Building for both iOS and Android simultaneously
- Creating smooth 60fps animations
- Working with Firebase integration
- Using Riverpod for state management
- Implementing GoRouter navigation
```

**Stack (2025):**
- Flutter 3.x
- Dart 3.x
- Riverpod
- GoRouter
- Dio
- Firebase

**Reference Guides:**
- `references/riverpod-state-management.md` - State management
- `references/gorouter-navigation.md` - Navigation patterns
- `references/rest-api-integration.md` - HTTP client setup

**Example Usage:**
```
> "Create a Flutter counter app with Riverpod"
> "Set up GoRouter with authentication flow"
> "Build a REST API service with Dio and error handling"
```

---

### Android/Kotlin

**Skill:** `mobile-development` (includes Android path)

Native Android development with Jetpack Compose.

**Stack (2025):**
- Kotlin 2.0
- Jetpack Compose
- Room
- Hilt
- Coroutines + Flow

**Learning Path:**
```
[1] Kotlin Fundamentals (4-6 wk)
    └─ Null safety, coroutines, data classes

[2] Jetpack Compose (4-6 wk)
    └─ Composables, state, effects

[3] Architecture (3-4 wk)
    └─ MVVM, Room, Navigation

[4] Networking + DI (2-3 wk)
    └─ Retrofit, Hilt, Flow

[5] Testing + Play Store (2 wk)
    └─ JUnit, Espresso, release
```

---

### Cross-Platform

**Comparison:**

| Framework | Language | Performance | Learning Curve | Best For |
|-----------|----------|-------------|----------------|----------|
| **Flutter** | Dart | Excellent | Medium | UI-heavy apps |
| **React Native** | JavaScript | Good | Easy | JS teams |
| **MAUI** | C# | Good | Medium | .NET teams |

**Recommendation:**
- Single codebase needed → **Flutter** (best DX)
- Web/JS background → **React Native**
- Enterprise/.NET → **MAUI**

---

## Code Conversion Skills

### Swift → Flutter

**Skill:** `refactor-swift-to-flutter`

Convert existing Swift/iOS codebases to Flutter.

```
When to use:
- Porting iOS app to Android
- "Convert this Swift code to Flutter"
- "Migrate Swift to Dart"
- "Rewrite in Flutter"
```

**Mapping Reference:**

| Swift | Flutter |
|-------|---------|
| `@State` | `useState` / `StatefulWidget` |
| `@ObservedObject` | `ConsumerWidget` / `ref.watch` |
| `Combine` | `Riverpod` |
| `SwiftUI` | Flutter widgets |
| `URLSession` | `Dio` |
| `Core Data` | `Hive` / `SQLite` |

**Example Usage:**
```
> "Convert this Swift ViewModel to Riverpod"
> "Transform this SwiftUI view to Flutter"
> "Convert Core Data models to Hive"
```

---

### Flutter → Swift

**Skill:** `flutter-sdk-to-swift`

Convert Flutter/Dart codebases to native iOS Swift.

```
When to use:
- Porting Flutter app to iOS
- "Convert Flutter to Swift"
- "Migrate Dart to Swift"
- "Rewrite in Swift"
```

**Mapping Reference:**

| Flutter | Swift |
|---------|-------|
| `Riverpod` | `Combine` |
| `GoRouter` | `NavigationStack` |
| `Dio` | `URLSession` |
| `Hive` | `Core Data` |
| `freezed` | `Codable` |

**Example Usage:**
```
> "Convert this Riverpod provider to Combine"
> "Transform Flutter widgets to SwiftUI"
> "Convert Hive models to Core Data"
```

---

## Development Workflow Skills

### Testing

**Skill:** `e2e-testing-patterns`

End-to-end testing for mobile apps.

**Coverage:**
- iOS: XCTest, UI Testing
- Android: Espresso, Compose Testing
- Flutter: Integration testing
- Cross-platform: Appium

### Design

**Skills:**
- `high-end-visual-design` - Premium UI patterns
- `liquid-glass-design` - Glassmorphism effects
- `design-taste-frontend` - Design principles

---

## Platform Decision Guide

### Which Platform to Choose?

```
Need both iOS and Android?
├─► Yes + performance critical → Native (Swift + Kotlin)
├─► Yes + budget limited → Flutter
└─► Yes + JS team → React Native

iOS only?
└─► Swift + SwiftUI

Android only?
└─► Kotlin + Jetpack Compose

Making games?
├─► 2D indie → Unity or Godot
└─► 3D/AAA → Unreal
```

### Game Engine Comparison

| Engine | Market Share | Language | Learning Curve |
|--------|-------------|----------|----------------|
| **Unity** | 51% | C# | Medium |
| **Unreal** | 31% | C++/BP | Hard |
| **Godot** | 10% | GDScript | Easy |

---

## Detailed Installation

### Claude Code

```bash
# Find config directory
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"

# Create and clone
mkdir -p "$CLAUDE_CONFIG_DIR/Skills"
git clone https://github.com/omixec/mobile-skills.git "$CLAUDE_CONFIG_DIR/Skills/mobile-skills"

# Link skills
cd "$CLAUDE_CONFIG_DIR/Skills"
for dir in mobile-skills/skills/*/; do
  ln -sf "$dir" "skill-$(basename "$dir")"
done
```

### OpenCode

```bash
mkdir -p ~/.opencode/skills
git clone https://github.com/omixec/mobile-skills.git ~/.opencode/skills/mobile-skills
```

### Cursor

```bash
mkdir -p ~/.cursor/extensions/skills
git clone https://github.com/omixec/mobile-skills.git ~/.cursor/extensions/skills/mobile-skills
```

### Codex CLI

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/omixec/mobile-skills.git ~/.codex/skills/mobile-skills
```

---

## Skill Usage

### Trigger the Right Skill

Skills auto-activate based on keywords in your prompt:

```
# iOS Development
"Create a SwiftUI login screen"
"Implement Combine publisher for API calls"

# Flutter Development
"Build a counter app with Riverpod"
"Set up GoRouter navigation"

# Code Conversion
"Convert this Swift code to Flutter"
"Transform this Flutter widget to SwiftUI"
```

### Manual Skill Activation

If needed, explicitly reference the skill:

```
Use the ios-swift-development skill to build this.
Use the flutter-development skill for the UI.
Use refactor-swift-to-flutter to convert this code.
```

---

## Troubleshooting

### Skill Not Loading

1. Verify skill directory exists in correct location
2. Check skill has `SKILL.md` file
3. Restart the AI agent

### Skill Triggers but Doesn't Work

1. Check skill description is properly loaded
2. Verify references directory exists
3. Check for syntax errors in SKILL.md

---

## Update Skills

```bash
# Navigate to skills directory
cd ~/Library/Application\ Support/Claude/Skills/mobile-skills

# Pull latest
git pull origin main
```

---

## Contributing

To add new mobile skills:

1. Create `skills/<skill-name>/SKILL.md`
2. Add YAML frontmatter with name and description
3. Add reference guides in `references/` subdirectory
4. Update this README

---

## License

MIT