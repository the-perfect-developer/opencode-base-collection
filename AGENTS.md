# OpenCode Base Collection — Agent Instructions

A curated collection of agents, skills, and commands for [OpenCode](https://opencode.ai).
This is a **content/configuration repository** — no application source code to compile or run.
All tools live under `.opencode/` (agents, skills, commands) and are written in Markdown.

## Project Structure

```
.opencode/
├── agents/        # Agent definition files (.md with YAML frontmatter)
├── commands/      # Slash command definitions (.md with YAML frontmatter)
├── skills/        # 35+ skill directories, each containing SKILL.md
├── package.json   # Bun package: @opencode-ai/plugin
└── bun.lock
.githooks/         # Version-controlled git hooks
├── pre-commit     # Orchestrator — runs all hooks in hooks.d/
└── hooks.d/       # Numbered hook scripts (10-, 20-, 30-, 40-)
scripts/           # Bash automation (install, setup, catalog generation)
pyproject.toml     # Ruff linter/formatter config (Python tooling only)
```

## Validation Commands

There is no build step. Validation is the primary quality gate.

```bash
# Validate all bash scripts (syntax only — does not execute)
bash -n scripts/install.sh
bash -n scripts/setup-hooks.sh

# Validate a specific skill
.opencode/skills/skill-creation/scripts/validate-skill.sh .opencode/skills/<skill-name>

# Run all pre-commit validations manually
.githooks/pre-commit

# Individual hook scripts
.githooks/hooks.d/10-validate-bash.sh      # bash -n on staged .sh files
.githooks/hooks.d/20-validate-skills.sh    # SKILL.md frontmatter validation
.githooks/hooks.d/30-validate-python-ruff.sh  # ruff lint + format check
.githooks/hooks.d/40-validate-eslint.sh    # ESLint on JS/TS files

# Python linting (Ruff)
ruff check .               # lint
ruff check --fix .         # lint + auto-fix
ruff format .              # format
ruff format --check .      # format check (CI mode, no writes)
```

### Set Up Git Hooks (first-time)

```bash
./scripts/setup-hooks.sh   # sets git core.hooksPath = .githooks
```

## Skill Validation Rules

A SKILL.md is valid when:
- Frontmatter delimiters `---` are present and well-formed
- `name` field: `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 chars, matches directory name
- `description` field: 1–1024 chars, should include quoted trigger phrases
- Body: 1500–2000 words ideal; move excess to `references/`
- Scripts in `scripts/` must be executable (`chmod +x`)

## Code Style Guidelines

### Bash Scripts

- Shebang: `#!/bin/bash` on every script
- Use `set -uo pipefail` (not `set -e`; avoid silent failures)
- Make scripts executable: `chmod +x`
- Validate with `bash -n` before committing
- Name hook scripts with numeric prefix: `<NN>-<description>.sh` (increments of 10)
- Exit early if no relevant staged files (fast-fail pattern)
- Use ANSI color constants (`RED`, `GREEN`, `YELLOW`, `NC`) for output
- Use `echo -e` with color variables for status messages
- Heredocs for multi-line usage text (`cat <<EOF ... EOF`)

### Markdown / SKILL.md Files

- YAML frontmatter block at the top between `---` delimiters
- Required frontmatter fields: `name`, `description`
- Optional frontmatter fields: `license`, `compatibility`, `metadata`
- `name` must be lowercase-hyphenated and match the parent directory name
- `description` must include quoted trigger phrases (e.g., `"create a skill"`)
- Use ATX headings (`#`, `##`, `###`), not Setext style
- Fenced code blocks with language tag (` ```bash `, ` ```yaml `, etc.)
- Progressive disclosure: keep SKILL.md body focused; put deep-dives in `references/`

### Agent Files (`.opencode/agents/*.md`)

YAML frontmatter fields:
```yaml
---
description: "..."
mode: subagent
tools:
  write: true|false
  edit: true|false
  bash: true
  webfetch: true
permission:
  write: ask          # implementers only
  edit: ask           # implementers only (consultants omit or set ask)
  bash:
    "*": ask          # REQUIRED: default deny-with-prompt for all bash
    "ls*": allow
    # ... per-command overrides (see below)
  webfetch: allow
---
```

#### Agent Roles

| Role | Agents | `tools.write` | `tools.edit` | Can commit? |
|---|---|---|---|---|
| Consultant | architect, code-analyst, performance-engineer, security-expert | `false` | `false` | No |
| Implementer | backend-engineer, frontend-engineer, junior-engineer | `true` | `true` | Yes |

#### Bash Permission Model

All agents share a common baseline of `allow` rules, with role-specific additions:

**Universal (all 7 agents — always `allow`)**
- Filesystem read: `ls*`, `pwd`, `which*`, `whoami`, `cat*`, `head*`, `tail*`, `wc*`, `file*`, `stat*`, `du*`, `df*`
- Search & text: `grep*`, `rg*`, `find*`, `tree*`, `awk*`, `sort*`, `cut*`, `uniq*`, `tr*`, `comm*`, `diff*`, `jq*`, `yq*`
- Output: `echo*`, `printf*`
- Environment: `env`, `printenv*`
- System info: `uname*`, `arch`, `nproc`, `hostname`, `uptime`, `free*`, `date`, `date +*`
- File integrity: `sha256sum*`, `md5sum*`, `sha1sum*`
- Runtime versions (exact strings, no globs): `node --version`, `node -v`, `python --version`, `python3 --version`, `go version`, `go env*`, `rustc --version`, `cargo --version`, `bun --version`, `deno --version`, `java --version`, `ruby --version`, `npm --version`, `yarn --version`, `pnpm --version`
- Package inspection: `npm ls*`, `npm list*`, `npm view*`, `pip list`, `pip show*`, `pip freeze`, `go list*`, `cargo metadata`, `cargo tree*`, `gem list`
- Process inspection: `pgrep*`, `pidof*` (but `ps*` and `lsof*` are `ask`)
- Git read: `git status`, `git diff*`, `git log*`, `git show*`, `git branch*`, `git remote*`, `git ls-files*`, `git blame*`, `git describe*`, `git rev-parse*`, `git stash list`, `git tag`, `git tag -l*`, `git config --get*`
- `/tmp` sandbox: `"* /tmp*": allow`

**Always `ask` (all 7 agents)**
- Network: `curl*`, `ping*`, `dig*`, `nslookup*`, `ss*`, `netstat*`
- Process inspection: `ps*`, `lsof*`
- `make -n*`

**Consultant-specific additions**
- performance-engineer: timing/profiling (`time *`, `hyperfine*`, `vmstat*`, `iostat*`, `sar*`, `lscpu`, `ulimit -a`, `sysctl -n*`, `sysctl -a`), benchmarking (`ab *`, `wrk *`, `perf stat*`, `perf record * /tmp*`, `perf report*`), language profilers (`py-spy*`, `python -m cProfile*`, `python -m timeit*`, `go test -bench*`, `go tool pprof*`, `node --cpu-prof*`, etc.)
- security-expert: `getfacl*`, `npm audit`, `yarn audit`, `pnpm audit`, `pip-audit*`, `cargo audit*`, `openssl x509*`

**Implementer-specific additions**
- Git write: `git add*`, `git commit*`, `git stash*`, `git switch*` (`allow`); `git checkout*`, `git push*`, `git reset*`, `git merge*`, `git rebase*`, `git tag*` (`ask`)
- Package managers: `npm install`, `npm ci`, `npm run dev/build/test/lint/format`, `yarn install/dev/build/test`, `pnpm install/dev/build/test`, `bun install`, `bun run*`
- Language build/test: `python -m pytest*`, `pytest*`, `pip install*`, `uv pip install*`, `ruff check/format*`, `mypy*`, `go test/build/run*`, `go mod tidy/download`, `cargo test/build/run/fmt/clippy*`
- Filesystem write: `mkdir*`, `touch*` (`allow`); `cp*`, `mv*`, `rm*`, `chmod*`, `ln -s*` (`ask`)
- Syntax validation: `bash -n*`

#### Safety Rules When Authoring Permissions

- Use **exact strings** for version checks — never bare globs: `"node --version": allow` not `"node*": allow`
- Do NOT use `"git tag*"` glob — use `"git tag": allow` and `"git tag -l*": allow` separately (the glob would also match `git tag -d`)
- Do NOT use `"date*"` glob — use `"date": allow` and `"date +*": allow` separately (the glob matches `date -s` which sets system time)
- Do NOT give consultants `tee*`, `patch*`, or `xargs*` — they write files or execute arbitrary commands
- Keep `rm*`, `docker exec*`, `git push*`, `git reset*` at `ask` — never `allow`
- `/tmp` sandbox (`"* /tmp*": allow`) covers all subpaths — no need for additional `/tmp` rules

### TypeScript (Google Style — enforced by ESLint)

- Named exports only; never `export default`
- `const`/`let` only; never `var`
- `interface` preferred over `type` for object shapes
- Single quotes for strings; template literals for interpolation
- `UpperCamelCase` classes, `lowerCamelCase` functions/variables, `CONSTANT_CASE` constants
- File names: `lowercase-with-dashes.ts`
- `.js` extension required in import paths (ESM)
- 2-space indentation, semicolons required

### Python (Google Style — enforced by Ruff)

- Line length: 88 chars; indentation: 4 spaces
- `snake_case` functions/variables, `PascalCase` classes, `UPPER_CASE` constants
- Import order: stdlib → third-party → local (enforced by `I` rule set)
- Full package import paths (avoid ambiguous single-name imports)
- Type annotations on all function signatures
- `"""` triple-quoted docstrings with Args/Returns/Raises sections
- `unfixable = ["F401"]`: unused imports are flagged, not auto-removed
- Quote style: double quotes

### JavaScript (Google Style)

- 2-space indentation, semicolons required
- K&R brace style; always use braces for control structures
- Named exports only; `.js` extension in import paths
- Arrow functions preferred for callbacks
- `lowerCamelCase` variables/functions, `UpperCamelCase` classes

## Commit Conventions

All commits **must** follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

Examples:
```
feat(skills): add htmx skill with Alpine.js integration
fix(hooks): correct ruff check exit code handling
docs(readme): update installation instructions
chore(catalog): regenerate opencode-catalog.json
```

Breaking changes: append `!` after type/scope or add `BREAKING CHANGE:` footer.

## Adding New Content

### New Skill

1. Create directory: `.opencode/skills/<skill-name>/`
2. Create `SKILL.md` with required frontmatter (`name`, `description`)
3. Ensure `name` matches directory name exactly
4. Validate: `.opencode/skills/skill-creation/scripts/validate-skill.sh .opencode/skills/<skill-name>`
5. Register in `.opencode/package.json` if needed
6. Regenerate catalog: `bash ./scripts/generate-catalog.sh`

### New Agent

1. Create `.opencode/agents/<agent-name>.md`
2. Include all required YAML frontmatter fields
3. Decide role: consultant (`write: false`) or implementer (`write: true`)

### New Command

1. Create `.opencode/commands/<command-name>.md`
2. Define `agent` and optionally `agents` in frontmatter
3. Command name becomes the slash command: `/command-name`

## CI/CD Pipelines

| Workflow | Trigger | Action |
|---|---|---|
| `validate-bash.yml` | PR/push to `main` | `bash -n` all `.sh` files |
| `validate-skills.yml` | PR/push to `main` | Validate all `SKILL.md` frontmatter |
| `generate-catalog.yml` | Push to `main` | Auto-regenerate `opencode-catalog.json` |
| `generate-tools-docs.yml` | Push to `main` | Auto-regenerate `docs/tools-reference.md` |

Do **not** manually edit `opencode-catalog.json` or `docs/tools-reference.md` — they are auto-generated.
