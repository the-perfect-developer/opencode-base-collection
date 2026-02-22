#!/bin/bash

# Git hook: Validate Python files with Ruff
# This hook checks all staged Python files for linting errors and formatting issues

set -e

echo "🔍 Running Ruff validation on Python files..."

# Get staged Python files
STAGED_PY_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$' || true)

if [ -z "$STAGED_PY_FILES" ]; then
    echo "✅ No Python files to validate"
    exit 0
fi

# Check if ruff is installed
if ! command -v ruff &> /dev/null; then
    echo "❌ Ruff is not installed"
    echo ""
    echo "Install it with:"
    echo "  pip install ruff"
    echo "  or"
    echo "  uv add --dev ruff"
    exit 1
fi

# Create a temporary file list for validation
TEMP_FILE_LIST=$(mktemp)
echo "$STAGED_PY_FILES" > "$TEMP_FILE_LIST"

# Track validation status
LINT_FAILED=0
FORMAT_FAILED=0

# Run Ruff linter on staged files
echo "📋 Checking linting rules..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        if ! ruff check "$file"; then
            LINT_FAILED=1
        fi
    fi
done < "$TEMP_FILE_LIST"

# Run Ruff formatter check on staged files
echo ""
echo "📐 Checking code formatting..."
while IFS= read -r file; do
    if [ -f "$file" ]; then
        if ! ruff format --check "$file"; then
            FORMAT_FAILED=1
        fi
    fi
done < "$TEMP_FILE_LIST"

# Cleanup
rm -f "$TEMP_FILE_LIST"

# Report results
if [ $LINT_FAILED -eq 1 ] || [ $FORMAT_FAILED -eq 1 ]; then
    echo ""
    echo "❌ Ruff validation failed"
    echo ""
    
    if [ $LINT_FAILED -eq 1 ]; then
        echo "Fix linting issues with:"
        echo "  ruff check --fix ."
    fi
    
    if [ $FORMAT_FAILED -eq 1 ]; then
        echo "Fix formatting issues with:"
        echo "  ruff format ."
    fi
    
    exit 1
fi

echo "✅ All Python files passed Ruff validation"
exit 0
