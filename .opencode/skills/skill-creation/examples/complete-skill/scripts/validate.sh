#!/bin/bash
# scripts/validate.sh
#
# Example validation script for complete-skill demonstration.
# Shows how to write a utility script for skill validation.
#
# Usage: ./scripts/validate.sh

set -euo pipefail

echo "=== Complete Skill Validation Example ==="
echo
echo "This script demonstrates validation patterns for skills."
echo "It validates the complete-skill example structure."
echo

SKILL_DIR="$(dirname "$0")/.."
EXIT_CODE=0

# Helper function for validation checks
check() {
    local description="$1"
    local condition="$2"
    
    if eval "$condition"; then
        echo "  ✓ $description"
        return 0
    else
        echo "  ✗ $description"
        EXIT_CODE=1
        return 1
    fi
}

# Validate SKILL.md
echo "Validating SKILL.md..."
check "SKILL.md exists" "[[ -f '${SKILL_DIR}/SKILL.md' ]]"
check "SKILL.md has frontmatter" "grep -q '^---$' '${SKILL_DIR}/SKILL.md'"
check "SKILL.md has name field" "grep -q '^name:' '${SKILL_DIR}/SKILL.md'"
check "SKILL.md has description" "grep -q '^description:' '${SKILL_DIR}/SKILL.md'"

# Validate references/
echo
echo "Validating references/..."
check "references/ directory exists" "[[ -d '${SKILL_DIR}/references' ]]"
check "patterns.md exists" "[[ -f '${SKILL_DIR}/references/patterns.md' ]]"
check "advanced.md exists" "[[ -f '${SKILL_DIR}/references/advanced.md' ]]"

# Validate examples/
echo
echo "Validating examples/..."
check "examples/ directory exists" "[[ -d '${SKILL_DIR}/examples' ]]"
check "working-example.sh exists" "[[ -f '${SKILL_DIR}/examples/working-example.sh' ]]"
check "working-example.sh is executable" "[[ -x '${SKILL_DIR}/examples/working-example.sh' ]]"

# Validate scripts/
echo
echo "Validating scripts/..."
check "scripts/ directory exists" "[[ -d '${SKILL_DIR}/scripts' ]]"
check "validate.sh exists (self)" "[[ -f '${SKILL_DIR}/scripts/validate.sh' ]]"
check "validate.sh is executable (self)" "[[ -x '${SKILL_DIR}/scripts/validate.sh' ]]"

# Summary
echo
if [[ $EXIT_CODE -eq 0 ]]; then
    echo "=== Validation Passed ==="
    echo "All checks passed successfully!"
else
    echo "=== Validation Failed ==="
    echo "Some checks failed. Review errors above."
fi

exit $EXIT_CODE
