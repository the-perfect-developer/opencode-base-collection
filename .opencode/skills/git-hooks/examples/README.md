# Git Hooks Examples

Working examples from the Base Skills project demonstrating Git hooks implementation patterns.

## Overview

This directory contains real-world examples of Git hooks used in this project. All examples are production-ready and actively used.

## Directory Structure

```
examples/
├── README.md                    # This file
├── modular-pre-commit/          # Full orchestrator pattern example
│   ├── pre-commit               # Orchestrator script
│   └── hooks.d/                 # Individual validation hooks
│       ├── 10-validate-bash.sh
│       └── 20-validate-skills.sh
├── setup-hooks.sh               # Installation script
├── validate-bash.sh             # Standalone bash validator
└── validate-skills.sh           # Standalone skill validator
```

## Examples

### Modular Pre-Commit Hook

**Location**: `modular-pre-commit/`

Full implementation of the orchestrator pattern used in this project.

**Features**:
- Discovers and runs all hooks in `hooks.d/` directory
- Executes in numerical order (10, 20, 30...)
- Stops on first failure
- Clear visual feedback
- Easy to add new validations

**Usage**:
```bash
# Copy to your repository
cp -r modular-pre-commit/.githooks ~/my-project/

# Make hooks executable
chmod +x ~/my-project/.githooks/pre-commit
chmod +x ~/my-project/.githooks/hooks.d/*.sh

# Configure Git
cd ~/my-project
git config core.hooksPath .githooks
```

**Architecture**:
1. `pre-commit` - Orchestrator that finds and runs all hooks
2. `hooks.d/10-validate-bash.sh` - Validates bash script syntax
3. `hooks.d/20-validate-skills.sh` - Validates SKILL.md files

**Adding new hooks**:
```bash
# Create new validation (number determines order)
cat > .githooks/hooks.d/30-validate-yaml.sh <<'EOF'
#!/bin/bash
set -e
echo "🔍 Validating YAML files..."
# Validation logic here
exit 0
EOF

chmod +x .githooks/hooks.d/30-validate-yaml.sh
```

### Setup Script

**Location**: `setup-hooks.sh`

Automated installation script for team members.

**Features**:
- Configures `core.hooksPath` automatically
- Provides clear feedback
- Documents active hooks
- Safe to run multiple times

**Usage**:
```bash
# After cloning repository
./setup-hooks.sh
```

**What it does**:
1. Detects repository root
2. Configures Git to use `.githooks/` directory
3. Lists active hooks
4. Provides usage instructions

### Standalone Validators

**Location**: `validate-bash.sh`, `validate-skills.sh`

Individual validation hooks that can be used independently or within the orchestrator pattern.

#### Bash Validator

Validates shell script syntax without executing them.

**Features**:
- Uses `bash -n` for syntax checking
- Checks only staged files
- Fast execution
- Clear error messages

**Usage**:
```bash
# Standalone
./examples/validate-bash.sh

# As pre-commit hook
cp examples/validate-bash.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

#### Skills Validator

Validates SKILL.md files using the skill-creation validation script.

**Features**:
- Validates frontmatter syntax
- Checks required fields
- Verifies name patterns
- Validates referenced files exist

**Usage**:
```bash
# Standalone
./examples/validate-skills.sh

# In hooks.d/
cp examples/validate-skills.sh .githooks/hooks.d/20-validate-skills.sh
chmod +x .githooks/hooks.d/20-validate-skills.sh
```

## How This Project Uses Hooks

### Active Hooks

**Location**: `../../.githooks/`

This project actively uses:
1. **pre-commit** - Orchestrator for all pre-commit validations
2. **10-validate-bash.sh** - Ensures all shell scripts are syntactically valid
3. **20-validate-skills.sh** - Validates skill file structure and content

### Installation

New contributors run:
```bash
./setup-hooks.sh
```

Or manually:
```bash
git config core.hooksPath .githooks
```

### Naming Convention

Hooks use the pattern:
```
the-perfect-developer-base-collection-<number>-<description>.sh
```

- **Prefix**: Project identifier
- **Number**: Execution order (increments of 10)
- **Description**: What the hook validates

### Testing Hooks

```bash
# Test individual hook
.githooks/hooks.d/10-validate-bash.sh

# Test orchestrator
.githooks/pre-commit

# Temporarily disable a hook
chmod -x .githooks/hooks.d/20-validate-skills.sh
```

## Implementation Patterns

### Pattern 1: Early Exit

All hooks exit early when no relevant files are staged:

```bash
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.sh$' || true)

if [ -z "$STAGED_FILES" ]; then
    echo "✅ No files to validate"
    exit 0
fi
```

**Benefits**:
- Fast execution when hook doesn't apply
- Clear feedback about what was checked
- No wasted processing

### Pattern 2: Visual Feedback

Hooks use emojis for quick scanning:
- 🔍 - Starting validation
- ✅ - Success
- ❌ - Failure
- ⚠️  - Warning

```bash
echo "🔍 Validating bash scripts..."
# ... validation ...
echo "✅ All bash scripts valid"
```

### Pattern 3: Graceful Degradation

Hooks check for dependencies before using them:

```bash
VALIDATOR=".opencode/skills/skill-creation/scripts/validate-skill.sh"

if [ ! -f "$VALIDATOR" ]; then
    echo "⚠️  Warning: Validation script not found"
    echo "   Skipping SKILL.md validation"
    exit 0
fi
```

**Benefits**:
- Works even if optional tools are missing
- Clear warning when skipping validation
- Doesn't block commits unnecessarily

### Pattern 4: Numbered Execution Order

Hook names use numbered prefixes:
- `10-validate-bash.sh`
- `20-validate-skills.sh`
- `30-next-validation.sh`

**Benefits**:
- Predictable execution order
- Easy to insert new hooks (e.g., `15-validate-json.sh`)
- Self-documenting priority

## Best Practices from This Project

**DO** (as demonstrated):
- Use orchestrator pattern for multiple validations
- Exit early when no relevant files staged
- Provide clear, actionable error messages
- Make hooks easy to test independently
- Use consistent naming conventions
- Include visual indicators (emojis)
- Check for dependencies gracefully

**DON'T** (avoided in this project):
- Hardcode file paths
- Run validations on unstaged files
- Block commits without clear explanation
- Assume dependencies are available
- Mix multiple concerns in one hook

## Adapting for Your Project

### Minimal Setup

```bash
# 1. Copy orchestrator
cp modular-pre-commit/pre-commit .githooks/
mkdir -p .githooks/hooks.d

# 2. Add one validation
cp validate-bash.sh .githooks/hooks.d/10-validate-bash.sh

# 3. Make executable
chmod +x .githooks/pre-commit .githooks/hooks.d/*.sh

# 4. Configure Git
git config core.hooksPath .githooks
```

### Adding Project-Specific Validations

```bash
# Create new hook following the template
cat > .githooks/hooks.d/30-your-validation.sh <<'EOF'
#!/bin/bash
set -e

echo "🔍 Running your validation..."

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep 'pattern' || true)

if [ -z "$STAGED_FILES" ]; then
    echo "✅ No files to validate"
    exit 0
fi

# Your validation logic here
for file in $STAGED_FILES; do
    your-validator "$file" || exit 1
done

echo "✅ Validation passed"
exit 0
EOF

chmod +x .githooks/hooks.d/30-your-validation.sh
```

## Troubleshooting

**Hooks not running**:
```bash
# Check configuration
git config core.hooksPath

# Should output: .githooks
```

**Hook fails unexpectedly**:
```bash
# Run hook manually to see errors
.githooks/pre-commit

# Check individual hook
.githooks/hooks.d/10-validate-bash.sh
```

**Need to bypass hooks temporarily**:
```bash
# For testing only - don't use regularly
git commit --no-verify
```

## Reference

See the main SKILL.md for:
- Complete hooks documentation
- Advanced patterns
- Server-side hooks
- CI/CD integration
- Security considerations
