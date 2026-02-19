# Commit Types — Detailed Reference

Detailed guidance for every Conventional Commits type: when to use it, when NOT to use it, how it maps to SemVer, and worked examples.

## Table of Contents

1. [feat](#feat)
2. [fix](#fix)
3. [docs](#docs)
4. [style](#style)
5. [refactor](#refactor)
6. [perf](#perf)
7. [test](#test)
8. [build](#build)
9. [ci](#ci)
10. [chore](#chore)
11. [revert](#revert)
12. [Overlapping Types — Decision Guide](#overlapping-types--decision-guide)

---

## feat

**SemVer impact**: MINOR bump (0.x.0)

Introduces a new capability that did not exist before. "New" means from the consumer's perspective — if an end user or API caller gains an ability they didn't have, it is a `feat`.

**Use when**:
- Adding a new API endpoint, CLI flag, UI screen, or configuration option
- Implementing a previously unsupported protocol or standard
- Adding an opt-in behaviour that consumers must activate

**Do NOT use when**:
- Expanding internal implementation details invisible to consumers (use `refactor`)
- Restoring broken functionality to its documented state (use `fix`)
- Adding a new test file (use `test`)

**Examples**:
```
feat: add support for OAuth2 PKCE flow
feat(search): add full-text search with relevance ranking
feat(api)!: introduce v2 response envelope format
```

---

## fix

**SemVer impact**: PATCH bump (0.0.x)

Corrects behaviour that deviates from documented or expected behaviour. The system was broken in a detectable way; this commit makes it correct again.

**Use when**:
- Fixing a null pointer / undefined reference
- Correcting incorrect output or return values
- Resolving a race condition or data corruption bug
- Patching a security vulnerability

**Do NOT use when**:
- Changing behaviour that was never documented (use `refactor`)
- Adding missing features requested by users (use `feat`)
- Updating test assertions (use `test`)

**Examples**:
```
fix: handle empty array in sort utility
fix(auth): refresh token before it expires instead of after
fix(ui): prevent modal from closing when clicking backdrop
fix(deps): resolve peer dependency conflict with react@18
```

---

## docs

**SemVer impact**: none

Changes that affect documentation files only — no source code change.

**Use when**:
- Updating README, CHANGELOG, CONTRIBUTING, API reference
- Adding or fixing JSDoc / TSDoc / docstring comments
- Correcting typos in comments or markdown files
- Adding usage examples to documentation

**Do NOT use when**:
- Inline comments that affect logic readability but are adjacent to code changes (bundle with the primary type)
- Updating generated documentation as part of a release (use `chore` or `build`)

**Examples**:
```
docs: add example for pagination in REST guide
docs(api): document rate limiting headers
docs: fix broken links in CONTRIBUTING.md
```

---

## style

**SemVer impact**: none

Formatting changes that do not alter program logic or meaning — whitespace, semicolons, quotes, indentation.

**Use when**:
- Running a formatter (Prettier, Black, gofmt) on existing code
- Fixing lint warnings about style (trailing whitespace, max line length)
- Converting single quotes to double quotes project-wide

**Do NOT use when**:
- Renaming variables or functions (semantically meaningful — use `refactor`)
- Changing logic to satisfy a linter rule (use `fix` or `refactor`)

**Examples**:
```
style: apply Prettier formatting to src/
style(css): normalize spacing in button component
style: remove trailing whitespace across project
```

---

## refactor

**SemVer impact**: none

A code change that improves structure, readability, or maintainability without changing observable behaviour. Neither a bug fix nor a new feature from the consumer's perspective.

**Use when**:
- Extracting a function or class
- Renaming for clarity
- Simplifying complex logic with equivalent semantics
- Migrating from one internal pattern to another (e.g. callbacks → promises)
- Reorganising directory structure

**Do NOT use when**:
- The change fixes a bug (even if incidentally — use `fix`)
- The change adds new capability (use `feat`)
- The change is purely cosmetic formatting (use `style`)

**Examples**:
```
refactor(auth): extract token validation into TokenService class
refactor: replace callback chain with async/await
refactor(db): normalise user query builder patterns
refactor!: rename UserRecord to UserEntity across the codebase
```

---

## perf

**SemVer impact**: none (unless it changes observable API behaviour)

Code change whose primary purpose is improving runtime performance, memory usage, or throughput, without changing observable external behaviour.

**Use when**:
- Adding database indexes
- Replacing an O(n²) algorithm with O(n log n)
- Implementing caching for expensive computations
- Reducing bundle size through tree-shaking or lazy loading

**Do NOT use when**:
- The optimisation changes return values or side effects (use `fix` or `refactor`)
- The optimisation adds a new configuration option to enable it (use `feat`)

**Examples**:
```
perf(db): add composite index on (user_id, created_at)
perf: memoize expensive tax calculation
perf(images): switch to WebP format for 40% size reduction
```

---

## test

**SemVer impact**: none

Adding, updating, or fixing tests. No production code change.

**Use when**:
- Writing new unit, integration, or end-to-end tests
- Fixing broken or flaky tests
- Updating test fixtures or snapshots
- Refactoring test helpers

**Do NOT use when**:
- Test infrastructure changes affect the build (use `build`)
- Coverage tooling configuration changes (use `ci` or `build`)

**Examples**:
```
test: add unit tests for UserService.findById
test(auth): cover token expiry edge cases
test: update snapshots after UI refactor
test(e2e): add checkout flow integration test
```

---

## build

**SemVer impact**: none

Changes that affect the build system, compilation, or external dependencies.

**Use when**:
- Updating build tool configuration (webpack, vite, rollup, make)
- Adding or removing npm/yarn/pip/cargo dependencies
- Changing compilation targets or output formats
- Updating lockfiles after dependency upgrades

**Do NOT use when**:
- CI pipeline scripts change (use `ci`)
- Runtime configuration changes (use `chore` or `feat`)

**Examples**:
```
build: upgrade webpack from 4 to 5
build(deps): add zod for runtime schema validation
build: configure tree-shaking for production bundle
build(deps-dev): bump typescript to 5.4.0
```

---

## ci

**SemVer impact**: none

Changes to CI/CD configuration files and scripts.

**Use when**:
- Modifying GitHub Actions, GitLab CI, CircleCI, Jenkins files
- Updating deployment pipeline scripts
- Adding or removing CI jobs or stages
- Configuring automated release workflows

**Do NOT use when**:
- Changes affect local build tooling (use `build`)
- Changes affect runtime infrastructure (use `chore` or `feat`)

**Examples**:
```
ci: add automated release on tag push
ci(github): add code coverage reporting to PR checks
ci: cache node_modules between workflow runs
ci: fix failing deploy job on main branch
```

---

## chore

**SemVer impact**: none

Routine maintenance tasks that do not fit any other type and do not affect production code or tests.

**Use when**:
- Updating `.gitignore`, `.editorconfig`, or other meta-files
- Renaming or reorganising non-source files
- Housekeeping commits that would be invisible to end users
- Bumping version number in `package.json` manually

**Do NOT use when**:
- A more specific type applies (prefer `build`, `ci`, `docs`, `style`)
- The change touches production logic (even minor cleanup — use `refactor`)

**Examples**:
```
chore: update .gitignore to exclude .DS_Store
chore(release): bump version to 2.1.0
chore: remove unused environment variable from .env.example
```

---

## revert

**SemVer impact**: varies (mirrors the reverted commit)

Reverts a previous commit. The description should reference the reverted commit.

**Format**:
```
revert: <description of reverted commit>

Refs: <SHA of reverted commit(s)>
```

**Examples**:
```
revert: feat(search): add full-text search

Refs: a3f8c21

revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

---

## Overlapping Types — Decision Guide

These are the most common ambiguous cases:

### `fix` vs `refactor`

| Scenario | Type |
|----------|------|
| Code was wrong and now produces correct output | `fix` |
| Code was working; restructured for clarity | `refactor` |
| Code was subtly wrong; restructuring revealed and corrected it | `fix` (primary intent) |

### `feat` vs `refactor`

| Scenario | Type |
|----------|------|
| New public API, endpoint, or UI element added | `feat` |
| Internal reorganisation, no new public surface | `refactor` |
| New internal abstraction that enables a future feature | `refactor` |

### `build` vs `chore`

| Scenario | Type |
|----------|------|
| Dependency added/removed/upgraded | `build` |
| Build tool config changed | `build` |
| Non-build meta files updated (.gitignore, .editorconfig) | `chore` |

### `style` vs `refactor`

| Scenario | Type |
|----------|------|
| Formatter applied, no logic change | `style` |
| Variable renamed for clarity | `refactor` |
| Code reorganised for readability | `refactor` |

### When a commit touches multiple types

Split into separate commits. One commit = one logical change. This makes `git bisect`, changelogs, and reverts dramatically simpler.

If splitting is not practical, choose the type with the **highest SemVer impact**:
1. `fix` or `feat` with `BREAKING CHANGE` → MAJOR
2. `feat` → MINOR
3. `fix` → PATCH
4. Everything else → no bump
