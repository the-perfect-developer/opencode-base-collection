#!/bin/bash

# Example: SKILL.md validator hook
# Validates skill files using the skill-creation validation script
# Place in .githooks/hooks.d/20-validate-skills.sh

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
    echo "⚠️  Warning: Validation script not found"
    echo "   Skipping SKILL.md validation"
    exit 0
fi

# Validate each skill
VALIDATION_FAILED=0

for skill_file in $STAGED_SKILLS; do
    if [ -f "$skill_file" ]; then
        skill_dir=$(dirname "$skill_file")
        
        echo "  Validating: $skill_file"
        
        if ! "$VALIDATOR" "$skill_dir"; then
            echo "❌ Validation failed for: $skill_file"
            VALIDATION_FAILED=1
        fi
    fi
done

if [ $VALIDATION_FAILED -eq 1 ]; then
    exit 1
fi

echo "✅ All SKILL.md files validated successfully"
exit 0
