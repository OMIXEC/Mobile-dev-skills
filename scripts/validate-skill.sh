#!/usr/bin/env bash
# =============================================================================
# validate-skill.sh — Validate a skill directory structure
# Usage: scripts/validate-skill.sh <path/to/skill>
# =============================================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ERRORS=0; WARNINGS=0

err()  { echo -e "${RED}  ERROR:${NC} $1"; ((ERRORS++)); }
warn() { echo -e "${YELLOW}  WARN:${NC} $1"; ((WARNINGS++)); }
ok()   { echo -e "${GREEN}  OK:${NC} $1"; }

SKILL_DIR="$1"

if [ ! -d "$SKILL_DIR" ]; then
    echo -e "${RED}Skill directory not found: $SKILL_DIR${NC}"
    exit 1
fi

SKILL_NAME="$(basename "$SKILL_DIR")"
echo -e "Validating: ${CYAN}$SKILL_NAME${NC}"
echo ""

# Check SKILL.md exists
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
    err "Missing SKILL.md"
else
    ok "SKILL.md exists"

        # Check frontmatter
        first_line=$(head -1 "$SKILL_DIR/SKILL.md" | tr -d '\r')
        if [ "$first_line" != "---" ]; then
            err "Missing YAML frontmatter (--- delimiter, got: '$first_line')"
    else
        ok "Has YAML frontmatter"

        # Check name field
        name=$(sed -n '/^---$/,/^---$/p' "$SKILL_DIR/SKILL.md" | sed -n '/^name:/s/^name:\s*//p' | tr -d '"'"'" | xargs)
        if [ -z "$name" ]; then
            err "Missing 'name' field in frontmatter"
        elif [ "$name" != "$SKILL_NAME" ]; then
            warn "name field '$name' does not match directory '$SKILL_NAME'"
        else
            ok "name matches directory: $name"
        fi

        # Check description — verify it exists in frontmatter
        desc_check=$(awk '/^---$/{f++;next} f==1 && /^description:/{print "found"; exit}' "$SKILL_DIR/SKILL.md")
        if [ -z "$desc_check" ]; then
            err "Missing 'description' field in frontmatter"
        else
            # Try to get a rough char count for the description value
            desc_len=$(awk '/^---$/{f++;next} /^---$/{exit} f==1 && p{print} f==1 && /^description:/{p=1}' "$SKILL_DIR/SKILL.md" | wc -c | tr -d ' ')
            if [ "$desc_len" -lt 10 ]; then
                warn "Description appears very short ($desc_len chars)"
            else
                ok "Description present"
            fi
        fi

        # Check for non-standard fields
        non_std=$(sed -n '/^---$/,/^---$/p' "$SKILL_DIR/SKILL.md" | grep -v '^name:' | grep -v '^description:' | \
            grep -v '^---$' | grep -v '^$' | grep -v '^#' | grep -v '^compatibility:')
        if [ -n "$non_std" ]; then
            warn "Non-standard frontmatter fields found:"
            echo "$non_std" | sed 's/^/    /'
        fi
    fi
fi

# Check references
if [ -d "$SKILL_DIR/references" ] && [ -z "$(ls -A "$SKILL_DIR/references" 2>/dev/null)" ]; then
    warn "Empty references/ directory"
fi

echo ""
echo -e "${GREEN}${BOLD}Result:${NC} ${ERRORS} errors, ${WARNINGS} warnings"
[ "$ERRORS" -eq 0 ] || exit 1
