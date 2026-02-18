#!/bin/bash
# examples/working-example.sh
#
# Complete working example demonstrating skill creation workflow.
# This script creates a minimal skill and validates it.
#
# Usage: ./examples/working-example.sh [skill-name]
#
# Example:
#   ./examples/working-example.sh my-test-skill

set -euo pipefail

# Get skill name from argument or use default
SKILL_NAME="${1:-example-skill}"
SKILL_DIR=".opencode/skills/${SKILL_NAME}"

echo "=== Skill Creation Example ==="
echo "Creating skill: ${SKILL_NAME}"
echo

# Step 1: Create directory structure
echo "Step 1: Creating directory structure..."
mkdir -p "${SKILL_DIR}"
echo "  ✓ Created ${SKILL_DIR}/"

# Step 2: Create SKILL.md with frontmatter
echo
echo "Step 2: Creating SKILL.md with frontmatter..."
cat > "${SKILL_DIR}/SKILL.md" <<'EOF'
---
name: PLACEHOLDER_NAME
description: This skill should be used when the user asks to "demonstrate example skill", "test skill creation", or needs an example of a working skill.
---

# Example Skill

This is a minimal working skill created by the example script.

## Purpose

Demonstrate:
- Proper skill structure
- Valid frontmatter
- Basic content organization

## Usage

This skill was created as an example. You can:
1. Examine the structure
2. Use as a template
3. Modify for your needs
4. Delete when done

## Structure

```
PLACEHOLDER_NAME/
└── SKILL.md
```

## Next Steps

To enhance this skill:
- Add `references/` for detailed documentation
- Add `examples/` for working code samples  
- Add `scripts/` for utility tools

See the skill-creation skill for complete guidance.
EOF

# Replace placeholder with actual skill name
sed -i "s/PLACEHOLDER_NAME/${SKILL_NAME}/g" "${SKILL_DIR}/SKILL.md"
echo "  ✓ Created ${SKILL_DIR}/SKILL.md"

# Step 3: Show the created skill
echo
echo "Step 3: Skill created successfully!"
echo
echo "Frontmatter:"
echo "---"
sed -n '/^---$/,/^---$/p' "${SKILL_DIR}/SKILL.md" | sed '1d;$d'
echo "---"

# Step 4: Validation (if validation script exists)
echo
echo "Step 4: Validation..."
VALIDATE_SCRIPT=".opencode/skills/skill-creation/scripts/validate-skill.sh"

if [[ -f "${VALIDATE_SCRIPT}" ]]; then
    echo "Running validation script..."
    bash "${VALIDATE_SCRIPT}" "${SKILL_DIR}" || true
else
    echo "Validation script not found at: ${VALIDATE_SCRIPT}"
    echo "Performing basic validation manually..."
    
    # Basic validation checks
    echo
    echo "Basic validation checks:"
    
    # Check SKILL.md exists
    if [[ -f "${SKILL_DIR}/SKILL.md" ]]; then
        echo "  ✓ SKILL.md exists"
    else
        echo "  ✗ SKILL.md not found"
    fi
    
    # Check frontmatter exists
    if grep -q "^---$" "${SKILL_DIR}/SKILL.md"; then
        echo "  ✓ Frontmatter delimiters present"
    else
        echo "  ✗ Frontmatter delimiters missing"
    fi
    
    # Check name field
    if grep -q "^name:" "${SKILL_DIR}/SKILL.md"; then
        echo "  ✓ name field present"
    else
        echo "  ✗ name field missing"
    fi
    
    # Check description field
    if grep -q "^description:" "${SKILL_DIR}/SKILL.md"; then
        echo "  ✓ description field present"
    else
        echo "  ✗ description field missing"
    fi
    
    # Check name matches pattern
    NAME=$(grep "^name:" "${SKILL_DIR}/SKILL.md" | cut -d' ' -f2)
    if echo "$NAME" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        echo "  ✓ name matches pattern"
    else
        echo "  ✗ name doesn't match pattern: ^[a-z0-9]+(-[a-z0-9]+)*$"
    fi
fi

# Summary
echo
echo "=== Summary ==="
echo "Skill '${SKILL_NAME}' created at: ${SKILL_DIR}/"
echo
echo "Next steps:"
echo "  1. Review ${SKILL_DIR}/SKILL.md"
echo "  2. Customize the content for your use case"
echo "  3. Test by asking OpenCode to use the skill"
echo "  4. Add references/, examples/, scripts/ as needed"
echo
echo "To delete this example skill:"
echo "  rm -rf ${SKILL_DIR}"
echo
