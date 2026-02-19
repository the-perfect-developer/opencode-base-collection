---
name: conventional-git-commit
description: This skill MUST be loaded on every git commit without exception. It should also be used when the user asks to "write a conventional commit", "format a commit message", "follow conventional commits spec", "create a semantic commit", "make a commit", "commit changes", or "git commit". Every commit message produced in this project MUST conform to this specification.
---

# Conventional Git Commit

> **MANDATORY RULE**: Every git commit message in this project MUST follow the Conventional Commits 1.0.0 specification. No exceptions. A commit with a non-conforming message MUST be rejected and rewritten before proceeding.

Produces git commit messages that conform to the [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification — a lightweight, machine-readable convention that maps directly to Semantic Versioning.

## Commit Message Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Every part of this structure is defined by strict rules:

- **type** — Required. A noun indicating the category of change.
- **scope** — Optional. A noun in parentheses narrowing the affected area, e.g. `fix(parser):`.
- **`!`** — Optional. Appended immediately before `:` to flag a breaking change.
- **description** — Required. A short, imperative-mood summary immediately after the colon+space.
- **body** — Optional. One blank line after the description; free-form paragraphs.
- **footers** — Optional. One blank line after the body; `Token: value` or `Token #value` pairs.

## Core Types

| Type | SemVer impact | When to use |
|------|--------------|-------------|
| `feat` | MINOR | Introduces a new feature |
| `fix` | PATCH | Patches a bug |
| `docs` | none | Documentation changes only |
| `style` | none | Formatting, whitespace, missing semicolons |
| `refactor` | none | Code change that is neither a fix nor a feature |
| `perf` | none | Performance improvement |
| `test` | none | Adding or correcting tests |
| `build` | none | Build system or external dependency changes |
| `ci` | none | CI/CD configuration changes |
| `chore` | none | Routine tasks, maintenance, tooling |
| `revert` | varies | Reverts a previous commit |

Only `feat` and `fix` have implicit SemVer meaning. All others carry no automatic version bump unless accompanied by a breaking change marker.

## Breaking Changes

Two equivalent methods exist — use either or both:

**Method 1 — `!` after type/scope:**
```
feat(api)!: remove deprecated endpoint /v1/users
```

**Method 2 — `BREAKING CHANGE` footer:**
```
feat(api): remove deprecated endpoint /v1/users

BREAKING CHANGE: /v1/users is removed. Migrate to /v2/users.
```

**Both combined** (maximum visibility):
```
feat(api)!: remove deprecated endpoint /v1/users

BREAKING CHANGE: /v1/users is removed. Migrate to /v2/users.
```

A breaking change MUST use uppercase `BREAKING CHANGE` in the footer. `BREAKING-CHANGE` is a valid synonym.

## Workflow: Writing a Commit Message

**Step 1 — Identify the primary intent:**
Determine whether the change adds a feature, fixes a bug, or is maintenance/housekeeping.

**Step 2 — Choose the type:**
Pick the single most appropriate type from the table above. If a change spans multiple types, split it into separate commits.

**Step 3 — Determine scope (optional):**
Choose a short noun representing the affected module, component, or area: `auth`, `parser`, `api`, `ui`, `deps`.

**Step 4 — Detect breaking changes:**
Ask: "Does this change require consumers to update their code?" If yes, apply `!` and/or add a `BREAKING CHANGE` footer.

**Step 5 — Write the description:**
- Use imperative mood: "add", "fix", "remove", "update" — not "added", "fixes", "removing"
- Keep under 72 characters
- Do not capitalize the first letter (consistency convention)
- Do not end with a period

**Step 6 — Add body if needed:**
Explain the *why*, not the *what*. Wrap at 72 characters. Separate from description with one blank line.

**Step 7 — Add footers if needed:**
Reference issues, reviewers, or co-authors using `Token: value` format.

## Quick Examples

```
feat: add OAuth2 login support
```
```
fix(auth): prevent session expiry on page refresh
```
```
docs: update API reference for /v2/search endpoint
```
```
refactor(parser): extract token validation into separate module
```
```
perf(db): add index on users.email for faster lookup
```
```
chore(deps): bump lodash from 4.17.20 to 4.17.21
```
```
feat!: drop support for Node.js 14

BREAKING CHANGE: minimum required Node.js version is now 18.
```
```
fix: prevent racing of requests

Introduce a request id and a reference to the latest request.
Dismiss incoming responses other than from the latest request.

Reviewed-by: Alice
Refs: #123
```

## Footer Conventions

Footers follow git trailer format — `Token: value` or `Token #value`:

| Footer | Purpose |
|--------|---------|
| `BREAKING CHANGE: <desc>` | Documents a breaking API change |
| `Refs: #123` | Links to a related issue or PR |
| `Reviewed-by: Name` | Credits a code reviewer |
| `Co-authored-by: Name <email>` | Credits a co-author |
| `Fixes: #456` | Closes an issue on merge |

Token names use hyphens instead of spaces (e.g. `Co-authored-by`). `BREAKING CHANGE` is the sole exception — it may contain a space.

## Scope Guidelines

Scopes are project-specific nouns. Common patterns:

- **By module**: `feat(auth):`, `fix(parser):`, `test(api):`
- **By layer**: `refactor(db):`, `perf(cache):`, `build(docker):`
- **By UI area**: `feat(login):`, `style(nav):`, `fix(modal):`

Keep scopes consistent within a project. Define the allowed scope list in a contributing guide or commitlint config if the team is large.

## SemVer Mapping

| Commit type | Resulting version bump |
|-------------|----------------------|
| `fix` | PATCH (0.0.x) |
| `feat` | MINOR (0.x.0) |
| Any type with `BREAKING CHANGE` or `!` | MAJOR (x.0.0) |

Tools such as `semantic-release` and `standard-version` parse commit history to automate this version bump.

## Common Mistakes to Avoid

- **Vague descriptions**: `fix: bug` → `fix(auth): handle null token in session middleware`
- **Wrong type**: using `chore` for a bug fix; use `fix`
- **Multiple intents in one commit**: one commit = one logical change
- **Missing blank line before body or footers**: parsers rely on the blank line separator
- **Lowercase `breaking change` in footer**: MUST be `BREAKING CHANGE` (uppercase)
- **Missing space after colon**: `feat:description` is invalid; must be `feat: description`

## Additional Resources

### Reference Files

- **`references/commit-types.md`** — Detailed guidance and examples for every commit type, including edge cases and when types overlap
- **`references/advanced-patterns.md`** — Breaking changes, multi-footer commits, revert commits, monorepo scopes, and tooling integration (commitlint, semantic-release)
