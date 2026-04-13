#!/bin/bash
# Install mobile-skills for Cursor
# Usage: curl -sL https://raw.githubusercontent.com/omixec/mobile-skills/main/install-cursor.sh | bash

set -e

echo "Installing mobile-skills for Cursor..."

SKILLS_DIR="$HOME/.cursor/extensions/skills"

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

echo "Installation complete!"
echo "Restart Cursor to use the new skills."