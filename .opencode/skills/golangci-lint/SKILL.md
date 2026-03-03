---
name: golangci-lint
description: This skill should be used when the user asks to "set up golangci-lint", "add linting to a Go project", "configure golangci-lint", "fix golangci-lint errors", or needs guidance on Go code quality and linting best practices.
---

# golangci-lint

golangci-lint is a fast, parallel Go linters aggregator. It runs dozens of linters concurrently, caches results, and reports issues in a unified output. Use this skill to install, configure, run, and integrate golangci-lint into Go projects.

## Installation

### Binary (Recommended)

Install a pinned version into `$(go env GOPATH)/bin`:

```bash
curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.10.1
golangci-lint --version
```

Install into a local `./bin/` directory instead:

```bash
curl -sSfL https://golangci-lint.run/install.sh | sh -s v2.10.1
```

### macOS

```bash
brew install golangci-lint
# or tap for the latest release
brew tap golangci/tap && brew install golangci/tap/golangci-lint
```

### Windows

```bash
choco install golangci-lint   # Chocolatey
scoop install main/golangci-lint  # Scoop
```

### Docker

```bash
docker run --rm -v $(pwd):/app -w /app golangci/golangci-lint:v2.10.1 golangci-lint run
```

Always pin to a specific version in CI. Avoid `go install` for golangci-lint — binary installation is faster and more reproducible.

## Running

### Basic Commands

```bash
# Lint the entire module (recursive)
golangci-lint run

# Equivalent explicit form
golangci-lint run ./...

# Lint specific directories or files
golangci-lint run ./pkg/... ./internal/...
golangci-lint run main.go

# Format code
golangci-lint fmt

# List enabled/available linters
golangci-lint linters
golangci-lint help linters
```

Directories are not analyzed recursively by default — append `/...` to recurse.

### Useful Flags

| Flag | Purpose |
|---|---|
| `--fix` | Auto-fix issues where supported |
| `--fast` | Run only fast linters |
| `-E <linter>` | Enable a specific linter |
| `-D <linter>` | Disable a specific linter |
| `--default=none` | Disable all default linters |
| `--timeout 5m` | Set analysis timeout |
| `-v` | Verbose output (shows which config is loaded) |
| `--new-from-rev HEAD~1` | Report only issues in recent changes |

### Show Only New Issues

Integrate into existing codebases without fixing everything at once:

```bash
# Show only issues in uncommitted changes
golangci-lint run --new

# Show only issues introduced since a commit
golangci-lint run --new-from-rev HEAD~1
```

## Configuration File

golangci-lint searches for these files from the working directory upward:

- `.golangci.yml` / `.golangci.yaml`
- `.golangci.toml`
- `.golangci.json`

All config-file options mirror CLI flags. Linter-specific settings are only available via the config file.

### Minimal Working Configuration

```yaml
version: "2"

linters:
  default: standard
  enable:
    - gocritic
    - gosec
    - misspell
    - revive
    - wrapcheck

run:
  timeout: 5m
  tests: true

issues:
  max-issues-per-linter: 0
  max-same-issues: 0
```

### Recommended Project Configuration

```yaml
version: "2"

linters:
  default: standard
  enable:
    - bodyclose
    - errorlint
    - gocritic
    - gosec
    - misspell
    - noctx
    - revive
    - staticcheck
    - wrapcheck
  disable:
    - exhaustruct   # too noisy for most projects

run:
  timeout: 5m
  tests: true
  relative-path-mode: gomod

issues:
  max-issues-per-linter: 0
  max-same-issues: 0
  new-from-rev: ""  # report all issues, not just new ones

linters:
  exclusions:
    generated: lax
    presets:
      - comments
      - std-error-handling
    rules:
      - path: _test\.go
        linters:
          - gosec
          - errcheck
          - funlen
```

## Linters

### Enabled by Default (`default: standard`)

| Linter | Purpose |
|---|---|
| `errcheck` | Detects unchecked errors |
| `govet` | Finds suspicious constructs (like `go vet`) |
| `ineffassign` | Detects assignments to variables that are never used |
| `staticcheck` | Comprehensive static analysis suite |
| `unused` | Finds unused constants, variables, functions, and types |

### Commonly Enabled Extra Linters

| Linter | Purpose |
|---|---|
| `bodyclose` | Checks HTTP response body is closed |
| `errorlint` | Finds issues with Go 1.13 error wrapping |
| `gocritic` | Bugs, performance, and style diagnostics |
| `gosec` | Security-focused code inspection |
| `misspell` | Finds commonly misspelled English words |
| `noctx` | Detects missing `context.Context` usage |
| `revive` | Configurable drop-in replacement for `golint` |
| `wrapcheck` | Ensures errors from external packages are wrapped |
| `funlen` | Reports functions exceeding a length threshold |
| `gocyclo` | Cyclomatic complexity checker |
| `godot` | Checks comments end with a period |
| `prealloc` | Suggests slice pre-allocation |
| `unparam` | Reports unused function parameters |

Run `golangci-lint help linters` to see all available linters with their status.

## Suppressing False Positives

### Inline `//nolint` Directive

Suppress for a single line:

```go
var legacyVar = globalState //nolint:gochecknoglobals // legacy API contract
```

Suppress multiple linters:

```go
result, _ := riskyCall() //nolint:errcheck,gosec
```

Suppress for an entire function:

```go
//nolint:gocyclo // This legacy function is intentionally complex
func parseLegacyConfig() error {
    // ...
}
```

**Syntax rules** — no spaces allowed between `//` and `nolint`, or between `nolint:` and the linter name:

```go
// nolint:xxx   ← INVALID (space after //)
//nolint: xxx   ← INVALID (space after colon)
//nolint:xxx    ← VALID
```

Always add a comment after `//nolint` explaining why.

### Exclusion Rules in Config

Exclude by path pattern:

```yaml
linters:
  exclusions:
    rules:
      - path: _test\.go
        linters:
          - gocyclo
          - errcheck
          - gosec
```

Exclude by issue text:

```yaml
linters:
  exclusions:
    rules:
      - linters:
          - staticcheck
        text: "SA9003:"
```

Exclude generated files:

```yaml
linters:
  exclusions:
    generated: lax   # also excludes files with "do not edit" comments
    paths:
      - vendor/
      - ".*\\.pb\\.go$"
```

### Exclusion Presets

Four built-in presets group common false-positive suppressions:

```yaml
linters:
  exclusions:
    presets:
      - comments            # unexported items without godoc
      - std-error-handling  # ignores Close/Flush/Print error checks
      - common-false-positives  # gosec G103, G204, G304
      - legacy              # deprecated rules from older linters
```

## CI Integration

### GitHub Actions

```yaml
name: Lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: stable
      - uses: golangci/golangci-lint-action@v6
        with:
          version: v2.10.1
```

Use the official `golangci/golangci-lint-action` — it uses smart caching and creates GitHub annotations for found issues.

### GitLab CI

```yaml
include:
  - component: $CI_SERVER_FQDN/components/code-quality-oss/codequality-os-scanners-integration/golangci@1.0.1
```

### Other CI (Binary)

```bash
curl -sSfL https://golangci-lint.run/install.sh | sh -s -- -b /usr/local/bin v2.10.1
golangci-lint run ./...
```

Always pin to a specific version to prevent unexpected breakage when linters are upgraded upstream.

## Output Formats

golangci-lint supports multiple output formats for different consumers:

```yaml
output:
  formats:
    text:
      path: stdout
      print-linter-name: true
    json:
      path: ./lint-report.json
    checkstyle:
      path: ./checkstyle-report.xml
    junit-xml:
      path: ./junit-report.xml
    sarif:
      path: ./sarif-report.json
  sort-order:
    - linter
    - severity
    - file
```

## Quick Reference

| Command | Purpose |
|---|---|
| `golangci-lint run` | Lint entire module |
| `golangci-lint run --fix` | Lint and auto-fix |
| `golangci-lint fmt` | Format code |
| `golangci-lint linters` | List enabled linters |
| `golangci-lint run -v` | Verbose (shows config path) |
| `golangci-lint run --new` | Only new issues in changed files |

| Config file | Search order |
|---|---|
| `.golangci.yml` | First match wins, searches upward |
| `.golangci.yaml` | Second |
| `.golangci.toml` | Third |
| `.golangci.json` | Fourth |

## Additional Resources

For complete configuration examples, linter-by-linter settings, and advanced patterns:

- **`references/advanced-configuration.md`** — Full `.golangci.yml` with all sections annotated, per-linter settings examples, and CI caching strategies
