# PreToolUse Hook — Run Tests Before Applying Changes

This directory contains reusable hook patterns for mobile development skills.

## Available Hooks

### `pre-tool-use-run-tests` — Run Project Tests Before Any Write

Prevents code edits from being applied to a broken project. When a mobile project is detected (iOS, Flutter, or Android), this hook runs the adaptive test runner before any Write/Bash/edit operation.

**How to use:**

Add to your agent's hook configuration or include in the SKILL.md instructions:

```
Before making any code changes to this project, first run:
  bash scripts/test-mobile.sh

If tests fail, report the failures to the user and do NOT proceed with the change
until the failures are resolved or the user explicitly asks to proceed.
```

### `post-tool-use-verify-build` — Verify Build After Changes

After applying code changes, verify that the project still compiles/passes lint.

**For iOS:**
```
After making changes, verify builds pass:
  xcodebuild -project *.xcodeproj -scheme <scheme> -sdk iphonesimulator build 2>&1 | tail -10
```

**For Flutter:**
```
After making changes, verify builds pass:
  flutter analyze --no-fatal-infos
  flutter build ios --no-codesign 2>&1 | tail -5
```

**For Android:**
```
After making changes, verify builds pass:
  ./gradlew assembleDebug 2>&1 | tail -10
```
