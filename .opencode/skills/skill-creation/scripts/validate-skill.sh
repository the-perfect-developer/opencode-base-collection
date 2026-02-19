#!/bin/bash
# validate-skill.sh
#
# Validates OpenCode skill structure and frontmatter.
#
# Usage: validate-skill.sh <skill-path>
#
# Example:
#   validate-skill.sh .opencode/skills/my-skill
#   validate-skill.sh ~/.config/opencode/skills/global-skill

set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Usage information
usage() {
    cat <<EOF
Usage: $(basename "$0") <skill-path>

Validates OpenCode skill structure and frontmatter.

Arguments:
  skill-path    Path to skill directory containing SKILL.md

Examples:
  $(basename "$0") .opencode/skills/my-skill
  $(basename "$0") ~/.config/opencode/skills/global-skill

Exit codes:
  0 - All validations passed
  1 - Validation errors found
  2 - Usage error

Checks performed:
  - SKILL.md file exists
  - Valid YAML frontmatter syntax
  - Required fields present (name, description)
  - Name matches regex pattern
  - Name matches directory name
  - Description length (1-1024 chars)
  - Referenced files exist
EOF
}

# Show help if requested or no arguments
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
    exit 0
fi

# Get skill path
SKILL_PATH="$1"

# Check skill directory exists
if [[ ! -d "$SKILL_PATH" ]]; then
    echo -e "${RED}✗ Error: Directory not found: ${SKILL_PATH}${NC}"
    exit 2
fi

# Get absolute path
SKILL_PATH=$(cd "$SKILL_PATH" && pwd)
SKILL_FILE="${SKILL_PATH}/SKILL.md"

echo "=== Validating Skill at ${SKILL_PATH} ==="
echo

# Track validation status
EXIT_CODE=0
ERROR_COUNT=0
WARNING_COUNT=0

# Helper functions
error() {
    echo -e "${RED}✗ ERROR: $1${NC}"
    ((ERROR_COUNT++))
    EXIT_CODE=1
}

warn() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
    ((WARNING_COUNT++))
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Validation 1: SKILL.md exists
echo "Checking file structure..."
if [[ -f "$SKILL_FILE" ]]; then
    success "SKILL.md exists"
else
    error "SKILL.md not found at: ${SKILL_FILE}"
    echo
    echo "=== Validation Failed ==="
    echo "Cannot continue without SKILL.md file"
    exit 1
fi

# Validation 2: Extract and validate frontmatter
echo
echo "Checking frontmatter..."

# Check frontmatter delimiters exist
if ! grep -q "^---$" "$SKILL_FILE"; then
    error "Frontmatter delimiters (---) not found"
else
    success "Frontmatter delimiters present"
    
    # Extract frontmatter (between first and second --- only)
    FRONTMATTER=$(awk 'BEGIN{count=0} /^---$/{count++; if(count==1) {in_fm=1; next} else if(count==2) {exit}} in_fm' "$SKILL_FILE")
    
    # Check YAML syntax (basic check)
    if echo "$FRONTMATTER" | grep -qE '^[a-zA-Z_]+:'; then
        success "Frontmatter has YAML structure"
    else
        error "Frontmatter doesn't appear to be valid YAML"
    fi
fi

# Validation 3: Check required fields
echo
echo "Checking required fields..."

# Check name field
if echo "$FRONTMATTER" | grep -q "^name:"; then
    NAME=$(echo "$FRONTMATTER" | grep "^name:" | head -1 | cut -d' ' -f2- | tr -d '"' | tr -d "'")
    success "name field present: ${NAME}"
    
    # Validate name pattern
    if echo "$NAME" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        success "name matches pattern: ^[a-z0-9]+(-[a-z0-9]+)*$"
    else
        error "name '${NAME}' doesn't match pattern: ^[a-z0-9]+(-[a-z0-9]+)*$"
        echo "  Name must:"
        echo "    - Be lowercase only"
        echo "    - Use hyphens, not underscores"
        echo "    - Not start or end with hyphen"
        echo "    - Not have consecutive hyphens"
    fi
    
    # Validate name length
    NAME_LENGTH=${#NAME}
    if [[ $NAME_LENGTH -ge 1 ]] && [[ $NAME_LENGTH -le 64 ]]; then
        success "name length valid (${NAME_LENGTH} chars, 1-64 allowed)"
    else
        error "name length invalid (${NAME_LENGTH} chars, must be 1-64)"
    fi
    
    # Check name matches directory
    DIR_NAME=$(basename "$SKILL_PATH")
    if [[ "$NAME" == "$DIR_NAME" ]]; then
        success "name matches directory: ${DIR_NAME}"
    else
        error "name '${NAME}' doesn't match directory '${DIR_NAME}'"
    fi
else
    error "name field missing in frontmatter"
    NAME=""
fi

# Check description field
if echo "$FRONTMATTER" | grep -q "^description:"; then
    # Extract description from frontmatter only (may be multi-line)
    DESCRIPTION=$(echo "$FRONTMATTER" | sed -n '/^description:/,/^[a-z_-]*:/p' | sed '$d' | sed '1s/^description: *//')
    # If single line, just get it directly
    if [[ -z "$DESCRIPTION" ]]; then
        DESCRIPTION=$(echo "$FRONTMATTER" | grep "^description:" | head -1 | cut -d' ' -f2-)
    fi
    
    success "description field present"
    
    # Validate description length
    DESC_LENGTH=${#DESCRIPTION}
    if [[ $DESC_LENGTH -ge 1 ]] && [[ $DESC_LENGTH -le 1024 ]]; then
        success "description length valid (${DESC_LENGTH} chars, 1-1024 allowed)"
    else
        error "description length invalid (${DESC_LENGTH} chars, must be 1-1024)"
    fi
    
    # Check for trigger phrases in quotes
    if echo "$DESCRIPTION" | grep -q '"[^"]*"'; then
        success "description includes trigger phrases in quotes"
    else
        warn "description should include specific trigger phrases in quotes"
        echo "  Example: This skill should be used when the user asks to \"create X\", \"do Y\"..."
    fi
else
    error "description field missing in frontmatter"
fi

# Validation 4: Check optional fields
echo
echo "Checking optional fields..."

if grep -q "^license:" "$SKILL_FILE"; then
    LICENSE=$(grep "^license:" "$SKILL_FILE" | cut -d' ' -f2-)
    success "license field present: ${LICENSE}"
fi

if grep -q "^compatibility:" "$SKILL_FILE"; then
    COMPAT=$(grep "^compatibility:" "$SKILL_FILE" | cut -d' ' -f2-)
    success "compatibility field present: ${COMPAT}"
fi

if grep -q "^metadata:" "$SKILL_FILE"; then
    success "metadata field present"
fi

# Validation 5: Check referenced files
echo
echo "Checking referenced files..."

# Find all markdown file references in SKILL.md (pattern: `path/to/file.md`)
REFERENCED_FILES=$(grep -oE '`[^`]*\.(md|sh|py|js|json|yaml|yml|txt)`' "$SKILL_FILE" | tr -d '`' || true)

if [[ -n "$REFERENCED_FILES" ]]; then
    MISSING_FILES=()
    
    while IFS= read -r ref_file; do
        # Resolve path relative to skill directory
        FULL_PATH="${SKILL_PATH}/${ref_file}"
        
        if [[ -f "$FULL_PATH" ]]; then
            success "Referenced file exists: ${ref_file}"
        else
            warn "Referenced file not found: ${ref_file}"
            MISSING_FILES+=("$ref_file")
        fi
    done <<< "$REFERENCED_FILES"
    
    if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
        echo
        warn "Some referenced files are missing:"
        for missing in "${MISSING_FILES[@]}"; do
            echo "    - ${missing}"
        done
    fi
else
    success "No file references found (or all references use different format)"
fi

# Validation 6: Check for common directories
echo
echo "Checking directory structure..."

if [[ -d "${SKILL_PATH}/references" ]]; then
    REF_COUNT=$(find "${SKILL_PATH}/references" -type f -name "*.md" | wc -l)
    success "references/ directory exists (${REF_COUNT} files)"
fi

if [[ -d "${SKILL_PATH}/examples" ]]; then
    EX_COUNT=$(find "${SKILL_PATH}/examples" -type f | wc -l)
    success "examples/ directory exists (${EX_COUNT} files)"
fi

if [[ -d "${SKILL_PATH}/scripts" ]]; then
    SCRIPT_COUNT=$(find "${SKILL_PATH}/scripts" -type f | wc -l)
    success "scripts/ directory exists (${SCRIPT_COUNT} files)"
    
    # Check if scripts are executable
    NON_EXEC=$(find "${SKILL_PATH}/scripts" -type f ! -executable 2>/dev/null | wc -l)
    if [[ $NON_EXEC -gt 0 ]]; then
        warn "${NON_EXEC} script(s) in scripts/ are not executable"
        echo "  Run: chmod +x ${SKILL_PATH}/scripts/*.sh"
    fi
fi

# Validation 7: Check SKILL.md body size
echo
echo "Checking content size..."

# Count words in body (excluding frontmatter)
BODY_WORDS=$(sed -n '/^---$/,/^---$/!p' "$SKILL_FILE" | wc -w)

if [[ $BODY_WORDS -ge 1500 ]] && [[ $BODY_WORDS -le 2000 ]]; then
    success "SKILL.md body size ideal (${BODY_WORDS} words, 1500-2000 recommended)"
elif [[ $BODY_WORDS -lt 1500 ]]; then
    success "SKILL.md body size (${BODY_WORDS} words)"
    if [[ $BODY_WORDS -lt 500 ]]; then
        warn "SKILL.md body is quite short (${BODY_WORDS} words)"
    fi
elif [[ $BODY_WORDS -le 3000 ]]; then
    success "SKILL.md body size acceptable (${BODY_WORDS} words, under 3000)"
else
    warn "SKILL.md body is large (${BODY_WORDS} words, recommended <3000)"
    echo "  Consider moving some content to references/"
fi

# Summary
echo
echo "=== Validation Summary ==="

if [[ $ERROR_COUNT -eq 0 ]] && [[ $WARNING_COUNT -eq 0 ]]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo "Skill is ready to use."
elif [[ $ERROR_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}⚠ Validation passed with ${WARNING_COUNT} warning(s)${NC}"
    echo "Skill will work, but consider addressing warnings."
else
    echo -e "${RED}✗ Validation failed with ${ERROR_COUNT} error(s) and ${WARNING_COUNT} warning(s)${NC}"
    echo "Fix errors before using the skill."
fi

echo
echo "Skill path: ${SKILL_PATH}"

if [[ -n "$NAME" ]]; then
    echo "Skill name: ${NAME}"
fi

exit $EXIT_CODE
