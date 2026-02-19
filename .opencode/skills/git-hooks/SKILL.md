---
name: git-hooks
description: This skill should be used when the user asks to "create git hooks", "set up pre-commit hooks", "configure git hooks", "add commit validation", "implement pre-push hooks", or needs guidance on Git hooks implementation, validation scripts, or hook best practices.
---

# Git Hooks

Automate code quality, testing, and validation using Git hooks—scripts that run automatically at key points in the Git workflow.

## What Are Git Hooks

Git hooks are executable scripts that Git runs automatically when specific events occur in a repository. They enable you to:

- **Enforce code quality** before commits reach the repository
- **Run automated tests** to catch issues early
- **Validate commit messages** to maintain consistent standards
- **Prevent accidental destructive actions** like force pushes
- **Trigger CI/CD workflows** on push events
- **Automate versioning and tagging** for releases

Hooks reside in `.git/hooks/` by default, but can be version-controlled using `core.hooksPath` configuration.

## Core Concepts

### Hook Types

**Client-side hooks** (run on developer machines):
- `pre-commit` - Before commit is created, validate staged changes
- `prepare-commit-msg` - Populate commit message template
- `commit-msg` - Validate commit message format
- `post-commit` - Notification after successful commit
- `pre-push` - Before pushing to remote, run tests
- `post-checkout` - After checkout, clean up working directory
- `pre-rebase` - Before rebasing, check for conflicts

**Server-side hooks** (run on remote repository):
- `pre-receive` - Before accepting pushed refs, enforce policies
- `update` - Like pre-receive, but runs per branch
- `post-receive` - After successful push, trigger CI/CD

### Hook Lifecycle

```
Developer action → Git event → Hook script runs → Exit code determines outcome
```

- **Exit 0**: Continue with Git operation
- **Exit non-zero**: Abort Git operation with error message

### Making Hooks Executable

Hooks must have execute permissions:

```bash
chmod +x .git/hooks/pre-commit
```

## Essential Workflows

### Setting Up Version-Controlled Hooks

Git doesn't version-control `.git/hooks/` by default. Use `core.hooksPath` to enable team-wide hooks:

**1. Create hooks directory in repository**:
```bash
mkdir .githooks
```

**2. Configure Git to use custom hooks path**:
```bash
git config core.hooksPath .githooks
```

**3. Add hooks to version control**:
```bash
git add .githooks/
git commit -m "Add version-controlled git hooks"
```

**4. Team members run after cloning**:
```bash
git config core.hooksPath .githooks
```

This project follows this pattern. See `.githooks/` directory for working examples.

### Creating a Basic Pre-Commit Hook

**Use case**: Validate bash scripts before committing.

**1. Create hook file**:
```bash
touch .githooks/pre-commit
chmod +x .githooks/pre-commit
```

**2. Add validation logic**:
```bash
#!/bin/bash
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
```

**Key patterns**:
- Use `set -e` to fail fast on errors
- Check for staged files with `git diff --cached`
- Exit early if no relevant files
- Provide clear visual feedback with emojis
- Exit with non-zero on validation failure

### Modular Hook Architecture

**Problem**: Single hook file becomes complex with multiple validations.

**Solution**: Orchestrator pattern that discovers and runs modular hook scripts.

**1. Create hooks.d/ directory**:
```bash
mkdir .githooks/hooks.d
```

**2. Create orchestrator in pre-commit**:
```bash
#!/bin/bash
set -e

HOOKS_DIR="$(dirname "$0")/hooks.d"

if [ -d "$HOOKS_DIR" ]; then
    for hook in "$HOOKS_DIR"/*; do
        if [ -x "$hook" ]; then
            echo "Running: $(basename "$hook")"
            "$hook" || exit 1
        fi
    done
fi

exit 0
```

**3. Add individual validation scripts**:
```bash
# .githooks/hooks.d/10-validate-bash.sh
# .githooks/hooks.d/20-validate-yaml.sh
# .githooks/hooks.d/30-run-tests.sh
```

**Naming convention**: Use numbered prefixes (10, 20, 30) to control execution order and allow inserting new hooks between existing ones (e.g., add a hypothetical `15-validate-json.sh` between 10 and 20).

This project uses this pattern. See `.githooks/hooks.d/` for examples.

### Validating Commit Messages

**Use case**: Enforce conventional commit format.

**Create commit-msg hook**:
```bash
#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Pattern: type(scope): description
PATTERN="^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{10,}$"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo "❌ Invalid commit message format"
    echo ""
    echo "Expected format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(auth): add OAuth2 login support"
    exit 1
fi

echo "✅ Commit message valid"
exit 0
```

### Running Tests Before Push

**Use case**: Prevent pushing broken code to remote.

**Create pre-push hook**:
```bash
#!/bin/bash
set -e

echo "🧪 Running tests before push..."

# Run test suite
npm test || {
    echo "❌ Tests failed. Push aborted."
    exit 1
}

echo "✅ All tests passed"
exit 0
```

### Preventing Force Push to Main

**Use case**: Protect production branches from destructive operations.

**Create pre-push hook**:
```bash
#!/bin/bash

PROTECTED_BRANCHES="^(main|master|production)$"

while read local_ref local_sha remote_ref remote_sha; do
    remote_branch=$(echo "$remote_ref" | sed 's/refs\/heads\///')
    
    if echo "$remote_branch" | grep -qE "$PROTECTED_BRANCHES"; then
        # Check if it's a force push
        if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
            echo "❌ Deleting $remote_branch is not allowed"
            exit 1
        fi
        
        # Check for force push
        if ! git merge-base --is-ancestor "$remote_sha" "$local_sha" 2>/dev/null; then
            echo "❌ Force push to $remote_branch is not allowed"
            exit 1
        fi
    fi
done

exit 0
```

## Project-Specific Implementation

This repository implements a production-ready Git hooks system. Follow this implementation pattern for your projects.

### Directory Structure

```
.githooks/
├── pre-commit                    # Orchestrator script
├── hooks.d/                      # Individual validation scripts
│   ├── the-perfect-developer-base-collection-10-validate-bash.sh
│   └── the-perfect-developer-base-collection-20-validate-skills.sh
└── README.md                     # Documentation
```

### Installation

**Automated setup**:
```bash
./setup-hooks.sh
```

This configures `git config core.hooksPath .githooks` automatically.

### Hook Naming Convention

Use this pattern for modular hooks:
```
the-perfect-developer-base-collection-<number>-<description>.sh
```

- **Prefix**: Project/team identifier
- **Number**: Execution order (increments of 10: 10, 20, 30...)
- **Description**: What the hook validates

Increments of 10 allow inserting new hooks between existing ones (e.g., add `15-validate-json.sh` between 10 and 20).

### Testing Individual Hooks

Run hooks independently for testing:

```bash
# Test single hook
.githooks/hooks.d/10-validate-bash.sh

# Test orchestrator
.githooks/pre-commit

# Temporarily disable a hook
chmod -x .githooks/hooks.d/20-validate-skills.sh
# Or rename with .disabled extension
mv .githooks/hooks.d/20-validate-skills.sh{,.disabled}
```

### Hook Template

Use this template for new validation hooks:

```bash
#!/bin/bash
set -e

echo "🔍 Running [VALIDATION NAME]..."

# Get staged files matching pattern
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep 'pattern' || true)

if [ -z "$STAGED_FILES" ]; then
    echo "✅ No files to validate"
    exit 0
fi

# Validation logic
for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        echo "Validating $file..."
        # Add validation command here
        # validation-command "$file" || exit 1
    fi
done

echo "✅ Validation passed"
exit 0
```

## Hook Parameters and Environment

### Common Parameters

Different hooks receive different parameters:

**pre-commit**: No parameters
```bash
#!/bin/bash
# Access staged files via git commands
STAGED=$(git diff --cached --name-only)
```

**commit-msg**: Commit message file path
```bash
#!/bin/bash
COMMIT_MSG_FILE=$1
message=$(cat "$COMMIT_MSG_FILE")
```

**pre-push**: stdin with refs being pushed
```bash
#!/bin/bash
while read local_ref local_sha remote_ref remote_sha; do
    # Process each ref
done
```

**post-checkout**: prev HEAD, new HEAD, branch flag
```bash
#!/bin/bash
PREV_HEAD=$1
NEW_HEAD=$2
IS_BRANCH=$3  # 1 for branch checkout, 0 for file checkout
```

### Environment Variables

Git sets environment variables hooks can access:

- `GIT_DIR` - Path to .git directory
- `GIT_WORK_TREE` - Path to working directory
- `GIT_INDEX_FILE` - Path to index file
- `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL` - Commit author
- `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL` - Committer info

**Test environment variables**:
```bash
#!/bin/bash
echo "Running $BASH_SOURCE"
set | grep GIT
echo "PWD is $PWD"
```

## Best Practices

**DO**:
- Make hooks fast—developers run them frequently
- Exit early when no relevant files are staged
- Provide clear, actionable error messages
- Use visual indicators (✅ ❌ 🔍) for quick scanning
- Version-control hooks using `core.hooksPath`
- Test hooks independently before integration
- Document hook behavior in README
- Use modular architecture for complex validation
- Make hooks easy to temporarily disable

**DON'T**:
- Perform long-running operations in pre-commit
- Block commits without clear explanation
- Hardcode file paths—use relative paths
- Assume dependencies are installed—check first
- Create infinite loops or complex recursion
- Mix multiple concerns in one hook script
- Skip error handling and validation
- Force hooks on team without consensus

## Security Considerations

**Validate inputs**: Never trust user input in hooks
```bash
# Bad: Command injection risk
git diff --cached --name-only | xargs some-command

# Good: Proper quoting and validation
git diff --cached --name-only | while read file; do
    if [ -f "$file" ]; then
        some-command "$file"
    fi
done
```

**Check permissions**: Ensure hooks are executable by intended users only
```bash
chmod 755 .githooks/pre-commit  # Owner write, others read+execute
```

**Avoid secrets**: Never hardcode credentials in hooks
```bash
# Bad: Hardcoded token
API_TOKEN="secret123"

# Good: Read from environment
API_TOKEN="${API_TOKEN:-$(cat ~/.api_token)}"
```

**Review third-party hooks**: Understand what scripts do before using them.

## Troubleshooting

**Hook not running**:
1. Check execute permissions: `ls -l .githooks/pre-commit`
2. Verify `core.hooksPath` config: `git config core.hooksPath`
3. Ensure file has no `.sample` extension
4. Check shebang line is correct: `#!/bin/bash`

**Hook runs but fails unexpectedly**:
1. Run hook manually to see errors: `.githooks/pre-commit`
2. Check exit codes: `echo $?` after running
3. Verify dependencies are installed
4. Test with minimal staged changes
5. Add debug output: `set -x` at start of script

**Cannot commit**:
1. Read hook error message carefully
2. Fix validation issues or unstage problematic files
3. Temporarily disable hook if needed: `git commit --no-verify`
4. Note: `--no-verify` bypasses all hooks—use sparingly

**Hooks not version-controlled**:
1. Ensure using `core.hooksPath`, not `.git/hooks/`
2. Verify `.githooks/` is committed: `git ls-files .githooks/`
3. Check team members ran setup: `git config core.hooksPath`

## Additional Resources

### Reference Documentation

For detailed information on advanced topics:
- **`references/hook-types.md`** - Complete list of all Git hooks with parameters and use cases
- **`references/server-side-hooks.md`** - Server-side hooks for CI/CD and policy enforcement
- **`references/advanced-patterns.md`** - Complex validation patterns and techniques
- **`references/ci-cd-integration.md`** - Integrating hooks with continuous integration pipelines

### Example Implementations

Working examples from this project:
- **`examples/modular-pre-commit/`** - Orchestrator pattern with hooks.d/ directory
- **`examples/validate-bash.sh`** - Bash syntax validation hook
- **`examples/validate-skills.sh`** - SKILL.md validation hook
- **`examples/setup-hooks.sh`** - Installation script for team setup

### External Resources

Official Git documentation:
- [Git Hooks Documentation](https://git-scm.com/docs/githooks) - Complete reference
- [Git Hooks Guide](https://githooks.com) - Community-maintained guide

Comprehensive tutorials:
- [Kinsta Git Hooks Guide](https://kinsta.com/blog/git-hooks/) - Advanced techniques
- [Atlassian Git Hooks Tutorial](https://www.atlassian.com/git/tutorials/git-hooks) - Conceptual overview

## Quick Reference

**Configure version-controlled hooks**:
```bash
git config core.hooksPath .githooks
```

**Make hook executable**:
```bash
chmod +x .githooks/pre-commit
```

**Test hook manually**:
```bash
.githooks/pre-commit
```

**Bypass hooks temporarily**:
```bash
git commit --no-verify
```

**Common hook skeleton**:
```bash
#!/bin/bash
set -e
echo "🔍 Running validation..."
# Validation logic here
echo "✅ Validation passed"
exit 0
```

**Get staged files**:
```bash
git diff --cached --name-only --diff-filter=ACM
```

**Validate and exit on failure**:
```bash
command || exit 1
```
