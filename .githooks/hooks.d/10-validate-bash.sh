#!/bin/bash

# Pre-commit hook: Validate bash script syntax
# This hook validates all bash scripts that are being committed

set -e

echo "🔍 Validating bash script syntax..."

# Get all staged .sh files
STAGED_SCRIPTS=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)

if [ -z "$STAGED_SCRIPTS" ]; then
    echo "✅ No bash scripts to validate"
    exit 0
fi

# Track if any validation failed
VALIDATION_FAILED=0

# Validate each staged script
for script in $STAGED_SCRIPTS; do
    if [ -f "$script" ]; then
        echo "  Checking: $script"
        
        # Use bash -n to check syntax without executing
        if ! bash -n "$script" 2>&1; then
            echo "❌ Syntax error in: $script"
            VALIDATION_FAILED=1
        fi
    fi
done

if [ $VALIDATION_FAILED -eq 1 ]; then
    echo ""
    echo "❌ Bash script validation failed"
    echo "   Fix the syntax errors above and try again"
    exit 1
fi

echo "✅ All bash scripts validated successfully"
exit 0
