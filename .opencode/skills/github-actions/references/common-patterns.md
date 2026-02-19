# GitHub Actions Common Patterns

Practical workflow patterns organized by use case with working examples.

## Table of Contents

- [Continuous Integration](#continuous-integration)
- [Continuous Deployment](#continuous-deployment)
- [Testing Patterns](#testing-patterns)
- [Build and Publish](#build-and-publish)
- [Automation and Maintenance](#automation-and-maintenance)
- [Security and Compliance](#security-and-compliance)
- [Performance Optimization](#performance-optimization)

## Continuous Integration

### Basic CI for Node.js

Test code on every push and pull request:

```yaml
name: Node.js CI

on:
  push:
    branches: [main, develop]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    
    - run: npm ci
    - run: npm test
    - run: npm run lint
```

### Multi-Version Testing (Matrix)

Test across multiple Node.js versions and operating systems:

```yaml
name: Cross-Platform CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        node: [18, 20, 22]
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node }}
        cache: 'npm'
    
    - run: npm ci
    - run: npm test
```

### Python CI with Multiple Versions

```yaml
name: Python CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11', '3.12']
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-python@v5
      with:
        python-version: ${{ matrix.python-version }}
        cache: 'pip'
    
    - run: pip install -r requirements.txt
    - run: pip install pytest pytest-cov
    - run: pytest --cov
```

### Monorepo CI (Selective Testing)

Run tests only for changed packages:

```yaml
name: Monorepo CI

on:
  pull_request:
    paths:
      - 'packages/**'

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      packages: ${{ steps.filter.outputs.changes }}
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: dorny/paths-filter@v3
      id: filter
      with:
        filters: |
          package-a:
            - 'packages/package-a/**'
          package-b:
            - 'packages/package-b/**'
  
  test:
    needs: detect-changes
    if: needs.detect-changes.outputs.packages != '[]'
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        package: ${{ fromJSON(needs.detect-changes.outputs.packages) }}
    
    steps:
    - uses: actions/checkout@v4
    - run: npm test --workspace=packages/${{ matrix.package }}
```

## Continuous Deployment

### Deploy to GitHub Pages

Build and deploy static site:

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    
    - run: npm ci
    - run: npm run build
    
    - uses: actions/upload-pages-artifact@v3
      with:
        path: ./dist
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    
    steps:
    - id: deployment
      uses: actions/deploy-pages@v4
```

### Deploy to AWS S3

```yaml
name: Deploy to S3

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm ci
    - run: npm run build
    
    - uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
        aws-region: us-east-1
    
    - run: |
        aws s3 sync ./dist s3://${{ secrets.S3_BUCKET }} --delete
        aws cloudfront create-invalidation --distribution-id ${{ secrets.CF_DISTRIBUTION_ID }} --paths "/*"
```

### Deploy with Environment Approvals

Require manual approval for production:

```yaml
name: Deploy with Approval

on:
  push:
    branches: [main]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
    - uses: actions/checkout@v4
    - run: ./deploy.sh staging
  
  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://example.com
    
    steps:
    - uses: actions/checkout@v4
    - run: ./deploy.sh production
```

### Versioned Deployments

Deploy based on semantic version tags:

```yaml
name: Release Deployment

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Extract version
      id: version
      run: echo "version=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT
    
    - name: Build
      run: npm run build
      env:
        VERSION: ${{ steps.version.outputs.version }}
    
    - name: Deploy
      run: ./deploy.sh ${{ steps.version.outputs.version }}
      env:
        DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
```

## Testing Patterns

### Code Coverage with Codecov

```yaml
name: Coverage

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    
    - run: npm ci
    - run: npm test -- --coverage
    
    - uses: codecov/codecov-action@v4
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        files: ./coverage/lcov.info
        fail_ci_if_error: true
```

### End-to-End Testing with Playwright

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm ci
    - run: npx playwright install --with-deps
    
    - run: npm run build
    
    - run: npx playwright test
      env:
        CI: true
    
    - uses: actions/upload-artifact@v4
      if: always()
      with:
        name: playwright-report
        path: playwright-report/
        retention-days: 7
```

### Visual Regression Testing

```yaml
name: Visual Regression

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm ci
    - run: npm run build
    
    - uses: chromaui/action@latest
      with:
        projectToken: ${{ secrets.CHROMATIC_PROJECT_TOKEN }}
        autoAcceptChanges: main
```

### Performance Testing

```yaml
name: Performance Test

on:
  pull_request:
  push:
    branches: [main]

jobs:
  lighthouse:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm ci
    - run: npm run build
    
    - run: npm install -g @lhci/cli
    
    - run: lhci autorun
      env:
        LHCI_GITHUB_APP_TOKEN: ${{ secrets.LHCI_GITHUB_APP_TOKEN }}
```

## Build and Publish

### Build and Push Docker Image

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: docker/setup-buildx-action@v3
    
    - uses: docker/login-action@v3
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - uses: docker/metadata-action@v5
      id: meta
      with:
        images: ghcr.io/${{ github.repository }}
        tags: |
          type=ref,event=branch
          type=semver,pattern={{version}}
          type=semver,pattern={{major}}.{{minor}}
    
    - uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

### Publish NPM Package

```yaml
name: Publish to NPM

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      id-token: write
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        registry-url: 'https://registry.npmjs.org'
    
    - run: npm ci
    - run: npm test
    - run: npm run build
    
    - run: npm publish --provenance --access public
      env:
        NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Multi-Platform Binary Builds

```yaml
name: Build Binaries

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: ${{ matrix.os }}
    
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: linux-x64
          - os: windows-latest
            target: windows-x64
          - os: macos-latest
            target: macos-x64
          - os: macos-latest
            target: macos-arm64
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm ci
    
    - name: Build binary
      run: npm run build:binary -- --target ${{ matrix.target }}
    
    - uses: actions/upload-artifact@v4
      with:
        name: binary-${{ matrix.target }}
        path: dist/binary-*
  
  release:
    needs: build
    runs-on: ubuntu-latest
    
    permissions:
      contents: write
    
    steps:
    - uses: actions/download-artifact@v4
      with:
        pattern: binary-*
        merge-multiple: true
    
    - uses: softprops/action-gh-release@v1
      with:
        files: binary-*
```

### Create GitHub Release with Changelog

```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    
    permissions:
      contents: write
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Generate changelog
      id: changelog
      run: |
        CHANGELOG=$(git log $(git describe --tags --abbrev=0 HEAD^)..HEAD --pretty=format:"- %s" --no-merges)
        echo "changelog<<EOF" >> $GITHUB_OUTPUT
        echo "$CHANGELOG" >> $GITHUB_OUTPUT
        echo "EOF" >> $GITHUB_OUTPUT
    
    - uses: softprops/action-gh-release@v1
      with:
        body: |
          ## Changes
          ${{ steps.changelog.outputs.changelog }}
        draft: false
        prerelease: ${{ contains(github.ref, '-beta') || contains(github.ref, '-alpha') }}
```

## Automation and Maintenance

### Auto-Merge Dependabot PRs

```yaml
name: Auto-merge Dependabot

on:
  pull_request:

jobs:
  auto-merge:
    if: github.actor == 'dependabot[bot]'
    runs-on: ubuntu-latest
    
    permissions:
      contents: write
      pull-requests: write
    
    steps:
    - uses: dependabot/fetch-metadata@v2
      id: metadata
    
    - name: Auto-merge minor and patch updates
      if: steps.metadata.outputs.update-type == 'version-update:semver-minor' || steps.metadata.outputs.update-type == 'version-update:semver-patch'
      run: gh pr merge --auto --squash "$PR_URL"
      env:
        PR_URL: ${{ github.event.pull_request.html_url }}
        GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Stale Issue Management

```yaml
name: Close Stale Issues

on:
  schedule:
    - cron: '0 0 * * *'
  workflow_dispatch:

jobs:
  stale:
    runs-on: ubuntu-latest
    
    permissions:
      issues: write
      pull-requests: write
    
    steps:
    - uses: actions/stale@v9
      with:
        stale-issue-message: 'This issue is stale because it has been open 60 days with no activity.'
        close-issue-message: 'This issue was closed because it has been stale for 14 days with no activity.'
        stale-issue-label: 'stale'
        days-before-stale: 60
        days-before-close: 14
```

### Auto-Label PRs

```yaml
name: Label PRs

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  label:
    runs-on: ubuntu-latest
    
    permissions:
      contents: read
      pull-requests: write
    
    steps:
    - uses: actions/labeler@v5
      with:
        configuration-path: .github/labeler.yml
```

**`.github/labeler.yml`**:
```yaml
documentation:
  - '**/*.md'
  - docs/**

frontend:
  - 'src/components/**'
  - 'src/pages/**'

backend:
  - 'src/api/**'
  - 'src/services/**'

dependencies:
  - package.json
  - package-lock.json
```

### Nightly Builds

```yaml
name: Nightly Build

on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM daily
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm ci
    - run: npm run build
    
    - name: Upload nightly build
      uses: actions/upload-artifact@v4
      with:
        name: nightly-build-${{ github.run_number }}
        path: dist/
        retention-days: 7
```

## Security and Compliance

### Security Scanning with CodeQL

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 0 * * 1'  # Weekly on Monday

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

### Dependency Vulnerability Scanning

```yaml
name: Dependency Scan

on:
  push:
    branches: [main]
  pull_request:
  schedule:
    - cron: '0 0 * * *'

jobs:
  scan:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm audit --audit-level=moderate
    
    - uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high
```

### License Compliance Check

```yaml
name: License Check

on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
    
    - run: npm ci
    
    - run: npx license-checker --onlyAllow "MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC"
```

### SBOM Generation

Generate Software Bill of Materials:

```yaml
name: Generate SBOM

on:
  release:
    types: [published]

jobs:
  sbom:
    runs-on: ubuntu-latest
    
    permissions:
      contents: write
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: anchore/sbom-action@v0
      with:
        format: spdx-json
        output-file: sbom.spdx.json
    
    - uses: softprops/action-gh-release@v1
      with:
        files: sbom.spdx.json
```

## Performance Optimization

### Dependency Caching

```yaml
name: Optimized Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    
    - name: Cache build outputs
      uses: actions/cache@v4
      with:
        path: |
          .next/cache
          dist/
        key: ${{ runner.os }}-build-${{ hashFiles('**/package-lock.json') }}-${{ github.sha }}
        restore-keys: |
          ${{ runner.os }}-build-${{ hashFiles('**/package-lock.json') }}-
          ${{ runner.os }}-build-
    
    - run: npm ci
    - run: npm run build
```

### Parallel Job Execution

```yaml
name: Parallel Workflow

on: [push]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint
  
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test
  
  type-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run type-check
  
  build:
    needs: [lint, test, type-check]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run build
```

### Conditional Job Execution

Skip jobs when files haven't changed:

```yaml
name: Smart CI

on:
  pull_request:
    paths:
      - 'src/**'
      - 'tests/**'
      - 'package*.json'

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      src: ${{ steps.filter.outputs.src }}
      tests: ${{ steps.filter.outputs.tests }}
      docs: ${{ steps.filter.outputs.docs }}
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: dorny/paths-filter@v3
      id: filter
      with:
        filters: |
          src:
            - 'src/**'
          tests:
            - 'tests/**'
          docs:
            - 'docs/**'
  
  test:
    needs: changes
    if: needs.changes.outputs.src == 'true' || needs.changes.outputs.tests == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
  
  docs:
    needs: changes
    if: needs.changes.outputs.docs == 'true'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build:docs
```

### Build Matrix Optimization

```yaml
name: Optimized Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest]
        node: [18, 20, 22]
        include:
          # Full matrix on main branch
          - os: windows-latest
            node: 20
          - os: macos-latest
            node: 20
        exclude:
          # Skip old Node on PRs
          - node: 18
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node }}
        cache: 'npm'
    
    - run: npm ci
    - run: npm test
```

## Composite Workflows

### Reusable Setup Action

Create `.github/actions/setup/action.yml`:

```yaml
name: Setup Project
description: Install dependencies and cache

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
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
      shell: bash
    
    - name: Cache build
      uses: actions/cache@v4
      with:
        path: dist/
        key: build-${{ hashFiles('src/**') }}
      shell: bash
```

Use in workflows:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./.github/actions/setup
      - run: npm test
```

### Reusable Workflow

Create `.github/workflows/reusable-test.yml`:

```yaml
name: Reusable Test

on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '20'
    secrets:
      token:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
    
    - run: npm ci
    - run: npm test
```

Call from another workflow:

```yaml
name: CI

on: [push, pull_request]

jobs:
  test-current:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
  
  test-legacy:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '18'
```

## Troubleshooting Common Issues

### Debug Failed Steps

```yaml
- name: Debug on failure
  if: failure()
  run: |
    echo "Step failed, dumping debug info"
    env
    ls -la
    cat $GITHUB_EVENT_PATH
```

### Conditional Cleanup

```yaml
- name: Cleanup
  if: always()
  run: |
    docker-compose down
    rm -rf temp/
```

### Artifact Retention on Failure

```yaml
- name: Run tests
  run: npm test

- name: Upload logs on failure
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: test-logs
    path: logs/
```

### Retry Failed Steps

```yaml
- uses: nick-fields/retry@v3
  with:
    timeout_minutes: 10
    max_attempts: 3
    command: npm run flaky-test
```

## Reference

For complete syntax details, see `workflow-syntax.md`.
