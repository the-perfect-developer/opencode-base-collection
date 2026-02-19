# GitHub Actions Security Guide

Security best practices for GitHub Actions workflows including secrets management, OIDC, and permissions.

## Table of Contents

- [Secrets Management](#secrets-management)
- [Token Permissions](#token-permissions)
- [OpenID Connect (OIDC)](#openid-connect-oidc)
- [Pull Request Security](#pull-request-security)
- [Dependency Security](#dependency-security)
- [Action Security](#action-security)
- [Environment Protection](#environment-protection)

## Secrets Management

### Creating and Using Secrets

**Repository secrets**:
1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name must not start with `GITHUB_` or a number
4. Use UPPER_SNAKE_CASE convention

**Access secrets in workflows**:
```yaml
steps:
  - name: Deploy
    env:
      API_TOKEN: ${{ secrets.API_TOKEN }}
      DATABASE_URL: ${{ secrets.DATABASE_URL }}
    run: ./deploy.sh
```

### Secret Scopes

**Repository secrets**:
- Available to all workflows in repository
- Use for repository-specific credentials

**Environment secrets**:
- Tied to deployment environments
- Require environment protection rules
- Override repository secrets with same name

```yaml
jobs:
  deploy:
    environment: production
    steps:
      - env:
          API_KEY: ${{ secrets.API_KEY }}  # Uses production environment secret
        run: ./deploy.sh
```

**Organization secrets**:
- Shared across repositories in organization
- Set visibility: all repos, private repos, or selected repos
- Good for shared credentials like registry tokens

### Secret Best Practices

**DO**:
- Use minimal secret scopes
- Rotate secrets regularly
- Use environment secrets for deployments
- Mask sensitive output with `::add-mask::`
- Use OIDC instead of long-lived credentials when possible

**DON'T**:
- Echo secrets in logs
- Pass secrets as command-line arguments
- Store secrets in repository code
- Use secrets in fork pull requests without protection

**Masking sensitive values**:
```yaml
- name: Mask dynamic secret
  run: |
    SECRET_VALUE=$(cat secret.txt)
    echo "::add-mask::$SECRET_VALUE"
    echo "SECRET_VALUE=$SECRET_VALUE" >> $GITHUB_ENV
```

### Secrets in Pull Requests

**Fork PRs have limited secret access**:
- Secrets not available by default in `pull_request` from forks
- Use `pull_request_target` with caution (runs in base branch context)
- Require approval for first-time contributors

**Safe fork PR pattern**:
```yaml
on:
  pull_request_target:
    types: [labeled]

jobs:
  test:
    if: contains(github.event.pull_request.labels.*.name, 'safe-to-test')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - run: npm test
```

## Token Permissions

### GITHUB_TOKEN Scopes

The `GITHUB_TOKEN` is automatically created for each workflow run.

**Default permissions** (permissive):
- `contents: write`
- `metadata: read`

**Restrict globally** in repository settings:
Settings → Actions → General → Workflow permissions → Read repository contents permission

**Restrict per workflow**:
```yaml
permissions:
  contents: read
  pull-requests: write
  issues: write
```

**Restrict per job**:
```yaml
jobs:
  build:
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
  
  comment:
    permissions:
      pull-requests: write
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({...})
```

### Available Permission Scopes

| Scope | Purpose |
|-------|---------|
| `actions` | Workflow runs and artifacts |
| `checks` | Check runs and suites |
| `contents` | Repository contents, commits, branches, tags |
| `deployments` | Deployment statuses |
| `discussions` | Repository discussions |
| `id-token` | OIDC token for cloud authentication |
| `issues` | Issues and labels |
| `packages` | GitHub Packages |
| `pages` | GitHub Pages |
| `pull-requests` | Pull requests |
| `repository-projects` | Classic projects |
| `security-events` | Code scanning and secret scanning |
| `statuses` | Commit statuses |

**Access levels**: `read`, `write`, `none`

### Principle of Least Privilege

**Example: Read-only CI**:
```yaml
permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

**Example: PR comments only**:
```yaml
permissions:
  contents: read
  pull-requests: write

jobs:
  comment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: 'Tests passed!'
            })
```

## OpenID Connect (OIDC)

OIDC allows workflows to authenticate with cloud providers without long-lived credentials.

### Benefits

- No stored credentials
- Short-lived tokens
- Fine-grained permissions
- Automatic rotation

### AWS Authentication

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
        aws-region: us-east-1
    
    - run: |
        aws s3 sync ./dist s3://my-bucket
        aws cloudfront create-invalidation --distribution-id E1234567890ABC --paths "/*"
```

**AWS IAM Role Trust Policy**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:owner/repo:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

### Azure Authentication

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: azure/login@v1
      with:
        client-id: ${{ secrets.AZURE_CLIENT_ID }}
        tenant-id: ${{ secrets.AZURE_TENANT_ID }}
        subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
    
    - run: |
        az webapp up --name my-app --resource-group my-rg
```

### Google Cloud Authentication

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/github/providers/github'
        service_account: 'github-actions@project-id.iam.gserviceaccount.com'
    
    - uses: google-github-actions/setup-gcloud@v2
    
    - run: |
        gcloud app deploy
```

### OIDC Claims Customization

Restrict by repository, branch, or environment:

```yaml
# AWS IAM condition
"Condition": {
  "StringEquals": {
    "token.actions.githubusercontent.com:sub": "repo:owner/repo:environment:production"
  }
}

# Or by branch
"Condition": {
  "StringLike": {
    "token.actions.githubusercontent.com:sub": "repo:owner/repo:ref:refs/heads/main"
  }
}
```

## Pull Request Security

### Fork PR Risks

**Risks**:
- Malicious code in workflow runs
- Secret exposure
- Token privilege escalation
- Resource abuse

### Safe Fork PR Patterns

**Pattern 1: Separate build and test jobs**:
```yaml
on:
  pull_request_target:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
          persist-credentials: false
      
      - run: npm ci
      - run: npm run build
      
      - uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: build
      
      - run: npm test
```

**Pattern 2: Label-based approval**:
```yaml
on:
  pull_request_target:
    types: [labeled]

jobs:
  test:
    if: contains(github.event.pull_request.labels.*.name, 'approved-for-ci')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - run: npm test
```

**Pattern 3: Require first-time contributor approval**:

Enable in repository settings:
Settings → Actions → General → Fork pull request workflows → Require approval for first-time contributors

### Checkout Security

**Unsafe** (checks out fork with write token):
```yaml
- uses: actions/checkout@v4
  # Dangerous in pull_request_target!
```

**Safe** (checks out fork without credentials):
```yaml
- uses: actions/checkout@v4
  with:
    ref: ${{ github.event.pull_request.head.sha }}
    persist-credentials: false
```

## Dependency Security

### Action Pinning

**DO pin to commit SHA**:
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

**Advantages**:
- Immutable reference
- Protection against tag moving
- Supply chain security

**DON'T use mutable references in production**:
```yaml
- uses: actions/checkout@v4  # Tag can be moved
- uses: actions/checkout@main  # Branch can change
```

**Use Dependabot to update pinned actions**:

`.github/dependabot.yml`:
```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    groups:
      actions:
        patterns:
          - "*"
```

### Dependency Scanning

**Scan for vulnerabilities**:
```yaml
name: Dependency Scan

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  scan:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm audit --audit-level=moderate
    
    - name: Snyk scan
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

## Action Security

### Reviewing Actions

Before using third-party actions:
1. Check source code repository
2. Review permissions required
3. Check maintenance status
4. Look for security audits
5. Prefer official or verified actions

### Restricted Actions

Limit which actions can run:

Repository settings → Actions → General → Actions permissions

Options:
- Allow all actions and reusable workflows
- Allow actions from GitHub and verified creators
- Allow specific actions and reusable workflows

**Example allowlist**:
```
actions/*,
github/*,
aws-actions/*,
azure/*,
google-github-actions/*
```

### Writing Secure Actions

**Validate inputs**:
```yaml
inputs:
  version:
    required: true
    description: Version to deploy

runs:
  using: composite
  steps:
    - run: |
        if [[ ! "${{ inputs.version }}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          echo "Invalid version format"
          exit 1
        fi
      shell: bash
```

**Avoid command injection**:
```yaml
# Bad - vulnerable to injection
- run: echo "User input: ${{ github.event.issue.title }}"

# Good - use environment variables
- env:
    ISSUE_TITLE: ${{ github.event.issue.title }}
  run: echo "User input: $ISSUE_TITLE"
```

## Environment Protection

### Deployment Environments

Create protected environments:

1. Repository Settings → Environments → New environment
2. Configure protection rules:
   - Required reviewers
   - Wait timer
   - Deployment branches

**Use in workflow**:
```yaml
jobs:
  deploy:
    environment:
      name: production
      url: https://example.com
    steps:
      - run: ./deploy.sh
```

### Environment Secrets

Override repository secrets per environment:

```yaml
jobs:
  deploy-staging:
    environment: staging
    steps:
      - env:
          API_URL: ${{ secrets.API_URL }}  # Uses staging API_URL
        run: ./deploy.sh
  
  deploy-production:
    environment: production
    steps:
      - env:
          API_URL: ${{ secrets.API_URL }}  # Uses production API_URL
        run: ./deploy.sh
```

### Branch Protection

Require environments for specific branches:

Environment settings → Deployment branches → Selected branches → Add rule

```
refs/heads/main
refs/tags/v*
```

## Security Scanning

### CodeQL Analysis

```yaml
name: CodeQL

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 0 * * 1'

jobs:
  analyze:
    runs-on: ubuntu-latest
    
    permissions:
      security-events: write
      contents: read
    
    strategy:
      matrix:
        language: [javascript, python]
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: github/codeql-action/init@v3
      with:
        languages: ${{ matrix.language }}
    
    - uses: github/codeql-action/autobuild@v3
    
    - uses: github/codeql-action/analyze@v3
```

### Secret Scanning

Enable in repository settings:
Settings → Security → Code security and analysis → Secret scanning

**Push protection**: Prevents accidental secret commits

**Custom patterns**: Define organization-specific secrets

### Dependency Review

```yaml
name: Dependency Review

on: [pull_request]

permissions:
  contents: read

jobs:
  review:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/dependency-review-action@v4
      with:
        fail-on-severity: moderate
```

## Security Checklist

When creating workflows:

- [ ] Use minimal GITHUB_TOKEN permissions
- [ ] Pin actions to commit SHAs
- [ ] Use OIDC instead of long-lived credentials
- [ ] Protect secrets from fork PRs
- [ ] Enable branch protection for environments
- [ ] Use environment secrets for deployments
- [ ] Validate all user inputs
- [ ] Enable CodeQL scanning
- [ ] Enable secret scanning with push protection
- [ ] Review third-party actions before use
- [ ] Set up Dependabot for action updates
- [ ] Use `pull_request_target` carefully
- [ ] Never echo secrets
- [ ] Rotate secrets regularly
- [ ] Use approval workflows for production deployments

## References

- Security hardening: https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions
- OIDC: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect
- Secrets: https://docs.github.com/en/actions/security-guides/encrypted-secrets
- Permissions: https://docs.github.com/en/actions/security-guides/automatic-token-authentication
