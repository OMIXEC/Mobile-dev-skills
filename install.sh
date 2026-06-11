#!/bin/bash
# =============================================================================
# Mobile Development Skills — Unified Installer
# Supports: Claude Code, OpenCode, Codex CLI, Cursor
# Usage:
#   curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install.sh | bash
#   ./install.sh                          # auto-detect platform, install all
#   ./install.sh --interactive             # pick skills interactively
#   ./install.sh --platform claude         # force a specific platform
#   ./install.sh --list                    # show available skills
#   ./install.sh --project ./my-app        # install into a project directory
# =============================================================================

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Repository ───────────────────────────────────────────────────────────────
REPO_URL="https://github.com/omixec/mobile-skills.git"
REPO_NAME="mobile-skills"

# ── Platform detection ───────────────────────────────────────────────────────
detect_platform() {
    local detected=""
    if   [ -f "$HOME/Library/Application Support/Claude/config.json" ]; then detected="claude"
    elif [ -d "$HOME/.opencode" ]; then detected="opencode"
    elif [ -d "$HOME/.codex" ]; then detected="codex"
    elif [ -d "$HOME/.cursor" ]; then detected="cursor"
    fi

    if [ -z "$detected" ]; then
        echo -e "${YELLOW}Could not auto-detect platform. Checking PATH...${NC}"
        if   command -v claude  &>/dev/null; then detected="claude"
        elif command -v opencode &>/dev/null; then detected="opencode"
        elif command -v codex   &>/dev/null; then detected="codex"
        elif command -v cursor  &>/dev/null; then detected="cursor"
        fi
    fi

    if [ -z "$detected" ]; then
        echo -e "${RED}Could not detect platform. Use --platform <name>${NC}"
        echo "Valid: claude, opencode, codex, cursor"
        exit 1
    fi
    echo "$detected"
}

# ── Config paths per platform ────────────────────────────────────────────────
platform_global_dir() {
    case "$1" in
        claude)   echo "$HOME/Library/Application Support/Claude/Skills" ;;
        opencode) echo "$HOME/.opencode/skills" ;;
        codex)    echo "$HOME/.codex/skills" ;;
        cursor)   echo "$HOME/.cursor/extensions/skills" ;;
        *) echo -e "${RED}Unknown platform: $1${NC}" >&2; exit 1 ;;
    esac
}

platform_project_dir() {
    case "$1" in
        claude)   echo ".claude/skills" ;;
        opencode) echo ".opencode/skills" ;;
        codex)    echo ".codex/skills" ;;
        cursor)   echo ".cursor/skills" ;;
        *) echo -e "${RED}Unknown platform: $1${NC}" >&2; exit 1 ;;
    esac
}

# ── Skill discovery ──────────────────────────────────────────────────────────
list_skills() {
    find "$SKILLS_SOURCE" -maxdepth 1 -mindepth 1 -type d ! -name '.git' -exec basename {} \; | sort
}

get_skill_description() {
    local skill_dir="$SKILLS_SOURCE/$1"
    if [ -f "$skill_dir/SKILL.md" ]; then
        awk '/^---$/{f++;next} /^---$/{exit} f==1 && /^description:/{desc=1; sub(/^description:[[:space:]]*"?>[[:space:]]*|^description:[[:space:]]*"?/,""); gsub(/"$/,""); print; next} desc{f==2; exit}' "$skill_dir/SKILL.md" | tr -d '\n' | xargs
    fi
}

get_skill_name() {
    local skill_dir="$SKILLS_SOURCE/$1"
    if [ -f "$skill_dir/SKILL.md" ]; then
        sed -n '/^name:/s/^name:\s*//p' "$skill_dir/SKILL.md" 2>/dev/null \
            | tr -d '"' | tr -d "'" | xargs || basename "$skill_dir"
    else
        basename "$skill_dir"
    fi
}

# ── Install logic ────────────────────────────────────────────────────────────
clone_or_update() {
    local target_dir="$1"
    if [ -d "$target_dir/$REPO_NAME" ] && [ -d "$target_dir/$REPO_NAME/skills" ]; then
        echo -e "${YELLOW}Updating $REPO_NAME...${NC}"
        git -C "$target_dir/$REPO_NAME" pull --ff-only origin main 2>/dev/null \
            || echo -e "${YELLOW}Could not git pull, using current version${NC}"
    else
        echo -e "${YELLOW}Copying skills from local source...${NC}"
        mkdir -p "$target_dir/$REPO_NAME/skills"
        cp -R "$SCRIPT_DIR/skills"/* "$target_dir/$REPO_NAME/skills/"
        cp -R "$SCRIPT_DIR/scripts" "$target_dir/$REPO_NAME/" 2>/dev/null || true
        cp -R "$SCRIPT_DIR/hooks" "$target_dir/$REPO_NAME/" 2>/dev/null || true
        cp -R "$SCRIPT_DIR/references" "$target_dir/$REPO_NAME/" 2>/dev/null || true
        cp "$SCRIPT_DIR/LICENSE" "$target_dir/$REPO_NAME/" 2>/dev/null || true
        cp "$SCRIPT_DIR/README.md" "$target_dir/$REPO_NAME/" 2>/dev/null || true
        # Initialize git so future pulls work if the repo goes live
        git -C "$target_dir/$REPO_NAME" init -q 2>/dev/null || true
        git -C "$target_dir/$REPO_NAME" remote add origin "$REPO_URL" 2>/dev/null || true
    fi
}

link_skills() {
    local target_dir="$1"; shift
    local skills_to_link=("$@")
    mkdir -p "$target_dir"

    if [ ${#skills_to_link[@]} -eq 0 ]; then
        echo -e "${RED}No skills to link${NC}"
        return 1
    fi

    local linked=0 skipped=0
    for skill in "${skills_to_link[@]}"; do
        local src="$SKILLS_SOURCE/$skill"
        local link="$target_dir/$skill"

        # platform-specific link naming
        case "$PLATFORM" in
            claude) link="$target_dir/skill-$skill" ;;
        esac

        if [ ! -d "$src" ]; then
            echo -e "${RED}  - $skill (not found)${NC}"
            ((skipped++)) || true
            continue
        fi

        [ -L "$link" ] && rm "$link"
        [ -d "$link" ] && rm -rf "$link"
        ln -sf "$src" "$link"
        echo -e "${GREEN}  + $skill${NC}"
        ((linked++)) || true
    done

    echo ""
    echo -e "${GREEN}Linked $linked skills${NC}${skipped:+${RED}, skipped $skipped${NC}}"
}

# ── Interactive picker ───────────────────────────────────────────────────────
interactive_pick() {
    local -a skills
    while IFS= read -r line; do
        skills+=("$line")
    done < <(list_skills)

    local -a selected=()
    local choice

    echo -e "\n${CYAN}${BOLD}Available Skills:${NC}"
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    for i in "${!skills[@]}"; do
        printf "  ${GREEN}%2d)${NC} %s\n" "$((i+1))" "${skills[$i]}"
    done
    echo -e "  ${GREEN} 0)${NC} ${RED}Cancel${NC}"
    echo -e "${YELLOW}────────────────────────────────────────────────────────${NC}"
    echo ""
    echo "Enter numbers separated by spaces, or 'all':"
    read -r choice

    if [ "$choice" = "all" ]; then
        selected=("${skills[@]}")
    else
        for num in $choice; do
            idx=$((num - 1))
            if [ "$idx" -ge 0 ] 2>/dev/null && [ "$idx" -lt "${#skills[@]}" ]; then
                selected+=("${skills[$idx]}")
            fi
        done
    fi

    printf '%s\n' "${selected[@]}"
}

# ── Verification ─────────────────────────────────────────────────────────────
verify_links() {
    local target_dir="$1"
    local errors=0
    for link in "$target_dir"/*/; do
        if [ -L "${link%/}" ]; then
            local resolved
            resolved="$(readlink "${link%/}")"
            if [ ! -d "$resolved" ]; then
                echo -e "${RED}  Broken link: $link -> $resolved${NC}"
                ((errors++)) || true
            fi
        fi
    done
    return $errors
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
    local PLATFORM=""
    local INTERACTIVE=false
    local PROJECT_DIR=""
    local LIST_ONLY=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --platform)   PLATFORM="$2"; shift 2 ;;
            --interactive|-i) INTERACTIVE=true; shift ;;
            --project)    PROJECT_DIR="$2"; shift 2 ;;
            --list|-l)    LIST_ONLY=true; shift ;;
            --help|-h)
                echo "Usage: install.sh [options]"
                echo "  --platform <name>   Force platform (claude, opencode, codex, cursor)"
                echo "  --interactive, -i   Pick skills interactively"
                echo "  --project <dir>     Install into a project directory"
                echo "  --list, -l          List available skills and exit"
                exit 0
                ;;
            *) echo -e "${RED}Unknown flag: $1${NC}"; exit 1 ;;
        esac
    done

    # Determine script source location
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -d "$SCRIPT_DIR/skills" ]; then
        SKILLS_SOURCE="$SCRIPT_DIR/skills"
    else
        local tmp
        tmp="$(mktemp -d)"
        echo -e "${YELLOW}Fetching skills repository...${NC}"
        git clone --depth 1 "$REPO_URL" "$tmp/$REPO_NAME" 2>/dev/null || {
            echo -e "${RED}Failed to clone repository${NC}"
            exit 1
        }
        SKILLS_SOURCE="$tmp/$REPO_NAME/skills"
    fi

    # Auto-detect platform if not specified
    [ -z "$PLATFORM" ] && PLATFORM="$(detect_platform)"

    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  Mobile Skills Installer  ·  Platform: $PLATFORM${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # List mode
    if $LIST_ONLY; then
        echo -e "${BOLD}Available skills:${NC}"
        for skill in $(list_skills); do
            local desc
            desc="$(get_skill_description "$skill")"
            printf "  ${GREEN}%-35s${NC} %s\n" "$skill" "$desc"
        done
        exit 0
    fi

    # Determine target directory
    local TARGET_DIR
    if [ -n "$PROJECT_DIR" ]; then
        TARGET_DIR="$PROJECT_DIR/$(platform_project_dir "$PLATFORM")"
    else
        echo -e "${YELLOW}Install location:${NC}"
        echo "  1) Global (all projects)"
        echo "  2) Project (current directory)"
        read -r -p "Choose [1]: " loc_choice
        loc_choice="${loc_choice:-1}"

        if [ "$loc_choice" = "2" ]; then
            TARGET_DIR="$(pwd)/$(platform_project_dir "$PLATFORM")"
        else
            TARGET_DIR="$(platform_global_dir "$PLATFORM")"
        fi
    fi

    # Clone/pull the repo
    clone_or_update "$TARGET_DIR"
    SKILLS_SOURCE="$TARGET_DIR/$REPO_NAME/skills"

    # Pick skills
    local -a SKILLS
    if $INTERACTIVE; then
        while IFS= read -r line; do SKILLS+=("$line"); done < <(interactive_pick)
    else
        while IFS= read -r line; do SKILLS+=("$line"); done < <(list_skills)
    fi

    [ ${#SKILLS[@]} -eq 0 ] && { echo -e "${RED}No skills selected.${NC}"; exit 0; }

    # Link skills
    link_skills "$TARGET_DIR" "${SKILLS[@]}"

    # Verify
    echo ""
    echo -e "${YELLOW}Verifying installation...${NC}"
    verify_links "$TARGET_DIR" || true

    # Summary
    echo -e "\n${GREEN}${BOLD}Done!${NC}"
    echo -e "Skills installed in: ${CYAN}$TARGET_DIR${NC}"
    echo -e "Restart your AI agent to start using them."
}

main "$@"
