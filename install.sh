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
    if   [ -f "$HOME/Library/Application Support/Claude/config.json" ] || [ -d "$HOME/Library/Application Support/Claude/Skills" ]; then detected="claude"
    elif [ -d "$HOME/.opencode" ]; then detected="opencode"
    elif [ -d "$HOME/.codex" ]; then detected="codex"
    elif [ -d "$HOME/.cursor" ]; then detected="cursor"
    fi

    if [ -z "$detected" ]; then
        if   command -v claude  &>/dev/null; then detected="claude"
        elif command -v opencode &>/dev/null; then detected="opencode"
        elif command -v codex   &>/dev/null; then detected="codex"
        elif command -v cursor  &>/dev/null; then detected="cursor"
        fi
    fi

    if [ -z "$detected" ]; then
        # Default to claude if we can't detect but are on macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            detected="claude"
        else
            echo -e "${RED}Could not detect platform. Use --platform <name>${NC}"
            echo "Valid: claude, opencode, codex, cursor"
            exit 1
        fi
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
    local skill_file="$SKILLS_SOURCE/$1/SKILL.md"
    if [ -f "$skill_file" ]; then
        # Use python if available for robust YAML parsing, otherwise fallback to simple grep
        if command -v python3 &>/dev/null; then
            python3 -c "
import sys, re
try:
    content = open('$skill_file').read()
    # Find the YAML frontmatter block
    fm_match = re.search(r'^---\n(.*?)\n---', content, re.MULTILINE | re.DOTALL)
    if fm_match:
        fm = fm_match.group(1)
        # Extract description value (handles folded/literal scalars and quotes)
        desc_match = re.search(r'^description:\s*(?:>|\|)?\s*(.*?)(?:\n[a-z]|$)', fm, re.MULTILINE | re.DOTALL)
        if desc_match:
            desc = desc_match.group(1).strip().replace('\n', ' ')
            desc = re.sub(r'\s+', ' ', desc)
            print(desc[:120] + ('...' if len(desc) > 120 else ''))
except:
    pass
" 2>/dev/null
        else
            grep "^description:" "$skill_file" | sed 's/^description:[[:space:]]*//;s/[">|]//g' | cut -c 1-120
        fi
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
    local local_repo_dir
    # Determine script source location robustly
    local_repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # If we're already in a cloned repo, we can use it
    if [ -d "$local_repo_dir/skills" ]; then
        SRC_DIR="$local_repo_dir"
        if [ "$USE_LINK" = true ]; then
            echo -e "${YELLOW}Linking skills source from $SRC_DIR...${NC}"
            mkdir -p "$target_dir"
            [ -L "$target_dir/$REPO_NAME" ] && rm "$target_dir/$REPO_NAME"
            [ -d "$target_dir/$REPO_NAME" ] && rm -rf "$target_dir/$REPO_NAME"
            ln -sf "$SRC_DIR" "$target_dir/$REPO_NAME"
            SKILLS_SOURCE="$target_dir/$REPO_NAME/skills"
            return
        fi
    else
        # Otherwise we need a clone (likely run via curl)
        local tmp
        tmp="$(mktemp -d)"
        echo -e "${YELLOW}Fetching skills repository...${NC}"
        git clone --depth 1 "$REPO_URL" "$tmp/$REPO_NAME" &>/dev/null || {
            echo -e "${RED}Failed to clone repository. Is git installed?${NC}"
            exit 1
        }
        SRC_DIR="$tmp/$REPO_NAME"
    fi

    if [ -d "$target_dir/$REPO_NAME" ] && [ ! -L "$target_dir/$REPO_NAME" ]; then
        echo -e "${YELLOW}Updating $REPO_NAME in $target_dir...${NC}"
        if [ -d "$target_dir/$REPO_NAME/.git" ]; then
            git -C "$target_dir/$REPO_NAME" pull --ff-only origin main 2>/dev/null \
                || echo -e "${YELLOW}Could not git pull, using current version${NC}"
        else
            cp -R "$SRC_DIR"/* "$target_dir/$REPO_NAME/"
        fi
    else
        echo -e "${YELLOW}Installing skills source to $target_dir/$REPO_NAME...${NC}"
        mkdir -p "$target_dir"
        [ -L "$target_dir/$REPO_NAME" ] && rm "$target_dir/$REPO_NAME"
        [ -d "$target_dir/$REPO_NAME" ] && rm -rf "$target_dir/$REPO_NAME"
        cp -R "$SRC_DIR" "$target_dir/$REPO_NAME"
    fi
    
    SKILLS_SOURCE="$target_dir/$REPO_NAME/skills"
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
            echo -e "${RED}  - $skill (not found in $SKILLS_SOURCE)${NC}"
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

    if [ "$choice" = "all" ] || [ -z "$choice" ]; then
        selected=("${skills[@]}")
    else
        for num in $choice; do
            idx=$((num - 1))
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$idx" -ge 0 ] && [ "$idx" -lt "${#skills[@]}" ]; then
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
    # Use find to avoid glob expansion issues if dir is empty
    find "$target_dir" -maxdepth 1 -type l | while read -r link; do
        local resolved
        resolved="$(readlink "$link")"
        if [ ! -d "$resolved" ]; then
            echo -e "${RED}  Broken link: $link -> $resolved${NC}"
            ((errors++)) || true
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
    local GLOBAL=false
    local USE_LINK=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --platform)   PLATFORM="$2"; shift 2 ;;
            --interactive|-i) INTERACTIVE=true; shift ;;
            --project)    PROJECT_DIR="$2"; shift 2 ;;
            --global|-g)  GLOBAL=true; shift ;;
            --link)       USE_LINK=true; shift ;;
            --list|-l)    LIST_ONLY=true; shift ;;
            --help|-h)
                echo "Usage: install.sh [options]"
                echo "  --global, -g        Install globally (default if no flags and no prompt)"
                echo "  --project <dir>     Install into a project directory"
                echo "  --link              Symlink source instead of copying (developers only)"
                echo "  --interactive, -i   Pick skills interactively"
                echo "  --platform <name>   Force platform (claude, opencode, codex, cursor)"
                echo "  --list, -l          List available skills and exit"
                exit 0
                ;;
            *) echo -e "${RED}Unknown flag: $1${NC}"; exit 1 ;;
        esac
    done

    # Determine initial SKILLS_SOURCE for listing and picking
    local SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ -d "$SCRIPT_DIR/skills" ]; then
        SKILLS_SOURCE="$SCRIPT_DIR/skills"
    else
        # Temporary source for discovery
        local tmp_src
        tmp_src="$(mktemp -d)"
        git clone --depth 1 "$REPO_URL" "$tmp_src/$REPO_NAME" &>/dev/null
        SKILLS_SOURCE="$tmp_src/$REPO_NAME/skills"
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
    elif $GLOBAL; then
        TARGET_DIR="$(platform_global_dir "$PLATFORM")"
    else
        # If not specified, check if we're in an interactive terminal
        if [ -t 0 ]; then
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
        else
            # Non-interactive: default to global
            echo -e "${YELLOW}Non-interactive session detected. Defaulting to Global install.${NC}"
            TARGET_DIR="$(platform_global_dir "$PLATFORM")"
        fi
    fi

    # Clone/pull/copy the repo to its permanent home in the target dir
    clone_or_update "$(dirname "$TARGET_DIR")"
    
    # After clone_or_update, SKILLS_SOURCE points to the permanent location
    # but we need to ensure it's absolute
    SKILLS_SOURCE="$(cd "$SKILLS_SOURCE" && pwd)"

    # Pick skills
    local -a SKILLS
    if $INTERACTIVE; then
        # interactive_pick returns list of skills
        IFS=$'\n' read -d '' -r -a SKILLS < <(interactive_pick) || true
    else
        # Default: all skills
        while IFS= read -r line; do SKILLS+=("$line"); done < <(list_skills)
    fi

    [ ${#SKILLS[@]} -eq 0 ] && { echo -e "${RED}No skills selected.${NC}"; exit 0; }

    # Link skills into the target directory
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
