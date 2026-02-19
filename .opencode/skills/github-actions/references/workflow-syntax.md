# GitHub Actions Workflow Syntax Reference

Complete reference for GitHub Actions YAML workflow syntax.

## Table of Contents

- [Workflow File Structure](#workflow-file-structure)
- [Top-Level Keys](#top-level-keys)
- [Event Triggers (on)](#event-triggers-on)
- [Jobs Configuration](#jobs-configuration)
- [Steps Configuration](#steps-configuration)
- [Expressions and Contexts](#expressions-and-contexts)
- [Environment Variables](#environment-variables)
- [Secrets and Security](#secrets-and-security)

## Workflow File Structure

```yaml
name: Workflow Name
run-name: Custom run name

on:
  # Event triggers

env:
  # Global environment variables

permissions:
  # GITHUB_TOKEN permissions

defaults:
  # Default settings

jobs:
  job-id:
    # Job configuration
```

## Top-Level Keys

### name

Display name for the workflow:

```yaml
name: CI Pipeline
```

### run-name

Custom name for workflow runs (supports expressions):

```yaml
run-name: Deploy by @${{ github.actor }}
```

### on

Event triggers (see [Event Triggers](#event-triggers-on))

### env

Global environment variables:

```yaml
env:
  NODE_ENV: production
  API_URL: https://api.example.com
```

### permissions

GITHUB_TOKEN permissions:

```yaml
permissions:
  contents: read
  pull-requests: write
  issues: write
```

**Scopes**:
- `actions`, `checks`, `contents`, `deployments`, `discussions`
- `id-token`, `issues`, `packages`, `pages`, `pull-requests`
- `repository-projects`, `security-events`, `statuses`

**Access levels**: `read`, `write`, `none`

### defaults

Default settings for run steps:

```yaml
defaults:
  run:
    shell: bash
    working-directory: ./src
```

## Event Triggers (on)

### Single Event

```yaml
on: push
```

### Multiple Events

```yaml
on: [push, pull_request, workflow_dispatch]
```

### Event with Configuration

```yaml
on:
  push:
    branches:
      - main
      - 'releases/**'
    tags:
      - 'v*'
    paths:
      - 'src/**'
      - '**.js'
  pull_request:
    types: [opened, synchronize, reopened]
    branches:
      - main
```

### Common Events

**push**:
```yaml
on:
  push:
    branches: [main, develop]
    tags: ['v*']
    paths: ['src/**']
    paths-ignore: ['docs/**']
```

**pull_request**:
```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [main]
```

**pull_request_target** (for fork PRs with secrets):
```yaml
on:
  pull_request_target:
    types: [opened, synchronize]
```

**workflow_dispatch** (manual trigger):
```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Deployment environment'
        required: true
        type: choice
        options:
          - development
          - staging
          - production
      version:
        description: 'Version to deploy'
        required: false
        type: string
```

**schedule** (cron):
```yaml
on:
  schedule:
    - cron: '0 0 * * *'    # Daily at midnight
    - cron: '0 */6 * * *'  # Every 6 hours
```

**release**:
```yaml
on:
  release:
    types: [published, created, edited]
```

**issues**:
```yaml
on:
  issues:
    types: [opened, labeled, assigned]
```

**workflow_call** (reusable workflow):
```yaml
on:
  workflow_call:
    inputs:
      config-path:
        required: true
        type: string
    secrets:
      token:
        required: true
```

**repository_dispatch** (API trigger):
```yaml
on:
  repository_dispatch:
    types: [custom-event]
```

### Activity Types by Event

| Event | Activity Types |
|-------|----------------|
| `pull_request` | `opened`, `synchronize`, `reopened`, `closed`, `assigned`, `labeled`, `review_requested` |
| `issues` | `opened`, `edited`, `deleted`, `closed`, `reopened`, `assigned`, `labeled` |
| `release` | `published`, `created`, `edited`, `deleted`, `released` |
| `workflow_run` | `completed`, `requested` |

## Jobs Configuration

### Basic Job

```yaml
jobs:
  job-id:
    name: Job Display Name
    runs-on: ubuntu-latest
    steps:
      - run: echo "Hello"
```

### Job Keys

**runs-on** (required):
```yaml
runs-on: ubuntu-latest
runs-on: windows-latest
runs-on: macos-latest
runs-on: [self-hosted, linux]
```

**needs** (job dependencies):
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
  
  deploy:
    needs: [build, test]
    runs-on: ubuntu-latest
    steps:
      - run: ./deploy.sh
```

**if** (conditional execution):
```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
```

**strategy** (matrix builds):
```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [18, 20, 22]
      fail-fast: false
      max-parallel: 2
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node }}
```

**Matrix with include/exclude**:
```yaml
strategy:
  matrix:
    os: [ubuntu-latest, macos-latest]
    node: [18, 20]
    include:
      - os: windows-latest
        node: 20
    exclude:
      - os: macos-latest
        node: 18
```

**env** (job-level environment variables):
```yaml
jobs:
  build:
    env:
      BUILD_TYPE: release
    steps:
      - run: echo $BUILD_TYPE
```

**defaults** (job-level defaults):
```yaml
jobs:
  test:
    defaults:
      run:
        shell: bash
        working-directory: ./tests
```

**permissions** (job-level permissions):
```yaml
jobs:
  deploy:
    permissions:
      contents: write
      packages: write
```

**timeout-minutes**:
```yaml
jobs:
  test:
    timeout-minutes: 30
```

**continue-on-error**:
```yaml
jobs:
  experimental:
    continue-on-error: true
```

**container** (run in container):
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: node:20
      env:
        NODE_ENV: test
      volumes:
        - /data:/data
      options: --cpus 2
```

**services** (service containers):
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
```

**outputs** (job outputs):
```yaml
jobs:
  build:
    outputs:
      version: ${{ steps.get-version.outputs.version }}
    steps:
      - id: get-version
        run: echo "version=1.0.0" >> $GITHUB_OUTPUT
  
  deploy:
    needs: build
    steps:
      - run: echo "Deploying ${{ needs.build.outputs.version }}"
```

**environment** (deployment environment):
```yaml
jobs:
  deploy:
    environment:
      name: production
      url: https://example.com
```

**concurrency** (limit concurrent runs):
```yaml
jobs:
  deploy:
    concurrency:
      group: production
      cancel-in-progress: false
```

## Steps Configuration

### Step Types

**Run command**:
```yaml
- run: npm test
```

**Use action**:
```yaml
- uses: actions/checkout@v4
```

**Composite step**:
```yaml
- name: Setup and test
  run: |
    npm install
    npm test
```

### Step Keys

**name**:
```yaml
- name: Run tests
  run: npm test
```

**id** (reference in later steps):
```yaml
- id: build-info
  run: echo "version=1.0.0" >> $GITHUB_OUTPUT

- run: echo "Version: ${{ steps.build-info.outputs.version }}"
```

**if** (conditional step):
```yaml
- name: Deploy
  if: github.ref == 'refs/heads/main'
  run: ./deploy.sh
```

**env** (step environment variables):
```yaml
- name: Build
  env:
    NODE_ENV: production
  run: npm run build
```

**with** (action inputs):
```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'
```

**working-directory**:
```yaml
- run: npm test
  working-directory: ./packages/core
```

**shell**:
```yaml
- run: echo "Hello"
  shell: bash

- run: Write-Output "Hello"
  shell: pwsh

- run: print("Hello")
  shell: python
```

**continue-on-error**:
```yaml
- name: Optional check
  run: npm run lint
  continue-on-error: true
```

**timeout-minutes**:
```yaml
- name: Long running task
  run: ./process.sh
  timeout-minutes: 60
```

### Run Syntax

**Single line**:
```yaml
- run: npm test
```

**Multi-line script**:
```yaml
- run: |
    echo "Installing dependencies"
    npm ci
    echo "Running tests"
    npm test
```

**Multi-line with pipe (preserves newlines)**:
```yaml
- run: |
    set -e
    npm ci
    npm test
```

**Multi-line folded (joins lines)**:
```yaml
- run: >
    npm install &&
    npm test
```

## Expressions and Contexts

### Expression Syntax

Use `${{ }}` for expressions:

```yaml
- if: ${{ github.ref == 'refs/heads/main' }}
  run: echo "Main branch"
```

**Can omit `${{ }}` in if conditions**:
```yaml
- if: github.ref == 'refs/heads/main'
  run: echo "Main branch"
```

### Contexts

**github context**:
```yaml
${{ github.repository }}       # owner/repo
${{ github.ref }}              # refs/heads/main
${{ github.ref_name }}         # main
${{ github.sha }}              # commit SHA
${{ github.actor }}            # user who triggered
${{ github.event_name }}       # push, pull_request, etc.
${{ github.run_id }}           # unique run ID
${{ github.run_number }}       # run number
${{ github.job }}              # current job ID
${{ github.workspace }}        # workspace directory
```

**env context**:
```yaml
${{ env.VARIABLE_NAME }}
```

**secrets context**:
```yaml
${{ secrets.SECRET_NAME }}
```

**matrix context**:
```yaml
${{ matrix.os }}
${{ matrix.node-version }}
```

**steps context**:
```yaml
${{ steps.step-id.outputs.output-name }}
${{ steps.step-id.conclusion }}  # success, failure, skipped
${{ steps.step-id.outcome }}     # success, failure
```

**needs context**:
```yaml
${{ needs.job-id.outputs.output-name }}
${{ needs.job-id.result }}  # success, failure, cancelled, skipped
```

**runner context**:
```yaml
${{ runner.os }}        # Linux, Windows, macOS
${{ runner.arch }}      # X64, ARM, ARM64
${{ runner.name }}      # runner name
${{ runner.temp }}      # temp directory
```

**job context**:
```yaml
${{ job.status }}       # success, failure, cancelled
```

**strategy context**:
```yaml
${{ strategy.job-index }}
${{ strategy.job-total }}
```

### Functions

**contains**:
```yaml
if: contains(github.event.pull_request.labels.*.name, 'deploy')
if: contains(github.ref, 'releases/')
```

**startsWith**:
```yaml
if: startsWith(github.ref, 'refs/tags/v')
```

**endsWith**:
```yaml
if: endsWith(github.ref, '-beta')
```

**format**:
```yaml
run: echo "${{ format('Hello {0} {1}', github.actor, github.repository) }}"
```

**join**:
```yaml
run: echo "${{ join(github.event.pull_request.labels.*.name, ', ') }}"
```

**toJSON**:
```yaml
run: echo '${{ toJSON(github.event) }}'
```

**fromJSON**:
```yaml
strategy:
  matrix: ${{ fromJSON(needs.setup.outputs.matrix) }}
```

**hashFiles**:
```yaml
- uses: actions/cache@v4
  with:
    key: ${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
```

**success**, **failure**, **cancelled**, **always**:
```yaml
- if: success()
  run: echo "Previous steps succeeded"

- if: failure()
  run: echo "Previous steps failed"

- if: always()
  run: echo "Always runs"

- if: cancelled()
  run: echo "Workflow was cancelled"
```

**Combining conditions**:
```yaml
if: success() && github.ref == 'refs/heads/main'
if: failure() || cancelled()
if: always() && !cancelled()
```

## Environment Variables

### Defining Variables

**Workflow level**:
```yaml
env:
  GLOBAL_VAR: value

jobs:
  test:
    steps:
      - run: echo $GLOBAL_VAR
```

**Job level**:
```yaml
jobs:
  test:
    env:
      JOB_VAR: value
    steps:
      - run: echo $JOB_VAR
```

**Step level**:
```yaml
steps:
  - name: Build
    env:
      STEP_VAR: value
    run: echo $STEP_VAR
```

### Default Environment Variables

GitHub provides these automatically:

| Variable | Description |
|----------|-------------|
| `CI` | Always `true` |
| `GITHUB_WORKFLOW` | Workflow name |
| `GITHUB_RUN_ID` | Unique run ID |
| `GITHUB_RUN_NUMBER` | Run number |
| `GITHUB_ACTION` | Action name |
| `GITHUB_ACTOR` | User who triggered |
| `GITHUB_REPOSITORY` | owner/repo |
| `GITHUB_REF` | Full ref (refs/heads/main) |
| `GITHUB_REF_NAME` | Short ref name (main) |
| `GITHUB_SHA` | Commit SHA |
| `GITHUB_WORKSPACE` | Workspace directory |
| `RUNNER_OS` | Linux, Windows, macOS |
| `RUNNER_ARCH` | X64, ARM, ARM64 |

### Setting Outputs

**From step to step**:
```yaml
- id: build
  run: echo "version=1.0.0" >> $GITHUB_OUTPUT

- run: echo "Built version ${{ steps.build.outputs.version }}"
```

**From job to job**:
```yaml
jobs:
  build:
    outputs:
      version: ${{ steps.get-version.outputs.version }}
    steps:
      - id: get-version
        run: echo "version=1.0.0" >> $GITHUB_OUTPUT
  
  deploy:
    needs: build
    steps:
      - run: echo "Deploying ${{ needs.build.outputs.version }}"
```

## Secrets and Security

### Using Secrets

**In environment variables**:
```yaml
- name: Deploy
  env:
    API_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
  run: ./deploy.sh
```

**In action inputs**:
```yaml
- uses: some/action@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
```

### GITHUB_TOKEN

Automatically available in workflows:

```yaml
- uses: actions/checkout@v4
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
```

**Set permissions**:
```yaml
permissions:
  contents: write
  pull-requests: read
```

**Default permissions** (if not specified):
- `contents: write`
- `metadata: read`

### Encrypted Secrets

Store in repository/organization/environment settings.

**Access levels**:
- Repository secrets: Available to all workflows
- Environment secrets: Available when using environment
- Organization secrets: Available across org repositories

**Secret naming**:
- Cannot start with `GITHUB_`
- Cannot start with a number
- Case insensitive
- Alphanumeric and underscores only

## Advanced Patterns

### Reusable Workflows

**Caller workflow**:
```yaml
jobs:
  call-reusable:
    uses: owner/repo/.github/workflows/reusable.yml@main
    with:
      config-path: config.json
    secrets:
      token: ${{ secrets.TOKEN }}
```

**Reusable workflow**:
```yaml
on:
  workflow_call:
    inputs:
      config-path:
        required: true
        type: string
    secrets:
      token:
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Config: ${{ inputs.config-path }}"
```

### Composite Actions

Create reusable steps:

```yaml
# action.yml
name: Setup and Test
description: Install dependencies and run tests

inputs:
  node-version:
    description: Node.js version
    required: false
    default: '20'

runs:
  using: composite
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
    
    - run: npm ci
      shell: bash
    
    - run: npm test
      shell: bash
```

### Artifacts

**Upload**:
```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/
    retention-days: 7
```

**Download**:
```yaml
- uses: actions/download-artifact@v4
  with:
    name: build-output
    path: dist/
```

### Caching

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

## Complete Example

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:

env:
  NODE_VERSION: '20'

permissions:
  contents: read
  pull-requests: write

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node: [18, 20, 22]
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Upload coverage
      uses: actions/upload-artifact@v4
      if: matrix.node == 20
      with:
        name: coverage
        path: coverage/
  
  build:
    needs: test
    runs-on: ubuntu-latest
    
    outputs:
      version: ${{ steps.package.outputs.version }}
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
    
    - run: npm ci
    
    - run: npm run build
    
    - id: package
      run: echo "version=$(node -p "require('./package.json').version")" >> $GITHUB_OUTPUT
    
    - uses: actions/upload-artifact@v4
      with:
        name: build
        path: dist/
  
  deploy:
    if: github.ref == 'refs/heads/main'
    needs: build
    runs-on: ubuntu-latest
    environment: production
    
    permissions:
      contents: write
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/download-artifact@v4
      with:
        name: build
        path: dist/
    
    - name: Deploy
      env:
        DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
      run: |
        echo "Deploying version ${{ needs.build.outputs.version }}"
        ./scripts/deploy.sh
```

## Reference Links

- Workflow syntax: https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions
- Events: https://docs.github.com/en/actions/reference/events-that-trigger-workflows
- Contexts: https://docs.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions
- Environment variables: https://docs.github.com/en/actions/reference/environment-variables
