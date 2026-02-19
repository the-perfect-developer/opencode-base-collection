---
name: github-actions
description: This skill should be used when the user asks to "create a GitHub Actions workflow", "set up CI/CD", "configure GitHub Actions", "add automated testing", "deploy with GitHub Actions", or needs guidance on GitHub Actions workflows, syntax, or automation.
---

# GitHub Actions Workflow Creation

Create and configure GitHub Actions workflows for CI/CD, automation, testing, and deployment.

## What GitHub Actions Provides

GitHub Actions is a CI/CD platform that automates build, test, and deployment pipelines through configurable workflows triggered by repository events.

**Core capabilities**:
- Continuous integration and deployment
- Automated testing on pull requests
- Package publishing and releases
- Issue and project management automation
- Scheduled tasks and cron jobs
- Multi-platform builds (Linux, Windows, macOS)

**Key concepts**:
- **Workflows** - Automated processes defined in YAML files
- **Events** - Triggers like push, pull_request, schedule
- **Jobs** - Sets of steps running on the same runner
- **Steps** - Individual tasks (scripts or actions)
- **Actions** - Reusable units of code
- **Runners** - Servers executing workflows

## Creating a Workflow

### Basic Workflow Structure

Workflows live in `.github/workflows/` and use YAML syntax:

```yaml
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Run tests
      run: npm test
```

### Workflow File Location

Create workflow files at:
```
.github/workflows/workflow-name.yml
```

Each repository can have multiple workflows for different purposes.

### Essential Components

**1. Workflow name**:
```yaml
name: CI Pipeline
```

**2. Event triggers**:
```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
  workflow_dispatch:  # Manual trigger
```

**3. Jobs definition**:
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

**4. Steps with actions or scripts**:
```yaml
steps:
  - uses: actions/checkout@v4
  - uses: actions/setup-node@v4
    with:
      node-version: '20'
  - run: npm install
  - run: npm test
```

## Common Workflow Patterns

### CI/CD for Node.js

```yaml
name: Node.js CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18, 20, 22]
    
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'npm'
    - run: npm ci
    - run: npm test
```

### Build and Deploy

```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build
      run: npm run build
    
    - name: Deploy
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./dist
```

### Multi-Job Workflow

```yaml
name: Build and Test

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: dist/
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/download-artifact@v4
        with:
          name: build-output
          path: dist/
      - run: npm test
```

## Event Triggers

### Common Events

| Event | Usage | Example |
|-------|-------|---------|
| `push` | Code pushed to branches | `on: push` |
| `pull_request` | PR opened/updated | `on: pull_request` |
| `workflow_dispatch` | Manual trigger | `on: workflow_dispatch` |
| `schedule` | Cron schedule | `on: schedule` |
| `release` | Release created | `on: release` |
| `issues` | Issue activity | `on: issues` |

### Event Configuration

**Branch filters**:
```yaml
on:
  push:
    branches:
      - main
      - 'releases/**'
```

**Path filters**:
```yaml
on:
  push:
    paths:
      - 'src/**'
      - '**.js'
```

**Schedule (cron)**:
```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
```

**Multiple events**:
```yaml
on:
  push:
    branches: [ main ]
  pull_request:
  workflow_dispatch:
```

## Jobs and Steps

### Job Configuration

**Basic job**:
```yaml
jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Hello"
```

**Job dependencies**:
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: npm run build
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: npm test
```

**Conditional jobs**:
```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: ./deploy.sh
```

### Matrix Builds

Run jobs with multiple configurations:

```yaml
jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [18, 20, 22]
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
```

### Environment Variables

**Repository secrets**:
```yaml
steps:
  - name: Deploy
    env:
      API_KEY: ${{ secrets.API_KEY }}
    run: ./deploy.sh
```

**Environment variables**:
```yaml
env:
  NODE_ENV: production

jobs:
  build:
    env:
      BUILD_VERSION: 1.0.0
    steps:
      - run: echo $BUILD_VERSION
```

## Using Actions

### Finding Actions

Search GitHub Marketplace: https://github.com/marketplace?type=actions

**Popular actions**:
- `actions/checkout@v4` - Clone repository
- `actions/setup-node@v4` - Setup Node.js
- `actions/setup-python@v5` - Setup Python
- `actions/cache@v4` - Cache dependencies
- `actions/upload-artifact@v4` - Store build artifacts
- `actions/download-artifact@v4` - Retrieve artifacts

### Action Usage

**With inputs**:
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'
```

**With outputs**:
```yaml
- id: build
  run: echo "version=1.0.0" >> $GITHUB_OUTPUT

- run: echo "Built version ${{ steps.build.outputs.version }}"
```

## Contexts and Expressions

### Common Contexts

| Context | Description | Example |
|---------|-------------|---------|
| `github` | Workflow info | `${{ github.ref }}` |
| `env` | Environment variables | `${{ env.NODE_ENV }}` |
| `secrets` | Repository secrets | `${{ secrets.API_KEY }}` |
| `matrix` | Matrix values | `${{ matrix.node-version }}` |
| `steps` | Step outputs | `${{ steps.build.outputs.version }}` |
| `runner` | Runner environment | `${{ runner.os }}` |

### Expressions

**Conditionals**:
```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

**Functions**:
```yaml
if: contains(github.event.pull_request.labels.*.name, 'deploy')
if: startsWith(github.ref, 'refs/tags/')
if: success() || failure()
```

## Security Best Practices

### Secrets Management

1. **Store secrets in repository settings** - Never commit secrets
2. **Use environment secrets** - For deployment environments
3. **Scope secrets appropriately** - Organization vs. repository level

```yaml
steps:
  - name: Deploy
    env:
      API_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
    run: ./deploy.sh
```

### Pull Request Security

**Limit fork permissions**:
```yaml
on:
  pull_request_target:  # Use for fork PRs
    types: [opened, synchronize]
```

**Require approval for forks**:
Configure in repository settings → Actions → Fork pull request workflows

### Token Permissions

**Restrict GITHUB_TOKEN**:
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
            github.rest.issues.createComment({...})
```

## Debugging Workflows

### Enable Debug Logging

Set repository secrets:
- `ACTIONS_STEP_DEBUG: true` - Step debugging
- `ACTIONS_RUNNER_DEBUG: true` - Runner debugging

### View Logs

Access workflow run logs from:
1. Repository → Actions tab
2. Select workflow run
3. Click job name
4. Expand steps to view output

### Common Issues

| Issue | Solution |
|-------|----------|
| Checkout fails | Use `actions/checkout@v4` |
| Secrets not available | Check secret name and scope |
| Step skipped | Check `if` conditions |
| Action version error | Update to latest version tag |
| Permission denied | Check `permissions` in workflow |

## Workflow Creation Checklist

Use this checklist when creating workflows:

- [ ] File in `.github/workflows/` with `.yml` or `.yaml` extension
- [ ] Workflow has descriptive `name`
- [ ] Appropriate event triggers configured
- [ ] Runner OS specified with `runs-on`
- [ ] First step uses `actions/checkout@v4`
- [ ] Secrets used for sensitive data (never hardcoded)
- [ ] Job dependencies configured with `needs` if required
- [ ] Matrix strategy used for multi-environment testing (if needed)
- [ ] Artifacts uploaded for build outputs (if needed)
- [ ] Appropriate permissions set for `GITHUB_TOKEN`
- [ ] Workflow tested on feature branch before merging

## Additional Resources

### Reference Files

For detailed syntax and patterns:
- **`references/workflow-syntax.md`** - Complete YAML syntax reference
- **`references/common-patterns.md`** - Workflow patterns by use case
- **`references/security-guide.md`** - Security best practices and OIDC

### Example Workflows

Working examples in `examples/`:
- **`examples/ci-nodejs.yml`** - Node.js CI with testing and linting
- **`examples/ci-python.yml`** - Python CI with multiple versions
- **`examples/deploy-pages.yml`** - Deploy to GitHub Pages
- **`examples/release.yml`** - Automated releases with changelog
- **`examples/docker-build.yml`** - Build and push Docker images

### External Resources

- GitHub Actions documentation: https://docs.github.com/en/actions
- GitHub Actions Marketplace: https://github.com/marketplace?type=actions
- Workflow syntax reference: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions

## Quick Reference

**Minimal workflow**:
```yaml
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

**Common action versions**:
- `actions/checkout@v4`
- `actions/setup-node@v4`
- `actions/setup-python@v5`
- `actions/cache@v4`
- `actions/upload-artifact@v4`

**Useful expressions**:
- `${{ github.ref }}` - Current branch/tag
- `${{ github.sha }}` - Commit SHA
- `${{ runner.os }}` - Runner OS (Linux, Windows, macOS)
- `${{ secrets.SECRET_NAME }}` - Access secret
- `${{ matrix.value }}` - Matrix value
