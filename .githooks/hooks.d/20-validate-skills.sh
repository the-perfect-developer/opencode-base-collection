#!/bin/bash

# Pre-commit hook: Validate SKILL.md files
# This hook validates all skill files that are being committed

set -e

echo "🔍 Validating SKILL.md files..."

# Get all staged SKILL.md files
STAGED_SKILLS=$(git diff --cached --name-only --diff-filter=ACM | grep 'SKILL\.md$' || true)

if [ -z "$STAGED_SKILLS" ]; then
    echo "✅ No SKILL.md files to validate"
    exit 0
fi

# Path to validation script
VALIDATOR=".opencode/skills/skill-creation/scripts/validate-skill.sh"

if [ ! -f "$VALIDATOR" ]; then
    echo "⚠️  Warning: Validation script not found at: $VALIDATOR"
    echo "   Skipping SKILL.md validation"
    exit 0
fi

# Track if any validation failed
VALIDATION_FAILED=0

# Validate each staged SKILL.md file
for skill_file in $STAGED_SKILLS; do
    if [ -f "$skill_file" ]; then
        # Get the directory containing SKILL.md
        skill_dir=$(dirname "$skill_file")
        
        echo ""
        echo "  Validating: $skill_file"
        echo "  ---"
        
        # Run validation script on the skill directory
        if ! "$VALIDATOR" "$skill_dir"; then
            echo "❌ Validation failed for: $skill_file"
            VALIDATION_FAILED=1
        else
            echo "  ---"
            echo "✅ Validation passed for: $skill_file"
        fi
    fi
done

if [ $VALIDATION_FAILED -eq 1 ]; then
    echo ""
    echo "❌ SKILL.md validation failed"
    echo "   Fix the errors above and try again"
    exit 1
fi

echo ""
echo "✅ All SKILL.md files validated successfully"
exit 0
