#!/bin/bash
# Interactive install script for Claude Code
# Usage: curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-claude.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Find Claude config directory
find_claude_dir() {
    if [ -d "$HOME/Library/Application Support/Claude" ]; then
        echo "$HOME/Library/Application Support/Claude"
    elif [ -d "$HOME/.config/Claude" ]; then
        echo "$HOME/.config/Claude"
    fi
}

print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║          Mobile Skills Installer - Claude Code          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_menu() {
    echo -e "${YELLOW}┌─ Installation Type${NC}"
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│  1) ${GREEN}Global${NC}   - Install for all projects (default)"
    echo -e "${YELLOW}│  2) ${GREEN}Project${NC}  - Install for current directory only"
    echo -e "${YELLOW}│  3) ${GREEN}Custom${NC}  - Choose specific skills to install"
    echo -e "${YELLOW}│  0) ${RED}Exit${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────────────────────${NC}"
    echo
}

print_skill_menu() {
    echo -e "${YELLOW}┌─ Available Skills (select to install)${NC}"
    echo -e "${YELLOW}│${NC}"
    local i=1
    for skill in "$SCRIPT_DIR/skills"/*/; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            echo -e "${YELLOW}│  $i) ${GREEN}$skill_name${NC}"
            ((i++))
        fi
    done
    echo -e "${YELLOW}│${NC}"
    echo -e "${YELLOW}│  a) ${GREEN}All skills${NC}"
    echo -e "${YELLOW}│  0) ${RED}Back${NC}"
    echo -e "${YELLOW}└──────────────────────────────────────────────────────────${NC}"
    echo
}

get_skill_list() {
    local skills=()
    for skill in "$SCRIPT_DIR/skills"/*/; do
        if [ -d "$skill" ]; then
            skills+=("$(basename "$skill")")
        fi
    done
    echo "${skills[@]}"
}

install_global() {
    local claude_dir=$(find_claude_dir)
    if [ -z "$claude_dir" ]; then
        echo -e "${RED}Error: Could not find Claude config directory${NC}"
        exit 1
    fi

    local skills_dir="$claude_dir/Skills"
    mkdir -p "$skills_dir"

    if [ -d "$skills_dir/mobile-skills" ]; then
        echo -e "${YELLOW}Updating existing mobile-skills...${NC}"
        cd "$skills_dir/mobile-skills"
        git pull origin main 2>/dev/null || echo -e "${YELLOW}Could not pull, using existing version${NC}"
    else
        echo -e "${YELLOW}Cloning mobile-skills...${NC}"
        git clone https://github.com/omixec/mobile-skills.git "$skills_dir/mobile-skills"
    fi

    cd "$skills_dir"
    for dir in mobile-skills/skills/*/; do
        if [ -d "$dir" ]; then
            skill_name=$(basename "$dir")
            link_name="skill-$skill_name"
            if [ -L "$link_name" ]; then
                rm "$link_name"
            fi
            ln -sf "$dir" "$link_name"
            echo -e "${GREEN}✓${NC} Linked: $skill_name"
        fi
    done

    echo
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${YELLOW}Restart Claude to use the new skills.${NC}"
}

install_project() {
    local project_dir=$(pwd)
    local project_skills_dir="$project_dir/.claude/skills"

    mkdir -p "$project_skills_dir"

    if [ -d "$project_skills_dir/mobile-skills" ]; then
        echo -e "${YELLOW}Updating existing mobile-skills...${NC}"
        cd "$project_skills_dir/mobile-skills"
        git pull origin main 2>/dev/null || echo -e "${YELLOW}Could not pull, using existing version${NC}"
    else
        echo -e "${YELLOW}Cloning mobile-skills...${NC}"
        git clone https://github.com/omixec/mobile-skills.git "$project_skills_dir/mobile-skills"
    fi

    cd "$project_skills_dir"
    for dir in mobile-skills/skills/*/; do
        if [ -d "$dir" ]; then
            skill_name=$(basename "$dir")
            link_name="skill-$skill_name"
            if [ -L "$link_name" ]; then
                rm "$link_name"
            fi
            ln -sf "$dir" "$link_name"
            echo -e "${GREEN}✓${NC} Linked: $skill_name"
        fi
    done

    echo
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${YELLOW}Skills installed in: $project_skills_dir${NC}"
}

install_custom() {
    local selected_skills=()
    
    while true; do
        echo -e "\n${CYAN}Select skills to install:${NC}"
        echo -e "${YELLOW}┌──────────────────────────────────────────────────────────┐${NC}"
        echo -e "${YELLOW}│  Current selection: ${selected_skills[*]:-none}          │${NC}"
        echo -e "${YELLOW}└──────────────────────────────────────────────────────────┘${NC}"
        echo
        echo -e "${YELLOW}  1) ${GREEN}ios-swift-development${NC}"
        echo -e "${YELLOW}  2) ${GREEN}flutter-development${NC}"
        echo -e "${YELLOW}  3) ${GREEN}mobile-development${NC}"
        echo -e "${YELLOW}  4) ${GREEN}app-store-preflight${NC}"
        echo -e "${YELLOW}  5) ${GREEN}clean-architecture${NC}"
        echo -e "${YELLOW}  6) ${GREEN}systematic-debugging${NC}"
        echo -e "${YELLOW}  7) ${GREEN}devops-engineer${NC}"
        echo -e "${YELLOW}  8) ${GREEN}frontend-design${NC}"
        echo -e "${YELLOW}  9) ${GREEN}all-above${NC}"
        echo -e "${YELLOW} 10) ${GREEN}all-skills${NC}"
        echo -e "${YELLOW}  0) ${RED}Done / Back${NC}"
        echo

        read -p "Select option: " choice

        case $choice in
            1) selected_skills+=("ios-swift-development") ;;
            2) selected_skills+=("flutter-development") ;;
            3) selected_skills+=("mobile-development") ;;
            4) selected_skills+=("app-store-preflight") ;;
            5) selected_skills+=("clean-architecture") ;;
            6) selected_skills+=("systematic-debugging") ;;
            7) selected_skills+=("devops-engineer") ;;
            8) selected_skills+=("frontend-design") ;;
            9) 
                selected_skills+=("ios-swift-development" "flutter-development" "mobile-development" "app-store-preflight" "clean-architecture" "systematic-debugging" "devops-engineer" "frontend-design")
                ;;
            10)
                for skill in "$SCRIPT_DIR/skills"/*/; do
                    [ -d "$skill" ] && selected_skills+=("$(basename "$skill")")
                done
                ;;
            0) break ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
    done

    if [ ${#selected_skills[@]} -eq 0 ]; then
        echo -e "${RED}No skills selected. Exiting.${NC}"
        exit 0
    fi

    # Remove duplicates
    selected_skills=($(printf '%s\n' "${selected_skills[@]}" | sort -u))

    echo -e "\n${YELLOW}Installing to global or project?${NC}"
    echo "  1) Global"
    echo "  2) Project (current directory)"
    read -p "Choice [1]: " install_type
    install_type=${install_type:-1}

    if [ "$install_type" = "1" ]; then
        install_to_global_skills "${selected_skills[@]}"
    else
        install_to_project_skills "${selected_skills[@]}"
    fi
}

install_to_global_skills() {
    local skills=("$@")
    local claude_dir=$(find_claude_dir)
    
    if [ -z "$claude_dir" ]; then
        echo -e "${RED}Error: Could not find Claude config directory${NC}"
        exit 1
    fi

    local skills_dir="$claude_dir/Skills"
    mkdir -p "$skills_dir"

    if [ ! -d "$skills_dir/mobile-skills" ]; then
        echo -e "${YELLOW}Cloning mobile-skills...${NC}"
        git clone https://github.com/omixec/mobile-skills.git "$skills_dir/mobile-skills"
    fi

    cd "$skills_dir"
    for skill_name in "${skills[@]}"; do
        skill_path="$skills_dir/mobile-skills/skills/$skill_name"
        if [ -d "$skill_path" ]; then
            link_name="skill-$skill_name"
            [ -L "$link_name" ] && rm "$link_name"
            ln -sf "$skill_path" "$link_name"
            echo -e "${GREEN}✓${NC} Linked: $skill_name"
        else
            echo -e "${RED}✗${NC} Not found: $skill_name"
        fi
    done

    echo
    echo -e "${GREEN}Installation complete!${NC}"
}

install_to_project_skills() {
    local skills=("$@")
    local project_dir=$(pwd)
    local project_skills_dir="$project_dir/.claude/skills"

    mkdir -p "$project_skills_dir"

    if [ ! -d "$project_skills_dir/mobile-skills" ]; then
        echo -e "${YELLOW}Cloning mobile-skills...${NC}"
        git clone https://github.com/omixec/mobile-skills.git "$project_skills_dir/mobile-skills"
    fi

    cd "$project_skills_dir"
    for skill_name in "${skills[@]}"; do
        skill_path="$project_skills_dir/mobile-skills/skills/$skill_name"
        if [ -d "$skill_path" ]; then
            link_name="skill-$skill_name"
            [ -L "$link_name" ] && rm "$link_name"
            ln -sf "$skill_path" "$link_name"
            echo -e "${GREEN}✓${NC} Linked: $skill_name"
        else
            echo -e "${RED}✗${NC} Not found: $skill_name"
        fi
    done

    echo
    echo -e "${GREEN}Installation complete!${NC}"
    echo -e "${YELLOW}Skills installed in: $project_skills_dir${NC}"
}

# Get script directory for skill listing
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

main() {
    print_header
    
    # Auto-detect if running via curl
    if [ -z "$SCRIPT_DIR" ] || [ ! -d "$SCRIPT_DIR/skills" ]; then
        TEMP_DIR=$(mktemp -d)
        echo -e "${YELLOW}Cloning mobile-skills for installation...${NC}"
        git clone --depth 1 https://github.com/omixec/mobile-skills.git "$TEMP_DIR/mobile-skills" 2>/dev/null
        SCRIPT_DIR="$TEMP_DIR/mobile-skills"
    fi

    if [ ! -d "$SCRIPT_DIR/skills" ]; then
        echo -e "${RED}Error: Could not find skills directory${NC}"
        exit 1
    fi

    print_menu
    
    read -p "Select option [1]: " choice
    choice=${choice:-1}

    case $choice in
        1) install_global ;;
        2) install_project ;;
        3) install_custom ;;
        0) echo "Exiting."; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}"; exit 1 ;;
    esac
}

main "$@"
