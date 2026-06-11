#!/usr/bin/env bash
# =============================================================================
# test-mobile.sh — Adaptive Test Runner for Mobile Projects
#
# Auto-detects the project type (iOS, Flutter, Android) and runs the correct
# test framework. Call this from hooks or manually to validate a mobile project.
#
# Usage:
#   scripts/test-mobile.sh [--platform ios|flutter|android] [--watch] [dir]
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

TARGET_DIR="${PWD}"
WATCH_MODE=false
FORCE_PLATFORM=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --platform) FORCE_PLATFORM="$2"; shift 2 ;;
        --watch|-w) WATCH_MODE=true; shift ;;
        --help|-h)
            echo "Usage: test-mobile.sh [--platform ios|flutter|android] [--watch] [dir]"
            exit 0 ;;
        *) TARGET_DIR="$1"; shift ;;
    esac
done

detect_platform() {
    local dir="$1"

    # Explicit override
    if [ -n "$FORCE_PLATFORM" ]; then
        echo "$FORCE_PLATFORM"
        return
    fi

    # Flutter
    if [ -f "$dir/pubspec.yaml" ] && grep -q "flutter" "$dir/pubspec.yaml" 2>/dev/null; then
        echo "flutter"; return
    fi

    # iOS
    if [ -f "$dir"/*.xcodeproj/project.pbxproj ] 2>/dev/null || \
       [ -f "$dir"/*.xcworkspace/contents.xcworkspacedata ] 2>/dev/null || \
       ls "$dir"/*.swift >/dev/null 2>&1; then
        echo "ios"; return
    fi

    # Android
    if [ -f "$dir/build.gradle" ] 2>/dev/null || \
       [ -f "$dir/build.gradle.kts" ] 2>/dev/null || \
       ls "$dir"/*.kt >/dev/null 2>&1; then
        echo "android"; return
    fi

    echo ""
}

run_ios_tests() {
    local dir="$1"

    # Find .xcodeproj or .xcworkspace
    local project_file
    project_file=$(find "$dir" -maxdepth 2 -name "*.xcworkspace" -o -name "*.xcodeproj" 2>/dev/null | head -1)

    if [ -z "$project_file" ]; then
        echo -e "${YELLOW}No Xcode project found in $dir${NC}"
        echo "Running swift test..."
        if command -v swift &>/dev/null; then
            swift test 2>&1
        else
            echo -e "${RED}Swift not installed${NC}"
            return 1
        fi
        return $?
    fi

    echo -e "${GREEN}iOS project detected: $project_file${NC}"

    local scheme
    scheme=$(xcodebuild -list -project "$project_file" 2>/dev/null | \
        awk '/Schemes:/{found=1; next} found && /^[[:space:]]/{gsub(/^[[:space:]]+/,""); if(NF) print; else exit}' | head -1)

    if [ -z "$scheme" ]; then
        echo -e "${YELLOW}Could not determine scheme, using default${NC}"
        scheme="$(basename "$project_file" .xcodeproj)_Tests" 2>/dev/null || true
    fi

    echo -e "Running: xcodebuild test -project \"$project_file\" -scheme \"$scheme\" -destination 'platform=iOS Simulator,name=iPhone 16'"

    xcodebuild test \
        -project "$project_file" \
        -scheme "$scheme" \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        2>&1 | tail -20
}

run_flutter_tests() {
    local dir="$1"

    if ! command -v flutter &>/dev/null; then
        echo -e "${RED}Flutter SDK not found${NC}"
        return 1
    fi

    echo -e "${GREEN}Flutter project detected${NC}"

    cd "$dir"

    echo -e "${YELLOW}Running flutter analyze...${NC}"
    flutter analyze 2>&1 | tail -10 || true

    echo ""
    echo -e "${YELLOW}Running flutter test...${NC}"
    if $WATCH_MODE; then
        flutter test --watch 2>&1
    else
        flutter test --reporter expanded 2>&1
    fi
}

run_android_tests() {
    local dir="$1"

    if ! command -v ./gradlew &>/dev/null && ! [ -f "$dir/gradlew" ]; then
        echo -e "${RED}No gradlew found${NC}"
        return 1
    fi

    echo -e "${GREEN}Android project detected${NC}"

    cd "$dir"

    echo -e "${YELLOW}Running lint...${NC}"
    ./gradlew lint 2>&1 | tail -10 || true
    echo ""

    echo -e "${YELLOW}Running unit tests...${NC}"
    ./gradlew test 2>&1 | tail -20
}

# ── Main ─────────────────────────────────────────────────────────────────────
PLATFORM=$(detect_platform "$TARGET_DIR")

if [ -z "$PLATFORM" ]; then
    echo -e "${YELLOW}Could not detect mobile platform.${NC}"
    echo "Try --platform ios|flutter|android or run from a mobile project root."
    exit 1
fi

echo -e "Platform: ${CYAN}$PLATFORM${NC}"
echo -e "Directory: ${CYAN}$TARGET_DIR${NC}"
echo ""

case "$PLATFORM" in
    ios)     run_ios_tests "$TARGET_DIR" ;;
    flutter) run_flutter_tests "$TARGET_DIR" ;;
    android) run_android_tests "$TARGET_DIR" ;;
    *) echo -e "${RED}Unsupported platform: $PLATFORM${NC}"; exit 1 ;;
esac

EXIT_CODE=$?
echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Test run completed with failures.${NC}"
fi
exit $EXIT_CODE
