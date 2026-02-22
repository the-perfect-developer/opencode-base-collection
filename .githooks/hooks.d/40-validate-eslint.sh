#!/bin/bash

# Git hook: Validate JavaScript and TypeScript files with ESLint
# This hook checks all staged .js, .mjs, .cjs, .jsx, .ts, .mts, .cts, .tsx
# files for linting errors using ESLint.

set -e

echo "🔍 Running ESLint validation on JS/TS files..."

# Get staged JS/TS files (added, copied, or modified)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM \
    | grep -E '\.(js|mjs|cjs|jsx|ts|mts|cts|tsx)$' || true)

if [ -z "$STAGED_FILES" ]; then
    echo "✅ No JS/TS files to validate"
    exit 0
fi

# Skip if this is not a Node.js project (no package.json at repo root).
# This allows JS/TS example files in non-Node repos (e.g. skills collections)
# to be committed without ESLint being installed.
REPO_ROOT=$(git rev-parse --show-toplevel)
if [ ! -f "$REPO_ROOT/package.json" ]; then
    echo "✅ No package.json found — skipping ESLint (not a Node.js project)"
    exit 0
fi

# Resolve the ESLint binary to use:
#   1. Local project binary (node_modules/.bin/eslint) — preferred
#   2. npx fallback (downloads on first run if not cached)
#   3. Global eslint binary
#
# Search upward from the repo root for node_modules/.bin/eslint
LOCAL_ESLINT="$REPO_ROOT/node_modules/.bin/eslint"

if [ -x "$LOCAL_ESLINT" ]; then
    ESLINT_CMD="$LOCAL_ESLINT"
elif command -v npx &> /dev/null; then
    # Use npx only if eslint is available in the local package (avoids
    # downloading it on every commit). npx --no-install exits non-zero if
    # the binary is not found locally.
    if npx --no-install eslint --version &> /dev/null 2>&1; then
        ESLINT_CMD="npx --no-install eslint"
    else
        echo "⚠️  ESLint is not installed in this project"
        echo ""
        echo "Install it with:"
        echo "  npm install --save-dev eslint @eslint/js"
        echo "  # or"
        echo "  pnpm add --save-dev eslint @eslint/js"
        echo ""
        echo "Then create a config file:"
        echo "  npm init @eslint/config@latest"
        exit 1
    fi
elif command -v eslint &> /dev/null; then
    ESLINT_CMD="eslint"
else
    echo "⚠️  ESLint is not installed"
    echo ""
    echo "Install it with:"
    echo "  npm install --save-dev eslint @eslint/js"
    echo "  # or"
    echo "  pnpm add --save-dev eslint @eslint/js"
    echo ""
    echo "Then create a config file:"
    echo "  npm init @eslint/config@latest"
    exit 1
fi

# Check that an ESLint config file exists in the repo root
if [ ! -f "$REPO_ROOT/eslint.config.js" ] \
    && [ ! -f "$REPO_ROOT/eslint.config.mjs" ] \
    && [ ! -f "$REPO_ROOT/eslint.config.cjs" ] \
    && [ ! -f "$REPO_ROOT/eslint.config.ts" ] \
    && [ ! -f "$REPO_ROOT/eslint.config.mts" ] \
    && [ ! -f "$REPO_ROOT/eslint.config.cts" ]; then
    echo "⚠️  No ESLint config file found at repo root"
    echo ""
    echo "Create one with:"
    echo "  npm init @eslint/config@latest"
    echo ""
    echo "Or manually create eslint.config.js — see the 'eslint' skill for"
    echo "a production-ready template."
    exit 1
fi

# Run ESLint against every staged file
# --no-warn-ignored: suppress warnings for files matched by global ignores
# --max-warnings 0:  treat any warning as a failure (strict mode)
LINT_FAILED=0

echo "📋 Checking files..."

while IFS= read -r file; do
    # Only lint files that still exist on disk (not deleted)
    if [ -f "$file" ]; then
        echo "  Checking: $file"
        if ! $ESLINT_CMD --no-warn-ignored "$file" 2>&1; then
            LINT_FAILED=1
        fi
    fi
done <<< "$STAGED_FILES"

if [ $LINT_FAILED -eq 1 ]; then
    echo ""
    echo "❌ ESLint validation failed"
    echo ""
    echo "Fix auto-fixable issues with:"
    echo "  npx eslint --fix <file>"
    echo ""
    echo "To skip this check in exceptional cases (use sparingly):"
    echo "  git commit --no-verify"
    exit 1
fi

echo "✅ All JS/TS files passed ESLint validation"
exit 0
