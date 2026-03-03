# golangci-lint Advanced Configuration

Reference for complete `.golangci.yml` configuration, per-linter settings, and CI integration patterns.

## Table of Contents

- [Complete Configuration Template](#complete-configuration-template)
- [Per-Linter Settings Examples](#per-linter-settings-examples)
- [Severity Configuration](#severity-configuration)
- [Output Formats Reference](#output-formats-reference)
- [Run Options Reference](#run-options-reference)
- [CI Caching Strategies](#ci-caching-strategies)
- [Incremental Adoption Strategy](#incremental-adoption-strategy)

---

## Complete Configuration Template

```yaml
# .golangci.yml — version 2 format
version: "2"

# ── Linters ──────────────────────────────────────────────────────────────────
linters:
  # default: standard | all | none | fast
  # "standard" enables: errcheck, govet, ineffassign, staticcheck, unused
  default: standard

  enable:
    - bodyclose
    - copyloopvar
    - errorlint
    - fatcontext
    - funlen
    - gocritic
    - gocyclo
    - gosec
    - misspell
    - noctx
    - nolintlint   # enforces //nolint comments have explanations
    - prealloc
    - revive
    - unparam
    - wrapcheck

  disable:
    - exhaustruct  # too noisy; requires every struct field to be set
    - wsl          # deprecated; use wsl_v5

  exclusions:
    generated: lax
    warn-unused: true
    presets:
      - comments
      - std-error-handling
      - common-false-positives
    rules:
      # Relax rules in test files
      - path: _test\.go
        linters:
          - funlen
          - gocyclo
          - gosec
          - errcheck
          - wrapcheck
      # Ignore long lines on go:generate directives
      - linters:
          - lll
        source: "^//go:generate "
      # Ignore generated proto files
      - path: ".*\\.pb\\.go$"
        linters:
          - wrapcheck
          - govet

# ── Run ──────────────────────────────────────────────────────────────────────
run:
  timeout: 5m
  tests: true
  relative-path-mode: gomod   # paths relative to go.mod location
  modules-download-mode: readonly
  issues-exit-code: 1
  go: "1.23"

# ── Issues ───────────────────────────────────────────────────────────────────
issues:
  max-issues-per-linter: 0    # 0 = unlimited
  max-same-issues: 0          # 0 = unlimited
  uniq-by-line: false
  fix: false                  # set to true to auto-apply fixes

# ── Output ───────────────────────────────────────────────────────────────────
output:
  formats:
    text:
      path: stdout
      print-linter-name: true
      print-issued-lines: true
      colors: true
  sort-order:
    - linter
    - severity
    - file
  show-stats: true

# ── Severity ─────────────────────────────────────────────────────────────────
severity:
  default: error
  rules:
    - linters:
        - godox
      severity: warning
    - linters:
        - misspell
      severity: info
```

---

## Per-Linter Settings Examples

### `revive` — Configurable Go Linter

```yaml
linters:
  settings:
    revive:
      severity: warning
      rules:
        - name: exported
          severity: warning
          disabled: false
        - name: var-naming
          severity: warning
        - name: unused-parameter
          severity: warning
        - name: cognitive-complexity
          arguments: [15]
```

### `gocritic` — Bug, Performance, Style

```yaml
linters:
  settings:
    gocritic:
      enabled-tags:
        - diagnostic
        - performance
      disabled-checks:
        - hugeParam
        - rangeValCopy
```

### `gosec` — Security

```yaml
linters:
  settings:
    gosec:
      excludes:
        - G104  # Errors unhandled (covered by errcheck)
        - G304  # File path provided as taint input
      config:
        G306: "0600"  # Expected file permission for WriteFile
```

### `funlen` — Function Length

```yaml
linters:
  settings:
    funlen:
      lines: 80
      statements: 50
      ignore-comments: true
```

### `gocyclo` / `cyclop` — Cyclomatic Complexity

```yaml
linters:
  settings:
    gocyclo:
      min-complexity: 15
    cyclop:
      max-complexity: 15
      package-average: 0.0
      skip-tests: true
```

### `lll` — Line Length

```yaml
linters:
  settings:
    lll:
      line-length: 120
      tab-width: 4
```

### `misspell` — Spelling

```yaml
linters:
  settings:
    misspell:
      locale: US
      extra-words:
        - typo: "importas"
          correction: "importas"
```

### `wrapcheck` — Error Wrapping

```yaml
linters:
  settings:
    wrapcheck:
      ignorePackageGlobs:
        - encoding/*
        - github.com/pkg/*
      ignoreSigRegexps:
        - \.New\(.*\)
```

### `depguard` — Import Allow/Blocklist

```yaml
linters:
  settings:
    depguard:
      rules:
        main:
          files:
            - "!**/*_test.go"
          deny:
            - pkg: "github.com/sirupsen/logrus"
              desc: "Use log/slog instead"
            - pkg: "io/ioutil"
              desc: "Deprecated since Go 1.16, use io and os packages"
```

### `staticcheck` — Disable Individual Checks

```yaml
linters:
  settings:
    staticcheck:
      checks:
        - all
        - "-SA1019"  # allow deprecated API usage temporarily
        - "-ST1000"  # disable package comment requirement
```

### `govet` — Specific Analyzers

```yaml
linters:
  settings:
    govet:
      enable:
        - shadow
      disable:
        - composites
```

### `tagliatelle` — Struct Tag Naming

```yaml
linters:
  settings:
    tagliatelle:
      case:
        rules:
          json: camel
          yaml: camel
          xml: camel
          bson: camel
          avro: snake
          mapstructure: kebab
```

---

## Severity Configuration

Severity applies to output formats that support it (SARIF, Code Climate, checkstyle):

```yaml
severity:
  default: error
  rules:
    - linters:
        - dupl
        - godox
      severity: warning
    - linters:
        - godot
        - misspell
      severity: info
```

Severity values: `error`, `warning`, `info`, `hint` (depends on output format).

Use `@linter` as severity to delegate to the linter's own severity (e.g., `gosec`, `revive`):

```yaml
severity:
  default: "@linter"
```

---

## Output Formats Reference

| Format | Use Case |
|---|---|
| `text` | Terminal / local development (default) |
| `json` | Tooling and custom parsers |
| `checkstyle` | Jenkins, SonarQube |
| `junit-xml` | JUnit-compatible CI dashboards |
| `sarif` | GitHub Advanced Security, VS Code |
| `code-climate` | GitLab Code Quality widget |
| `teamcity` | JetBrains TeamCity |
| `html` | Standalone HTML report |

Output multiple formats simultaneously:

```yaml
output:
  formats:
    text:
      path: stdout
    sarif:
      path: golangci-lint.sarif
    junit-xml:
      path: golangci-lint-junit.xml
```

---

## Run Options Reference

| Option | Default | Purpose |
|---|---|---|
| `timeout` | `0` (disabled) | Max total analysis time |
| `tests` | `true` | Include `_test.go` files |
| `relative-path-mode` | `cfg` | Anchor for relative exclusion paths |
| `modules-download-mode` | `""` | `readonly` prevents go.mod updates in CI |
| `issues-exit-code` | `1` | Exit code when issues found |
| `go` | from `go.mod` | Go version for analysis |
| `concurrency` | auto | Number of parallel analyzers |
| `allow-parallel-runners` | `false` | Allow multiple golangci-lint processes |

### `relative-path-mode` Values

- `gomod` — relative to `go.mod` directory (recommended for modules)
- `gitroot` — relative to `.git` root
- `cfg` — relative to config file location
- `wd` — relative to working directory (not recommended)

---

## CI Caching Strategies

### GitHub Actions with Cache

The official `golangci/golangci-lint-action` handles caching automatically:

```yaml
- uses: golangci/golangci-lint-action@v6
  with:
    version: v2.10.1
    args: --timeout=5m
```

For manual cache control:

```yaml
- name: Cache golangci-lint
  uses: actions/cache@v4
  with:
    path: ~/.cache/golangci-lint
    key: golangci-lint-${{ runner.os }}-${{ hashFiles('.golangci.yml') }}
```

### Docker with Cache Volumes

```bash
docker run --rm -t \
  -v $(pwd):/app \
  -w /app \
  --user $(id -u):$(id -g) \
  -v $(go env GOCACHE):/.cache/go-build \
  -e GOCACHE=/.cache/go-build \
  -v $(go env GOMODCACHE):/.cache/mod \
  -e GOMODCACHE=/.cache/mod \
  -v ~/.cache/golangci-lint:/.cache/golangci-lint \
  -e GOLANGCI_LINT_CACHE=/.cache/golangci-lint \
  golangci/golangci-lint:v2.10.1 golangci-lint run
```

### Cache Environment Variables

| Variable | Purpose |
|---|---|
| `GOLANGCI_LINT_CACHE` | Override golangci-lint cache location |
| `GOCACHE` | Go build cache |
| `GOMODCACHE` | Go module cache |

---

## Incremental Adoption Strategy

Introducing golangci-lint to an existing large codebase without addressing all existing issues at once:

### Step 1: Baseline — Only New Issues

```yaml
# .golangci.yml
version: "2"
linters:
  default: standard
issues:
  new-from-rev: HEAD  # only report issues in new code
```

Or use the `--new` flag:

```bash
golangci-lint run --new
```

### Step 2: Start with a Small Set of Linters

```yaml
linters:
  default: none
  enable:
    - govet
    - errcheck
    - staticcheck
```

### Step 3: Progressively Enable More Linters

Add one or two linters at a time as the team fixes existing issues:

```yaml
linters:
  default: none
  enable:
    - govet
    - errcheck
    - staticcheck
    - ineffassign   # added in week 2
    - misspell      # added in week 2
    - gosec         # added in week 4
```

### Step 4: Use `warn-unused: true`

Detects stale exclusion rules that were suppressing issues that no longer exist:

```yaml
linters:
  exclusions:
    warn-unused: true
```

### Step 5: Remove `new-from-rev` When Clean

Once the codebase is clean, remove `new-from-rev` to enforce all issues for all files.
