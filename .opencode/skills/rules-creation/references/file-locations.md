# File Locations and Precedence

Complete guide to where OpenCode looks for rules files and how precedence works.

## File Search Locations

OpenCode searches for rules in multiple locations with specific precedence rules.

### Project-Local Rules

OpenCode searches up from the current directory to the git repository root (or filesystem root if not in a git repo).

**Search order** (first match wins):
1. `./AGENTS.md`
2. `./CLAUDE.md`
3. `../AGENTS.md`
4. `../CLAUDE.md`
5. (continues up directory tree)

**Use cases**:
- Project-specific code standards
- Team conventions
- Project architecture
- Technology stack details
- Build and deployment workflows

**Version control**: Always commit project-local rules to Git to share with team.

### Global Rules

Located in user configuration directories.

**Search order** (first match wins):
1. `~/.config/opencode/AGENTS.md`
2. `~/.claude/CLAUDE.md` (unless disabled)

**Use cases**:
- Personal coding preferences
- Communication style preferences
- Tool preferences
- Cross-project conventions

**Version control**: Global rules are personal and should NOT be committed to Git.

### Custom Instructions

Specified in configuration files via the `instructions` field.

**Project configuration** (`opencode.json` in project root):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md"
  ]
}
```

**Global configuration** (`~/.config/opencode/opencode.json`):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "~/.config/mycompany/style-guide.md",
    "https://raw.githubusercontent.com/my-org/shared-rules/main/standards.md"
  ]
}
```

**Supported**:
- **Local file paths** - Relative to configuration file location
- **Absolute paths** - Start with `/` or `~/`
- **Glob patterns** - `**/*.md`, `packages/*/AGENTS.md`, etc.
- **Remote URLs** - HTTP/HTTPS (5 second timeout)

**Use cases**:
- Reuse existing documentation (CONTRIBUTING.md, etc.)
- Share standards across projects
- Centralized company/team guidelines
- Avoid duplicating content to AGENTS.md

## Precedence Rules

### File Type Precedence

Within each category (local vs global), OpenCode prefers OpenCode-native files:

**Local files**:
1. `AGENTS.md` (OpenCode native)
2. `CLAUDE.md` (Claude Code compatibility)

**Global files**:
1. `~/.config/opencode/AGENTS.md` (OpenCode native)
2. `~/.claude/CLAUDE.md` (Claude Code compatibility)

If both exist in the same location, only the OpenCode-native file is used.

### Combined Loading

OpenCode combines all matched files:
- **One local file** (AGENTS.md or CLAUDE.md from closest directory)
- **One global file** (~/.config/opencode/AGENTS.md or ~/.claude/CLAUDE.md)
- **All instruction files** from `opencode.json` configurations

All files are concatenated and provided to the LLM together.

### Instruction File Loading

Instruction files from `opencode.json` are loaded in addition to AGENTS.md files:

**Example scenario**:
```
Project has:
- /project/AGENTS.md
- /project/CONTRIBUTING.md
- /project/docs/api-guide.md

opencode.json:
{
  "instructions": ["CONTRIBUTING.md", "docs/api-guide.md"]
}

Result: All three files loaded
```

Glob patterns expand and all matching files load.

## Directory Traversal

### How Traversal Works

OpenCode starts from the current working directory and searches up:

```
/home/user/projects/myapp/src/components/
  - Check AGENTS.md, CLAUDE.md
/home/user/projects/myapp/src/
  - Check AGENTS.md, CLAUDE.md
/home/user/projects/myapp/
  - Check AGENTS.md, CLAUDE.md (FOUND - use this)
  - STOP if git repository root
/home/user/projects/
  - Only checked if not in git repo
```

**Stopping conditions**:
1. File found (AGENTS.md or CLAUDE.md)
2. Git repository root reached
3. Filesystem root reached

### Monorepo Considerations

In monorepos, place rules at appropriate levels:

**Option 1: Root-level rules**
```
monorepo/
├── AGENTS.md           ← Shared across all packages
├── packages/
│   ├── api/
│   └── web/
```

**Option 2: Package-level rules**
```
monorepo/
├── AGENTS.md           ← General monorepo info
├── packages/
│   ├── api/
│   │   └── AGENTS.md   ← API-specific rules (used when in api/)
│   └── web/
│       └── AGENTS.md   ← Web-specific rules (used when in web/)
```

OpenCode uses the **closest** AGENTS.md file up the tree.

**Alternative: Custom instructions**
```
monorepo/
├── opencode.json
├── packages/
│   ├── api/
│   │   └── AGENTS.md
│   └── web/
│       └── AGENTS.md

opencode.json:
{
  "instructions": ["packages/*/AGENTS.md"]
}
```

This loads **all** package AGENTS.md files together.

## Claude Code Compatibility

### Compatibility Files

OpenCode supports Claude Code file conventions as fallbacks:

**Local**:
- `CLAUDE.md` - Used if no `AGENTS.md` in directory tree

**Global**:
- `~/.claude/CLAUDE.md` - Used if no `~/.config/opencode/AGENTS.md`

### Migration Path

**Step 1**: Keep existing CLAUDE.md files working (no action needed)

**Step 2**: Gradually migrate to OpenCode conventions:
```bash
# Rename local files
mv CLAUDE.md AGENTS.md

# Rename global file
mv ~/.claude/CLAUDE.md ~/.config/opencode/AGENTS.md
```

**Step 3**: Optionally disable Claude Code compatibility:
```bash
export OPENCODE_DISABLE_CLAUDE_CODE=1
```

### Disabling Compatibility

Control Claude Code support via environment variables:

**Disable all .claude support**:
```bash
export OPENCODE_DISABLE_CLAUDE_CODE=1
```

**Disable only ~/.claude/CLAUDE.md**:
```bash
export OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=1
```

**Disable only ~/.claude/skills**:
```bash
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1
```

Set in your shell profile (~/.bashrc, ~/.zshrc) to persist.

## Configuration Files

### Project opencode.json

Place in project root to configure project-specific instructions:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "CONTRIBUTING.md",
    "docs/style-guide.md",
    ".cursor/rules/*.md"
  ]
}
```

**Should commit**: Yes, share with team

### Global opencode.json

Place at `~/.config/opencode/opencode.json` for personal cross-project instructions:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "~/.config/mycompany/coding-standards.md",
    "https://raw.githubusercontent.com/my-org/standards/main/rules.md"
  ]
}
```

**Should commit**: No, personal configuration

## Path Resolution

### Relative Paths

Relative paths in `opencode.json` resolve from the config file location:

**Project config** (`/project/opencode.json`):
```json
{
  "instructions": ["docs/guide.md"]
}
// Resolves to: /project/docs/guide.md
```

**Global config** (`~/.config/opencode/opencode.json`):
```json
{
  "instructions": ["rules/standards.md"]
}
// Resolves to: ~/.config/opencode/rules/standards.md
```

### Absolute Paths

Absolute paths work as expected:

```json
{
  "instructions": [
    "/home/user/shared/rules.md",
    "~/Documents/standards.md"
  ]
}
```

Tilde (`~`) expands to home directory.

### Glob Patterns

Glob patterns support standard wildcards:

```json
{
  "instructions": [
    "docs/**/*.md",           // All .md files in docs/ recursively
    "packages/*/AGENTS.md",   // AGENTS.md in each package
    ".cursor/rules/*.md"      // All .md in .cursor/rules/
  ]
}
```

**Glob syntax**:
- `*` - Matches any characters except `/`
- `**` - Matches any characters including `/` (recursive)
- `?` - Matches single character
- `[abc]` - Matches any character in brackets

### Remote URLs

Remote URLs fetch content with a 5 second timeout:

```json
{
  "instructions": [
    "https://raw.githubusercontent.com/my-org/standards/main/coding.md",
    "https://company.com/engineering/rules.md"
  ]
}
```

**Limitations**:
- 5 second timeout per URL
- HTTPS recommended for security
- Content cached per session (not persistent)
- Failed fetches logged but don't block session

## Best Practices

### Choosing File Locations

**Use project AGENTS.md for**:
- Team-shared standards
- Project-specific architecture
- Technology stack conventions
- Build/deploy procedures

**Use global AGENTS.md for**:
- Personal coding style
- Communication preferences
- Cross-project patterns
- Tool preferences

**Use opencode.json instructions for**:
- Reusing existing docs
- Sharing org-wide standards
- Avoiding duplication
- Dynamic file loading (globs)

### Organizing Multiple Files

**Pattern 1: Single AGENTS.md** (simple projects)
```
project/
└── AGENTS.md
```

**Pattern 2: AGENTS.md + instructions** (reuse existing docs)
```
project/
├── AGENTS.md
├── CONTRIBUTING.md
├── docs/
│   └── standards.md
└── opencode.json
```

**Pattern 3: Modular instructions** (complex projects)
```
project/
├── opencode.json
└── .opencode/
    └── rules/
        ├── code-style.md
        ├── api-design.md
        └── testing.md
```

### Version Control

**Always commit**:
- Project AGENTS.md
- Project opencode.json
- Referenced instruction files

**Never commit**:
- Global AGENTS.md (~/.config/opencode/)
- Global opencode.json
- Personal preference files

### Performance Considerations

**File count**: Each instruction file adds to context size
- Keep total instruction content under 10,000 words
- Use specific globs rather than broad patterns
- Reference files on-demand rather than loading all upfront

**Remote URLs**: Network latency can slow session startup
- Limit to 2-3 remote URLs
- Cache locally if fetched frequently
- Use local files when possible

## Troubleshooting

### Rules not loading

**Check file names**:
```bash
# Correct
AGENTS.md

# Incorrect
agents.md
Agents.md
AGENTS.MD
```

**Check locations**:
```bash
# Verify project file exists
ls -la AGENTS.md

# Verify global file exists
ls -la ~/.config/opencode/AGENTS.md
```

**Check git repo boundary**:
```bash
# Find git root
git rev-parse --show-toplevel

# AGENTS.md should be at or above this path
```

### Custom instructions not loading

**Validate JSON syntax**:
```bash
# Check for JSON errors
cat opencode.json | jq .
```

**Check paths exist**:
```bash
# Test glob pattern
ls -la docs/**/*.md

# Verify file exists
cat CONTRIBUTING.md
```

**Test remote URLs**:
```bash
# Check URL is accessible
curl -I https://example.com/rules.md
```

### Precedence issues

**Check which file is used**:
```bash
# OpenCode uses first match up the tree
find . -name "AGENTS.md" -o -name "CLAUDE.md"

# Check global
ls -la ~/.config/opencode/AGENTS.md ~/.claude/CLAUDE.md
```

**Disable Claude Code compatibility if conflicts occur**:
```bash
export OPENCODE_DISABLE_CLAUDE_CODE=1
```

### Multiple rules conflicts

If different rule files conflict:
1. OpenCode concatenates all matched files
2. Later rules don't override earlier ones
3. LLM tries to follow all instructions together

**Solution**: Consolidate or clarify conflicting rules in one location.
