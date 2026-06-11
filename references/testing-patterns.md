# Shared Testing Reference for Mobile Development

## Test Framework by Platform

| Platform | Unit Tests | UI Tests | E2E Tests |
|----------|-----------|----------|-----------|
| **iOS** | XCTest | XCUITest | Maestro, Appium |
| **Flutter** | flutter_test | widget_test | integration_test |
| **Android** | JUnit, Robolectric | Espresso, Compose Test | Maestro, Appium |
| **React Native** | Jest | React Native Testing Library | Detox, Maestro |

## Running Tests Automatically

Use the adaptive test runner:

```bash
# Auto-detect platform and run tests
bash scripts/test-mobile.sh

# Force a specific platform
bash scripts/test-mobile.sh --platform flutter

# With watch mode (flutter only)
bash scripts/test-mobile.sh --platform flutter --watch
```

## Test Best Practices

### iOS (XCTest)
- Use `XCTAssert` family for assertions
- Test view models separately from views
- Use `MainActor.run` for async UI tests
- Keep test methods focused on one behavior

### Flutter
- Put widget tests in `test/` with `_test.dart` suffix
- Use `pumpWidget` to render test widgets
- Use `mocktail` or `mockito` for mocking
- Integration tests go in `integration_test/`

### Android
- Unit tests: `src/test/java/` (JUnit, Robolectric)
- Instrumentation tests: `src/androidTest/java/` (Espresso)
- Use `@HiltAndroidTest` for DI in tests
- UIAutomator for cross-app testing

## Test Hooks Integration

When using with the hooks system, add to your project:

```yaml
# .codex/hooks/pre_tool_use/run_tests.yaml
hooks:
  - name: run-project-tests
    on: PreToolUse
    tools: [Write, Bash, Edit]
    command: bash scripts/test-mobile.sh
```

Or instruct the agent in SKILL.md to always verify before/after changes.
