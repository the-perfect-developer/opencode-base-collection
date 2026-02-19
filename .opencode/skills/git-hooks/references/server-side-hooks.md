# Server-Side Git Hooks

Server-side hooks enforce policies and trigger automation on the remote repository. Unlike client-side hooks, they cannot be bypassed.

## Overview

Server-side hooks run on the Git server (GitHub, GitLab, Bitbucket, or self-hosted) when developers push code. They provide:

- **Mandatory enforcement** - Cannot be bypassed with `--no-verify`
- **Centralized control** - Single point of policy enforcement
- **Post-push automation** - CI/CD triggers, deployments, notifications

## Architecture

```
Developer → git push → Server receives → pre-receive → update (per ref) → [Update refs] → post-receive → post-update
                                  ↓                        ↓                                  ↓
                              Can reject              Can reject                      Cannot reject
                              entire push             single ref                      (push complete)
```

## Hook Locations

**On server**:
```
repository.git/hooks/
├── pre-receive
├── update
├── post-receive
└── post-update
```

**Important**: These hooks live on the bare repository (`.git` directory), not in the working tree.

## Pre-Receive Hook

Runs before any refs are updated. Receives all refs being pushed via stdin.

### Parameters

- **Arguments**: None
- **stdin**: One line per ref:
  ```
  <old-object-sha> <new-object-sha> <ref-name>
  ```
- **Exit code**: Non-zero aborts entire push

### Use Cases

#### 1. Enforce Commit Message Format

```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    # Skip branch deletions
    if [ "$new_sha" = "0000000000000000000000000000000000000000" ]; then
        continue
    fi
    
    # Get commits to check
    if [ "$old_sha" = "0000000000000000000000000000000000000000" ]; then
        # New branch - check all reachable commits
        range="$new_sha"
    else
        # Existing branch - check new commits
        range="$old_sha..$new_sha"
    fi
    
    # Validate each commit message
    for commit in $(git rev-list "$range"); do
        message=$(git log -1 --pretty=%B "$commit")
        
        # Check Conventional Commits format
        if ! echo "$message" | head -n1 | grep -qE "^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+$"; then
            cat <<EOF
❌ Push rejected: Invalid commit message in $commit

All commits must follow Conventional Commits format:
  type(scope): description

Examples:
  feat(api): add user authentication
  fix(ui): correct button alignment
  docs: update API documentation

Current message:
$message
EOF
            exit 1
        fi
    done
done

exit 0
```

#### 2. Prevent Large Files

```bash
#!/bin/bash

MAX_SIZE=$((10 * 1024 * 1024))  # 10MB in bytes

while read old_sha new_sha ref_name; do
    # Skip deletions
    [ "$new_sha" = "0000000000000000000000000000000000000000" ] && continue
    
    # Get commits to check
    if [ "$old_sha" = "0000000000000000000000000000000000000000" ]; then
        range="$new_sha"
    else
        range="$old_sha..$new_sha"
    fi
    
    # Check each commit for large files
    for commit in $(git rev-list "$range"); do
        # Get files in this commit
        for file_hash in $(git diff-tree --no-commit-id --name-only -r "$commit"); do
            file_size=$(git cat-file -s "$commit:$file_hash" 2>/dev/null || echo 0)
            
            if [ "$file_size" -gt "$MAX_SIZE" ]; then
                size_mb=$((file_size / 1024 / 1024))
                echo "❌ Push rejected: File '$file_hash' is ${size_mb}MB (max 10MB)"
                echo "Commit: $commit"
                echo ""
                echo "Consider using Git LFS for large files:"
                echo "  https://git-lfs.github.com"
                exit 1
            fi
        done
    done
done

exit 0
```

#### 3. Require Signed Commits

```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    [ "$new_sha" = "0000000000000000000000000000000000000000" ] && continue
    
    if [ "$old_sha" = "0000000000000000000000000000000000000000" ]; then
        range="$new_sha"
    else
        range="$old_sha..$new_sha"
    fi
    
    for commit in $(git rev-list "$range"); do
        # Check if commit is signed
        if ! git verify-commit "$commit" 2>/dev/null; then
            echo "❌ Push rejected: Commit $commit is not signed"
            echo ""
            echo "All commits must be GPG signed."
            echo "Configure Git to sign commits:"
            echo "  git config user.signingkey <key-id>"
            echo "  git config commit.gpgsign true"
            exit 1
        fi
    done
done

exit 0
```

#### 4. Enforce Linear History (No Merge Commits)

```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    [ "$new_sha" = "0000000000000000000000000000000000000000" ] && continue
    
    if [ "$old_sha" = "0000000000000000000000000000000000000000" ]; then
        range="$new_sha"
    else
        range="$old_sha..$new_sha"
    fi
    
    # Check for merge commits
    merge_commits=$(git rev-list --merges "$range")
    
    if [ -n "$merge_commits" ]; then
        echo "❌ Push rejected: Merge commits not allowed"
        echo ""
        echo "This repository requires linear history."
        echo "Use rebase instead of merge:"
        echo "  git pull --rebase origin main"
        echo "  git rebase origin/main"
        exit 1
    fi
done

exit 0
```

### Best Practices

**Fast execution**: pre-receive blocks the push, so keep it fast
```bash
# Bad: Slow, checks every commit independently
for commit in $(git rev-list "$range"); do
    git show "$commit" | some-slow-linter
done

# Good: Batch process or check only changed files
git diff "$old_sha" "$new_sha" --name-only | xargs some-fast-linter
```

**Clear error messages**: Help developers fix issues
```bash
# Bad
echo "Invalid commit"
exit 1

# Good
cat <<EOF
❌ Push rejected: Invalid commit message

Expected format: type(scope): description
  
Your commit: $commit
Message: $(git log -1 --pretty=%B "$commit")

Fix with:
  git rebase -i origin/main
  # Edit commit message
  git push
EOF
exit 1
```

**Handle edge cases**:
```bash
# New branch (old_sha is all zeros)
if [ "$old_sha" = "0000000000000000000000000000000000000000" ]; then
    range="$new_sha"
    
# Branch deletion (new_sha is all zeros)
elif [ "$new_sha" = "0000000000000000000000000000000000000000" ]; then
    continue  # Skip deletions or enforce deletion policy
    
# Regular push
else
    range="$old_sha..$new_sha"
fi
```

## Update Hook

Runs once per ref being updated, after pre-receive but before refs are modified.

### Parameters

- **Arguments**:
  1. `$1` - Ref name (e.g., `refs/heads/main`)
  2. `$2` - Old object SHA
  3. `$3` - New object SHA
- **stdin**: None
- **Exit code**: Non-zero rejects only this ref (others may still succeed)

### Use Cases

#### 1. Branch-Specific Protection

```bash
#!/bin/bash

REF_NAME=$1
OLD_SHA=$2
NEW_SHA=$3

# Extract branch name
BRANCH=$(echo "$REF_NAME" | sed 's|refs/heads/||')

# Protect main branch
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    
    # Allow fast-forward only
    if [ "$OLD_SHA" != "0000000000000000000000000000000000000000" ]; then
        if ! git merge-base --is-ancestor "$OLD_SHA" "$NEW_SHA"; then
            echo "❌ Non-fast-forward push to $BRANCH is not allowed"
            echo "Use pull requests to update protected branches"
            exit 1
        fi
    fi
    
    # Prevent deletion
    if [ "$NEW_SHA" = "0000000000000000000000000000000000000000" ]; then
        echo "❌ Deleting $BRANCH is not allowed"
        exit 1
    fi
fi

exit 0
```

#### 2. Enforce Branch Naming Convention

```bash
#!/bin/bash

REF_NAME=$1
OLD_SHA=$2
NEW_SHA=$3

# Only check new branches
if [ "$OLD_SHA" = "0000000000000000000000000000000000000000" ]; then
    BRANCH=$(echo "$REF_NAME" | sed 's|refs/heads/||')
    
    # Allow main/master
    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        exit 0
    fi
    
    # Enforce naming: feature/, fix/, hotfix/, release/
    if ! echo "$BRANCH" | grep -qE '^(feature|fix|hotfix|release)/[a-z0-9-]+$'; then
        cat <<EOF
❌ Invalid branch name: $BRANCH

Branch names must follow the pattern:
  feature/description  - New features
  fix/description      - Bug fixes
  hotfix/description   - Production hotfixes
  release/version      - Release branches

Examples:
  feature/user-auth
  fix/login-redirect
  hotfix/security-patch
  release/v1.2.0
EOF
        exit 1
    fi
fi

exit 0
```

#### 3. Require Review Approval

```bash
#!/bin/bash

REF_NAME=$1
OLD_SHA=$2
NEW_SHA=$3

BRANCH=$(echo "$REF_NAME" | sed 's|refs/heads/||')

# Require approval for protected branches
if echo "$BRANCH" | grep -qE '^(main|master|production)$'; then
    
    # Check for review approval in commit messages
    # (This is simplified - real implementation would check external review system)
    for commit in $(git rev-list "$OLD_SHA..$NEW_SHA"); do
        message=$(git log -1 --pretty=%B "$commit")
        
        if ! echo "$message" | grep -q "Reviewed-by:"; then
            echo "❌ All commits to $BRANCH must be reviewed"
            echo "Missing 'Reviewed-by:' trailer in commit $commit"
            exit 1
        fi
    done
fi

exit 0
```

### Difference from pre-receive

| Feature | pre-receive | update |
|---------|-------------|--------|
| Execution | Once per push | Once per ref |
| Granularity | All-or-nothing | Per-branch control |
| Parameters | Via stdin | Via arguments |
| Use case | Global policies | Branch-specific rules |

## Post-Receive Hook

Runs after all refs successfully updated. Perfect for triggering automation.

### Parameters

- **Arguments**: None
- **stdin**: Same as pre-receive:
  ```
  <old-sha> <new-sha> <ref-name>
  ```
- **Exit code**: Ignored (push already completed)

### Use Cases

#### 1. Trigger CI/CD Pipeline

```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    branch=$(echo "$ref_name" | sed 's|refs/heads/||')
    
    # Trigger CI for main branch
    if [ "$branch" = "main" ]; then
        echo "Triggering CI/CD for main branch..."
        
        curl -X POST "https://ci.example.com/api/builds" \
            -H "Authorization: Bearer ${CI_API_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "{
                \"project\": \"my-project\",
                \"branch\": \"main\",
                \"commit\": \"$new_sha\"
            }"
    fi
    
    # Deploy staging for develop branch
    if [ "$branch" = "develop" ]; then
        echo "Deploying to staging..."
        ssh deploy@staging.example.com "cd /app && git pull && ./deploy.sh"
    fi
done

exit 0
```

#### 2. Send Notifications

```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    branch=$(echo "$ref_name" | sed 's|refs/heads/||')
    
    # Get commit details
    author=$(git log -1 --pretty=%an "$new_sha")
    message=$(git log -1 --pretty=%s "$new_sha")
    commit_url="https://github.com/user/repo/commit/$new_sha"
    
    # Send Slack notification
    curl -X POST "$SLACK_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"text\": \"New push to *$branch*\",
            \"attachments\": [{
                \"color\": \"good\",
                \"fields\": [
                    {\"title\": \"Author\", \"value\": \"$author\", \"short\": true},
                    {\"title\": \"Branch\", \"value\": \"$branch\", \"short\": true},
                    {\"title\": \"Message\", \"value\": \"$message\"}
                ],
                \"actions\": [{
                    \"type\": \"button\",
                    \"text\": \"View Commit\",
                    \"url\": \"$commit_url\"
                }]
            }]
        }"
done

exit 0
```

#### 3. Update Issue Tracker

```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    branch=$(echo "$ref_name" | sed 's|refs/heads/||')
    
    # Check commits for issue references
    for commit in $(git rev-list "$old_sha..$new_sha"); do
        message=$(git log -1 --pretty=%B "$commit")
        
        # Extract issue numbers (e.g., "fixes #123", "closes JIRA-456")
        for issue in $(echo "$message" | grep -oE '(fixes|closes|resolves) #[0-9]+' | grep -oE '#[0-9]+' | tr -d '#'); do
            
            echo "Adding comment to issue #$issue"
            
            curl -X POST "https://api.github.com/repos/user/repo/issues/$issue/comments" \
                -H "Authorization: token ${GITHUB_TOKEN}" \
                -H "Content-Type: application/json" \
                -d "{
                    \"body\": \"Referenced in commit $commit\"
                }"
        done
    done
done

exit 0
```

#### 4. Deploy to Production

```bash
#!/bin/bash

while read old_sha new_sha ref_name; do
    branch=$(echo "$ref_name" | sed 's|refs/heads/||')
    
    # Auto-deploy production on tag push
    if echo "$ref_name" | grep -q '^refs/tags/v'; then
        tag=$(echo "$ref_name" | sed 's|refs/tags/||')
        
        echo "Deploying version $tag to production..."
        
        # Clone to temp directory
        DEPLOY_DIR=$(mktemp -d)
        git clone --branch "$tag" --depth 1 "$(pwd)" "$DEPLOY_DIR"
        
        # Run deployment
        cd "$DEPLOY_DIR"
        ./scripts/deploy-production.sh
        
        # Send notification
        curl -X POST "$SLACK_WEBHOOK_URL" \
            -d "{\"text\":\"🚀 Deployed $tag to production\"}"
        
        # Cleanup
        rm -rf "$DEPLOY_DIR"
    fi
done

exit 0
```

### Best Practices

**Background tasks**: Long-running tasks should be backgrounded
```bash
# Bad: Blocks until deployment completes
./deploy.sh

# Good: Background with logging
{
    ./deploy.sh > /var/log/deploy.log 2>&1
    echo "Deployment finished: $(date)" >> /var/log/deploy.log
} &
```

**Error handling**: Log failures, don't abort (push already succeeded)
```bash
if ! trigger_ci "$commit"; then
    echo "Warning: Failed to trigger CI for $commit" >&2
    # Log error but continue
fi
```

**Security**: Use environment variables for secrets
```bash
# Bad: Hardcoded token
TOKEN="abc123secret"

# Good: Environment variable
TOKEN="${CI_API_TOKEN:-}"
if [ -z "$TOKEN" ]; then
    echo "Warning: CI_API_TOKEN not set, skipping CI trigger" >&2
    exit 0
fi
```

## Post-Update Hook

Similar to post-receive but less commonly used. Receives ref names as arguments instead of stdin.

### Parameters

- **Arguments**: List of ref names that were updated
- **stdin**: None
- **Exit code**: Ignored

### Example

```bash
#!/bin/bash

echo "Updated refs:"
for ref in "$@"; do
    echo "  - $ref"
    
    # Update ref advertisement for dumb HTTP transport
    git update-server-info
done

exit 0
```

**Note**: Most use cases are better served by `post-receive` which provides more information via stdin.

## Installation on Server

### Bare Repository (Typical Server Setup)

```bash
# On server
cd /path/to/repo.git/hooks

# Create hook
cat > pre-receive <<'EOF'
#!/bin/bash
# Hook content here
EOF

# Make executable
chmod +x pre-receive

# Test
./pre-receive < test-input.txt
```

### GitHub/GitLab/Bitbucket

**GitHub**: Use webhooks + Actions instead of hooks
```yaml
# .github/workflows/push.yml
on: push
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: ./validate.sh
```

**GitLab**: Server-side hooks in `/opt/gitlab/embedded/service/gitlab-shell/hooks/`

**Bitbucket**: Hooks configured via web UI or Bamboo integration

## Testing Server-Side Hooks

### Local Testing

```bash
# Simulate pre-receive input
echo "old-sha new-sha refs/heads/main" | ./hooks/pre-receive

# Test with actual commits
git rev-parse HEAD~1 HEAD refs/heads/main | tr '\n' ' ' | echo | ./hooks/pre-receive
```

### Test Repository

```bash
# Create test bare repo
mkdir test-repo.git
cd test-repo.git
git init --bare

# Install hook
cp ~/pre-receive hooks/
chmod +x hooks/pre-receive

# Push to test
cd ~/my-project
git remote add test /path/to/test-repo.git
git push test main
```

## Troubleshooting

**Hook not executing**:
```bash
# Check permissions
ls -l hooks/pre-receive
# Should be: -rwxr-xr-x

# Check shebang
head -n1 hooks/pre-receive
# Should be: #!/bin/bash or #!/bin/sh

# Test manually
echo "old new ref" | hooks/pre-receive
```

**Hook fails silently**:
```bash
# Add logging
#!/bin/bash
exec 2>> /var/log/git-hooks.log
set -x  # Debug mode
```

**Environment issues**:
```bash
# Server hooks run in restricted environment
# Set PATH explicitly
export PATH=/usr/local/bin:/usr/bin:/bin

# Load environment if needed
source /etc/profile
```

## Security Considerations

**Validate all input**:
```bash
# Never trust ref names or SHAs
if ! echo "$ref_name" | grep -qE '^refs/(heads|tags)/[a-zA-Z0-9/_-]+$'; then
    echo "Invalid ref name"
    exit 1
fi
```

**Avoid command injection**:
```bash
# Bad: Command injection risk
commit_msg=$(git log -1 --pretty=%B "$sha")
eval "$commit_msg"  # NEVER DO THIS

# Good: Safe handling
commit_msg=$(git log -1 --pretty=%B "$sha")
if echo "$commit_msg" | grep -q "pattern"; then
    # Safe processing
fi
```

**Limit resource usage**:
```bash
# Timeout long operations
timeout 30s git rev-list "$range" || {
    echo "Hook timed out"
    exit 1
}

# Limit commits checked
commit_count=$(git rev-list --count "$range")
if [ "$commit_count" -gt 1000 ]; then
    echo "Push too large, max 1000 commits"
    exit 1
fi
```
