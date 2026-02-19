# Complete Git Hooks Reference

Comprehensive guide to all Git hooks, their parameters, and use cases.

## Table of Contents

- [Client-Side Hooks](#client-side-hooks)
  - [Commit Workflow Hooks](#commit-workflow-hooks)
  - [Email Workflow Hooks](#email-workflow-hooks)
  - [Other Client Hooks](#other-client-hooks)
- [Server-Side Hooks](#server-side-hooks)
- [Hook Parameters Quick Reference](#hook-parameters-quick-reference)

## Client-Side Hooks

Client-side hooks run on developer machines and can be bypassed with `--no-verify`.

### Commit Workflow Hooks

#### pre-commit

**When**: Before commit message editor opens  
**Purpose**: Validate staged changes, run linters, check code style  
**Parameters**: None  
**stdin**: None  
**Can abort**: Yes (exit non-zero)

**Common uses**:
- Run linters (ESLint, Prettier, Black)
- Check code syntax
- Validate file formats
- Run quick unit tests
- Check for debugging statements
- Verify no large files are staged

**Example**:
```bash
#!/bin/bash
set -e

# Lint staged JavaScript files
STAGED_JS=$(git diff --cached --name-only --diff-filter=ACM | grep '\.js$' || true)

if [ -n "$STAGED_JS" ]; then
    echo "$STAGED_JS" | xargs eslint || exit 1
fi

exit 0
```

**Access staged files**:
```bash
# All staged files
git diff --cached --name-only

# Staged files by extension
git diff --cached --name-only --diff-filter=ACM | grep '\.py$'

# Staged files with content
git diff --cached
```

#### prepare-commit-msg

**When**: After default message generated, before editor opens  
**Purpose**: Modify commit message template automatically  
**Parameters**:
1. `$1` - Path to commit message file (read/write)
2. `$2` - Commit message source (`message`, `template`, `merge`, `squash`, `commit`)
3. `$3` - Commit SHA (only if `-c`, `-C`, or `--amend`)

**stdin**: None  
**Can abort**: Yes

**Common uses**:
- Add issue tracker references from branch name
- Insert template based on commit type
- Add co-author lines
- Include affected components

**Example**:
```bash
#!/bin/bash

COMMIT_MSG_FILE=$1
SOURCE=$2

# Extract issue number from branch name
BRANCH=$(git symbolic-ref --short HEAD)
ISSUE=$(echo "$BRANCH" | grep -oE '[A-Z]+-[0-9]+')

if [ -n "$ISSUE" ] && [ "$SOURCE" != "message" ]; then
    # Prepend issue number to existing message
    ORIGINAL=$(cat "$COMMIT_MSG_FILE")
    echo "$ISSUE: $ORIGINAL" > "$COMMIT_MSG_FILE"
fi

exit 0
```

**Commit sources**:
- `message` - User provided with `-m` flag
- `template` - Loaded from template file
- `merge` - Automatic merge commit message
- `squash` - Squash commit message
- `commit` - Using `-c`, `-C`, or `--amend`

#### commit-msg

**When**: After user enters commit message  
**Purpose**: Validate commit message format  
**Parameters**:
1. `$1` - Path to commit message file (read/write)

**stdin**: None  
**Can abort**: Yes

**Common uses**:
- Enforce commit message conventions (Conventional Commits, Angular style)
- Check message length limits
- Validate issue tracker references
- Ensure ticket numbers present
- Spell check commit messages

**Example - Conventional Commits**:
```bash
#!/bin/bash

MSG_FILE=$1
MSG=$(cat "$MSG_FILE")

# Pattern: type(scope): description
PATTERN="^(feat|fix|docs|style|refactor|perf|test|chore)(\(.+\))?: .{10,72}$"

if ! echo "$MSG" | head -n1 | grep -qE "$PATTERN"; then
    cat <<EOF
❌ Invalid commit message format

Expected: type(scope): description

Types:
  feat:     New feature
  fix:      Bug fix
  docs:     Documentation changes
  style:    Code style changes (formatting, semicolons, etc)
  refactor: Code refactoring
  perf:     Performance improvements
  test:     Adding or updating tests
  chore:    Maintenance tasks

Example: feat(auth): add OAuth2 login support
EOF
    exit 1
fi

exit 0
```

#### post-commit

**When**: After commit is created  
**Purpose**: Notifications, logging  
**Parameters**: None  
**stdin**: None  
**Can abort**: No (commit already created)

**Common uses**:
- Send notifications (Slack, email)
- Update project documentation
- Log commit statistics
- Trigger local builds
- Update issue tracker

**Example**:
```bash
#!/bin/bash

# Get commit info
COMMIT_SHA=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B)
AUTHOR=$(git log -1 --pretty=%an)

# Send notification
curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL \
    -H 'Content-Type: application/json' \
    -d "{\"text\":\"New commit by $AUTHOR: $COMMIT_MSG\"}"

exit 0
```

### Email Workflow Hooks

#### applypatch-msg

**When**: Before `git am` applies patch  
**Purpose**: Validate patch commit message  
**Parameters**:
1. `$1` - Path to proposed commit message

**stdin**: None  
**Can abort**: Yes

**Common uses**:
- Ensure patches meet commit message standards
- Add trailers (Signed-off-by, Reviewed-by)

#### pre-applypatch

**When**: After patch applied, before commit created  
**Purpose**: Inspect or test the tree  
**Parameters**: None  
**stdin**: None  
**Can abort**: Yes

**Common uses**:
- Run tests on incoming patches
- Validate patch doesn't break build

#### post-applypatch

**When**: After patch applied and committed  
**Purpose**: Notifications  
**Parameters**: None  
**stdin**: None  
**Can abort**: No

### Other Client Hooks

#### pre-rebase

**When**: Before rebasing  
**Purpose**: Prevent dangerous rebases  
**Parameters**:
1. `$1` - Upstream branch being rebased onto
2. `$2` - Branch being rebased (empty if rebasing current branch)

**stdin**: None  
**Can abort**: Yes

**Common uses**:
- Prevent rebasing published branches
- Warn about rebasing onto wrong branch
- Check for uncommitted changes

**Example**:
```bash
#!/bin/bash

UPSTREAM=$1
BRANCH=${2:-$(git symbolic-ref --short HEAD)}

# Prevent rebasing main branch
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "❌ Rebasing main branch is not allowed"
    exit 1
fi

# Check if branch has been pushed
if git rev-parse --verify "origin/$BRANCH" >/dev/null 2>&1; then
    echo "⚠️  Warning: Branch has been pushed to remote"
    echo "Rebasing published branches can cause problems for collaborators"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

exit 0
```

#### post-rewrite

**When**: After commands that rewrite commits (`git commit --amend`, `git rebase`)  
**Purpose**: Update references, logs  
**Parameters**:
1. `$1` - Command that triggered rewrite (`amend` or `rebase`)

**stdin**: One line per rewritten commit:
```
<old-sha> <new-sha>
```

**Can abort**: No

**Example**:
```bash
#!/bin/bash

COMMAND=$1

while read old_sha new_sha; do
    echo "Commit $old_sha rewritten to $new_sha by $COMMAND"
    # Update custom tracking, logs, etc.
done

exit 0
```

#### post-checkout

**When**: After `git checkout` or `git switch`  
**Purpose**: Adjust working directory, clean up generated files  
**Parameters**:
1. `$1` - Ref of previous HEAD
2. `$2` - Ref of new HEAD
3. `$3` - Branch checkout flag (1 for branch, 0 for file)

**stdin**: None  
**Can abort**: No

**Common uses**:
- Clean up build artifacts
- Update dependencies
- Switch environment configs
- Remove generated files

**Example**:
```bash
#!/bin/bash

PREV_HEAD=$1
NEW_HEAD=$2
IS_BRANCH=$3

if [ "$IS_BRANCH" = "1" ]; then
    echo "Checked out branch"
    
    # Clean Python bytecode
    find . -name '*.pyc' -delete
    find . -name '__pycache__' -type d -delete
    
    # Update dependencies if package.json changed
    if git diff --name-only "$PREV_HEAD" "$NEW_HEAD" | grep -q 'package.json'; then
        echo "package.json changed, updating dependencies..."
        npm install
    fi
fi

exit 0
```

#### post-merge

**When**: After successful merge  
**Purpose**: Update dependencies, restore permissions  
**Parameters**: 
1. `$1` - Squash merge flag (1 if squash merge, 0 otherwise)

**stdin**: None  
**Can abort**: No

**Common uses**:
- Update dependencies after merge
- Restore file permissions
- Clean up conflicts markers
- Rebuild project

**Example**:
```bash
#!/bin/bash

SQUASH=$1

# Check if package files changed
FILES_CHANGED=$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)

if echo "$FILES_CHANGED" | grep -qE 'package\.json|package-lock\.json'; then
    echo "Dependencies changed, running npm install..."
    npm install
fi

if echo "$FILES_CHANGED" | grep -q 'requirements.txt'; then
    echo "Python dependencies changed, updating..."
    pip install -r requirements.txt
fi

exit 0
```

#### pre-push

**When**: Before pushing to remote  
**Purpose**: Validate commits, run tests, prevent force push  
**Parameters**:
1. `$1` - Remote name (e.g., `origin`)
2. `$2` - Remote URL

**stdin**: One line per ref being pushed:
```
<local-ref> <local-sha> <remote-ref> <remote-sha>
```

**Can abort**: Yes

**Common uses**:
- Run test suite before push
- Prevent force push to protected branches
- Validate commit messages
- Check for TODOs or debug code
- Ensure all tests pass

**Example - Prevent force push**:
```bash
#!/bin/bash

REMOTE=$1
URL=$2

PROTECTED_BRANCHES="^(main|master|production|staging)$"

while read local_ref local_sha remote_ref remote_sha; do
    # Extract branch name
    local_branch=$(echo "$local_ref" | sed 's|refs/heads/||')
    remote_branch=$(echo "$remote_ref" | sed 's|refs/heads/||')
    
    # Check if pushing to protected branch
    if echo "$remote_branch" | grep -qE "$PROTECTED_BRANCHES"; then
        
        # Check for branch deletion
        if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
            echo "❌ Deleting $remote_branch is not allowed"
            exit 1
        fi
        
        # Check for force push (non-fast-forward)
        if [ "$remote_sha" != "0000000000000000000000000000000000000000" ]; then
            if ! git merge-base --is-ancestor "$remote_sha" "$local_sha"; then
                echo "❌ Force push to $remote_branch is not allowed"
                echo "Use pull request for non-fast-forward updates"
                exit 1
            fi
        fi
    fi
done

exit 0
```

**Example - Run tests**:
```bash
#!/bin/bash

echo "🧪 Running tests before push..."

npm test || {
    echo "❌ Tests failed. Fix tests before pushing."
    exit 1
}

echo "✅ All tests passed"
exit 0
```

## Server-Side Hooks

Server-side hooks run on the remote repository and cannot be bypassed by clients.

### pre-receive

**When**: Before any refs are updated on server  
**Purpose**: Enforce project policies, validate commits  
**Parameters**: None

**stdin**: One line per ref being updated:
```
<old-sha> <new-sha> <ref-name>
```

**Can abort**: Yes (rejects entire push)

**Common uses**:
- Enforce branch permissions
- Validate commit messages across all commits
- Check code signing
- Enforce linear history
- Prevent large files

**Example**:
```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    # Check all commits in the push
    if [ "$old_sha" = "0000000000000000000000000000000000000000" ]; then
        # New branch, check all commits
        commits=$(git rev-list "$new_sha")
    else
        # Existing branch, check new commits
        commits=$(git rev-list "$old_sha..$new_sha")
    fi
    
    # Validate each commit message
    for commit in $commits; do
        msg=$(git log -1 --pretty=%B "$commit")
        if ! echo "$msg" | head -n1 | grep -qE "^(feat|fix|docs):"; then
            echo "❌ Commit $commit has invalid message format"
            exit 1
        fi
    done
done

exit 0
```

### update

**When**: Once per ref being updated (after pre-receive)  
**Purpose**: Per-branch policy enforcement  
**Parameters**:
1. `$1` - Ref name being updated (e.g., `refs/heads/main`)
2. `$2` - Old object SHA
3. `$3` - New object SHA

**stdin**: None  
**Can abort**: Yes (rejects only this ref)

**Common uses**:
- Branch-specific access control
- Require code review before merge
- Enforce branch naming conventions

**Example**:
```bash
#!/bin/bash

REF_NAME=$1
OLD_SHA=$2
NEW_SHA=$3

# Extract branch name
BRANCH=$(echo "$REF_NAME" | sed 's|refs/heads/||')

# Require feature/ or fix/ prefix for new branches
if [ "$OLD_SHA" = "0000000000000000000000000000000000000000" ]; then
    if ! echo "$BRANCH" | grep -qE '^(feature|fix|hotfix)/'; then
        echo "❌ New branches must start with feature/, fix/, or hotfix/"
        exit 1
    fi
fi

exit 0
```

### post-receive

**When**: After all refs successfully updated  
**Purpose**: Trigger CI/CD, send notifications  
**Parameters**: None

**stdin**: Same as pre-receive:
```
<old-sha> <new-sha> <ref-name>
```

**Can abort**: No (push already complete)

**Common uses**:
- Trigger CI/CD pipeline
- Send email notifications
- Update issue tracker
- Deploy to staging/production
- Update project website

**Example**:
```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    branch=$(echo "$ref_name" | sed 's|refs/heads/||')
    
    if [ "$branch" = "main" ]; then
        echo "Deploying main branch to production..."
        
        # Trigger CI/CD pipeline
        curl -X POST https://ci.example.com/trigger \
            -H "Authorization: Bearer $CI_TOKEN" \
            -d "{\"branch\":\"main\",\"commit\":\"$new_sha\"}"
    fi
done

exit 0
```

### post-update

**When**: After all refs updated (similar to post-receive)  
**Purpose**: Notifications, less commonly used than post-receive  
**Parameters**: Variable - each updated ref name

**stdin**: None  
**Can abort**: No

**Example**:
```bash
#!/bin/bash

# Each argument is a ref that was updated
for ref in "$@"; do
    echo "Updated: $ref"
done

exit 0
```

## Hook Parameters Quick Reference

| Hook | Parameters | stdin | Can Abort |
|------|-----------|-------|-----------|
| `pre-commit` | None | None | Yes |
| `prepare-commit-msg` | msg_file, source, sha | None | Yes |
| `commit-msg` | msg_file | None | Yes |
| `post-commit` | None | None | No |
| `applypatch-msg` | msg_file | None | Yes |
| `pre-applypatch` | None | None | Yes |
| `post-applypatch` | None | None | No |
| `pre-rebase` | upstream, branch | None | Yes |
| `post-rewrite` | command | old-new pairs | No |
| `post-checkout` | prev_head, new_head, flag | None | No |
| `post-merge` | squash_flag | None | No |
| `pre-push` | remote_name, url | ref pairs | Yes |
| `pre-receive` | None | ref triples | Yes |
| `update` | ref, old_sha, new_sha | None | Yes |
| `post-receive` | None | ref triples | No |
| `post-update` | refs... | None | No |

## Testing Hooks

**Print parameters for debugging**:
```bash
#!/bin/bash

echo "Script: $0"
echo "Parameters: $@"
echo "Param count: $#"

for i in "$@"; do
    echo "Param: $i"
done

# Read stdin
while read line; do
    echo "stdin: $line"
done

exit 0
```

**Check environment variables**:
```bash
#!/bin/bash

echo "=== Environment Variables ==="
set | grep GIT
echo "PWD: $PWD"
echo "GIT_DIR: $GIT_DIR"
echo "GIT_WORK_TREE: $GIT_WORK_TREE"

exit 0
```
