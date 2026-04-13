#!/bin/bash
# Install mobile-skills for Claude Code
# Usage: curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-claude.sh | bash

set -e

echo "Installing mobile-skills for Claude..."

# Find Claude config directory
CLAUDE_CONFIG_DIR=""
if [ -d "$HOME/Library/Application Support/Claude" ]; then
    CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
elif [ -d "$HOME/.config/Claude" ]; then
    CLAUDE_CONFIG_DIR="$HOME/.config/Claude"
fi

if [ -z "$CLAUDE_CONFIG_DIR" ]; then
    echo "Error: Could not find Claude config directory"
    exit 1
fi

SKILLS_DIR="$CLAUDE_CONFIG_DIR/Skills"

# Create skills directory
mkdir -p "$SKILLS_DIR"

# Clone or update repository
if [ -d "$SKILLS_DIR/mobile-skills" ]; then
    echo "Updating existing mobile-skills..."
    cd "$SKILLS_DIR/mobile-skills"
    git pull origin main 2>/dev/null || echo "Could not pull, using existing version"
else
    echo "Cloning mobile-skills..."
    git clone https://github.com/omixec/mobile-skills.git "$SKILLS_DIR/mobile-skills"
fi

# Link individual skills
cd "$SKILLS_DIR"
for dir in mobile-skills/skills/*/; do
    if [ -d "$dir" ]; then
        skill_name=$(basename "$dir")
        link_name="skill-$skill_name"
        if [ -L "$link_name" ]; then
            rm "$link_name"
        fi
        ln -sf "$dir" "$link_name"
        echo "Linked: $skill_name"
    fi
done

echo "Installation complete!"
echo "Restart Claude to use the new skills."