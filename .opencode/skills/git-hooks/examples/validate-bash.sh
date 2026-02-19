#!/bin/bash

# Example: Simple bash script syntax validator
# Place in .githooks/pre-commit

set -e

echo "🔍 Validating bash scripts..."

# Get staged .sh files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)

if [ -z "$STAGED_FILES" ]; then
    echo "✅ No bash scripts to validate"
    exit 0
fi

# Validate syntax
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        echo "Checking $file..."
        bash -n "$file" || exit 1
    fi
done

echo "✅ All bash scripts valid"
exit 0
