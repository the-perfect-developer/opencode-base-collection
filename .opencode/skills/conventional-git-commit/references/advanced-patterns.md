# Advanced Patterns

Advanced usage of the Conventional Commits specification: breaking changes in depth, complex footer patterns, revert strategies, monorepo scopes, and tooling integration.

## Table of Contents

1. [Breaking Changes In Depth](#breaking-changes-in-depth)
2. [Footer Syntax Rules](#footer-syntax-rules)
3. [Multi-Footer Commits](#multi-footer-commits)
4. [Revert Commit Strategies](#revert-commit-strategies)
5. [Monorepo Scope Conventions](#monorepo-scope-conventions)
6. [Tooling Integration](#tooling-integration)
7. [Validation Checklist](#validation-checklist)

---

## Breaking Changes In Depth

A breaking change is any change that requires consumers to modify their code, configuration, or workflow.

### What Counts as Breaking

- Removing a public API method, endpoint, CLI flag, or configuration key
- Changing the signature of a public function (parameter types, order, count)
- Altering return value shape or type
- Changing default behaviour in a way that breaks existing integrations
- Renaming a public symbol without an alias
- Raising the minimum required runtime version

### What Does NOT Count as Breaking

- Adding new optional parameters with defaults
- Adding new fields to response objects (non-strict consumers)
- Internal refactors invisible to consumers
- Fixing a bug where the "old" behaviour was undocumented

### Marking a Breaking Change — Three Valid Forms

**Form 1: `!` only (minimum viable)**
```
feat(api)!: remove /v1/users endpoint
```
The description itself must convey what broke.

**Form 2: `BREAKING CHANGE` footer only**
```
feat(api): remove /v1/users endpoint

BREAKING CHANGE: The /v1/users endpoint is removed.
Migrate to /v2/users which returns the same data with
additional pagination metadata.
```

**Form 3: Both `!` and `BREAKING CHANGE` footer (recommended for major changes)**
```
feat(api)!: remove /v1/users endpoint

The v1 endpoint has been deprecated since 2.0.0 and is now removed.

BREAKING CHANGE: /v1/users is removed. Migrate to /v2/users.
Migration guide: https://docs.example.com/migration/v3
```

Form 3 is recommended for significant changes because:
- `!` provides immediate visual signal in `git log --oneline`
- The footer provides machine-readable detection for automation
- The body explains context and migration path

### BREAKING-CHANGE Synonym

`BREAKING-CHANGE` (with hyphen) is a valid synonym for `BREAKING CHANGE` in footers:

```
BREAKING-CHANGE: config key `database_url` renamed to `db.url`
```

Both forms trigger a MAJOR version bump in conforming tooling.

---

## Footer Syntax Rules

Footers follow [git trailer format](https://git-scm.com/docs/git-interpret-trailers) with two separator variants:

### Separator: `:<space>` (colon + space)

```
Reviewed-by: Alice <alice@example.com>
Co-authored-by: Bob <bob@example.com>
BREAKING CHANGE: environment variables now override config files
```

### Separator: `<space>#` (space + hash)

```
Refs #123
Fixes #456
Closes #789
```

### Token Rules

- Token names MUST use `-` instead of spaces: `Co-authored-by` not `Co authored by`
- Tokens are case-insensitive EXCEPT `BREAKING CHANGE` which MUST be uppercase
- `BREAKING CHANGE` is the only token that may contain a space

### Parsing Terminates on Next Valid Token

A footer value may span multiple lines. Parsing ends when the next `Token: ` or `Token #` pattern is encountered:

```
fix: stabilise request handling

Refs: #123
Long-description: This is a multi-line footer value.
It continues here because the next line does not start
with a valid token separator.
Reviewed-by: Alice
```

---

## Multi-Footer Commits

Complex commits may carry multiple footers. Order is flexible, but `BREAKING CHANGE` conventionally appears last:

```
feat(auth)!: add mandatory MFA for admin accounts

All accounts with admin role now require TOTP MFA on login.
Existing sessions will be invalidated on next deploy.

Co-authored-by: Alice <alice@example.com>
Reviewed-by: Bob <bob@example.com>
Refs: #401, #398
BREAKING CHANGE: Admin users must configure TOTP before next login.
See https://docs.example.com/mfa-setup for instructions.
```

### Issue-Closing Footers

Many Git hosts (GitHub, GitLab) recognise special keywords in footers that close issues on merge:

```
Fixes #123
Closes #456
Resolves #789
```

These follow `<space>#` separator syntax and close the referenced issue when the commit lands on the default branch.

---

## Revert Commit Strategies

The spec does not mandate a specific revert format, but this pattern is widely adopted:

### Single Commit Revert

```
revert: feat(search): add full-text search with relevance ranking

This reverts commit a3f8c21d due to memory leak under high load.
The feature will be re-introduced after fixing the allocator issue.

Refs: a3f8c21
```

### Multi-Commit Revert

```
revert: feat(api): introduce v2 response envelope format

Reverts the v2 format which caused parsing failures in legacy clients.

Refs: b4e9f12, c5d0a34, d6e1b56
```

### Revert of a Breaking Change

If the reverted commit introduced a breaking change, the revert is also a breaking change from the perspective of code that has already migrated:

```
revert!: feat(api)!: remove /v1/users endpoint

Restoring /v1/users for clients that cannot migrate in time.

BREAKING CHANGE: /v1/users is restored. Code relying on its
removal must be reverted.
Refs: e7f2c89
```

---

## Monorepo Scope Conventions

In monorepos, scopes prevent ambiguity between packages and prevent changelog pollution.

### Strategy 1: Package Name as Scope

```
feat(ui): add Tooltip component
fix(api): handle null user in /me endpoint
docs(cli): update --help output for deploy command
build(server): upgrade express to 5.0.0
```

Each package name becomes a valid scope. Define all valid scopes in the root contributing guide or commitlint config.

### Strategy 2: Domain as Scope

When multiple packages serve the same domain:

```
feat(auth): add refresh token rotation
fix(auth): prevent concurrent token refresh race
test(auth): cover token expiry boundary conditions
```

### Strategy 3: Hierarchical Scopes (not in spec, tooling-dependent)

Some projects use slash-separated or dot-separated scopes. This is NOT part of the spec but is accepted by some tools:

```
feat(ui/button): add loading state prop
fix(api/users): handle empty email on signup
```

Use only if the team's tooling explicitly supports it.

### Wildcard Scopes in commitlint

Configure allowed scopes in `commitlint.config.js`:

```js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-enum': [2, 'always', ['ui', 'api', 'auth', 'cli', 'docs', 'deps']],
  },
};
```

---

## Tooling Integration

### commitlint

Validates commit messages against the spec in CI or as a git hook.

**Install**:
```bash
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

**`commitlint.config.js`**:
```js
module.exports = {
  extends: ['@commitlint/config-conventional'],
};
```

**As a `commit-msg` hook** (via Husky):
```bash
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
```

### semantic-release

Automates version bumps and changelog generation from commit history.

**SemVer mapping**:
| Commit | Version bump |
|--------|-------------|
| `fix` | PATCH |
| `feat` | MINOR |
| Any with `BREAKING CHANGE` or `!` | MAJOR |

**`.releaserc.json`** (minimal):
```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/npm",
    "@semantic-release/github"
  ]
}
```

### standard-version (legacy)

Older alternative to semantic-release, still widely used:

```bash
npx standard-version       # auto-detect bump from commits
npx standard-version --dry-run  # preview without writing
```

### conventional-changelog

Generates a CHANGELOG from commit history:

```bash
npx conventional-changelog -p conventional -i CHANGELOG.md -s
```

---

## Validation Checklist

Before committing, verify each item:

**Structure**
- [ ] Message starts with a valid type (`feat`, `fix`, `docs`, etc.)
- [ ] Type is lowercase
- [ ] Scope (if present) is a single noun in parentheses: `fix(auth):`
- [ ] `!` (if used) appears immediately before `:` — `feat(api)!:` not `feat!(api):`
- [ ] A single space follows the colon: `feat: description` not `feat:description`
- [ ] Description does not start with a capital letter (by convention)
- [ ] Description does not end with a period

**Body**
- [ ] If body is present, there is exactly one blank line between description and body
- [ ] Body wraps at 72 characters per line

**Footers**
- [ ] If footers are present, there is exactly one blank line between body (or description) and footers
- [ ] Each footer uses `Token: value` or `Token #value` format
- [ ] Token names use hyphens, not spaces (`Co-authored-by`, not `Co authored by`)
- [ ] `BREAKING CHANGE` is uppercase in footers
- [ ] `BREAKING CHANGE` footer includes a description after the colon

**Breaking Changes**
- [ ] If consumers must update their code, the commit is marked as breaking
- [ ] Breaking change is communicated via `!`, `BREAKING CHANGE` footer, or both

**Intent**
- [ ] One commit covers one logical change
- [ ] The type accurately reflects the primary intent
- [ ] If multiple types apply, the commit has been split
