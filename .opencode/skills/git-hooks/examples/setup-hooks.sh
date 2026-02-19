#!/bin/bash

# Setup script to install git hooks
# Run this after cloning the repository

set -e

echo "🔧 Setting up git hooks..."

# Get the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)

# Configure git to use .githooks directory
git config core.hooksPath .githooks

echo "✅ Git hooks configured successfully!"
echo ""
echo "The following hooks are now active:"
echo "  - pre-commit: Orchestrator for modular validations"
echo ""
echo "Hooks directory: .githooks/"
echo ""
echo "Individual validations in .githooks/hooks.d/:"
echo "  - 10-validate-bash.sh"
echo "  - 20-validate-skills.sh"
echo ""
echo "To disable a hook temporarily:"
echo "  chmod -x .githooks/hooks.d/[hook-name]"
echo "  Or rename with .disabled extension"
