# Complete Frontmatter Specification

This document provides the complete specification for SKILL.md YAML frontmatter in OpenCode.

## Overview

Every `SKILL.md` file must begin with YAML frontmatter delimited by `---`. The frontmatter contains metadata that OpenCode uses for skill discovery and loading.

## Format

```yaml
---
name: skill-name
description: This skill should be used when...
license: MIT
compatibility: opencode
metadata:
  key1: value1
  key2: value2
---
```

The frontmatter block must:
- Start with `---` on its own line
- End with `---` on its own line
- Contain valid YAML
- Include required fields (name, description)
- Appear before any markdown content

## Required Fields

### name

**Type**: String  
**Length**: 1-64 characters  
**Pattern**: `^[a-z0-9]+(-[a-z0-9]+)*$`  
**Required**: Yes

The skill identifier used for loading and discovery.

**Rules**:
- Must be lowercase only
- Alphanumeric characters and hyphens only
- Single hyphens only (no consecutive `--`)
- Cannot start with a hyphen
- Cannot end with a hyphen
- Must match the directory name containing SKILL.md

**Valid examples**:
- `git-release`
- `api-design`
- `frontend-testing`
- `python3-development`
- `react`
- `sql-optimization`

**Invalid examples**:
- `Git-Release` (uppercase)
- `-git-release` (starts with hyphen)
- `git-release-` (ends with hyphen)
- `git--release` (consecutive hyphens)
- `git_release` (underscore not allowed)
- `git release` (space not allowed)

**Regex pattern**:
```regex
^[a-z0-9]+(-[a-z0-9]+)*$
```

Breaking down the pattern:
- `^` - Start of string
- `[a-z0-9]+` - One or more lowercase letters or digits
- `(-[a-z0-9]+)*` - Zero or more groups of (hyphen followed by one or more lowercase letters or digits)
- `$` - End of string

**Validation**:
```bash
# Valid if exit code is 0
echo "skill-name" | grep -E '^[a-z0-9]+(-[a-z0-9]+)*$'
```

**Directory matching**:
The name must match the directory containing SKILL.md:

```
✓ Correct:
.opencode/skills/git-release/SKILL.md
  name: git-release

✗ Incorrect:
.opencode/skills/git-release/SKILL.md
  name: release-helper  # Name doesn't match directory
```

### description

**Type**: String  
**Length**: 1-1,024 characters  
**Required**: Yes

Describes when and why agents should load this skill.

**Purpose**:
The description determines whether agents load your skill. It should:
- Include specific trigger phrases users would say
- Be concrete about use cases
- Provide enough context for agents to decide relevance

**Format guidelines**:
- Put user trigger phrases in quotes
- Use commas to separate trigger phrases
- End with broader context about what the skill provides
- Be specific, not generic

**Good descriptions**:

```yaml
description: This skill should be used when the user asks to "create a database schema", "design SQL tables", "optimize queries", "normalize data", or needs guidance on relational database design, indexing strategies, or query performance.
```

Why good:
- Multiple specific trigger phrases in quotes
- Concrete user language ("create a database schema")
- Additional context (relational database design, indexing)
- Clear use cases

```yaml
description: This skill should be used when the user asks to "deploy to production", "set up CI/CD pipeline", "configure deployment workflow", or needs guidance on deployment automation, rollback strategies, or environment configuration.
```

Why good:
- Action-oriented trigger phrases
- Covers related concepts (CI/CD, workflows)
- Includes edge cases (rollback strategies)

**Bad descriptions**:

```yaml
description: Helps with databases.
```

Why bad:
- Too vague
- No trigger phrases
- No specific use cases
- Agents won't know when to load it

```yaml
description: Use this skill for SQL work.
```

Why bad:
- Not specific enough
- Missing trigger phrases
- Doesn't describe what kind of SQL work

```yaml
description: Database schema design, query optimization, indexing.
```

Why bad:
- No trigger phrases
- Just keywords, not complete sentences
- Doesn't indicate when to use

**Length**:
- Minimum: 1 character (but be more descriptive)
- Maximum: 1,024 characters
- Sweet spot: 150-300 characters
- Include 3-5 trigger phrases

**Testing descriptions**:
To test if your description is good, ask:
1. Would an agent know when to load this skill?
2. Are there specific phrases a user would say?
3. Does it clearly differentiate from other skills?
4. Is it concrete rather than vague?

## Optional Fields

### license

**Type**: String  
**Required**: No  
**Default**: None

The license under which the skill is distributed.

**Common values**:
- `MIT`
- `Apache-2.0`
- `GPL-3.0`
- `BSD-3-Clause`
- `Proprietary`

**Example**:
```yaml
license: MIT
```

Use standard SPDX license identifiers when possible.

### compatibility

**Type**: String  
**Required**: No  
**Default**: None

The platform or system this skill targets.

**Common values**:
- `opencode` - OpenCode-specific skills
- `claude` - Claude-compatible skills (works in Claude Code too)
- `agents` - Generic agent skills

**Example**:
```yaml
compatibility: opencode
```

This field is informational and doesn't affect loading behavior.

### metadata

**Type**: Object (string-to-string map)  
**Required**: No  
**Default**: None

Custom key-value pairs for additional metadata.

**Rules**:
- Keys must be strings
- Values must be strings
- Use for any custom metadata not covered by standard fields

**Common uses**:
- `author` - Skill creator
- `version` - Skill version
- `created` - Creation date
- `updated` - Last update date
- `category` - Skill category
- `tags` - Comma-separated tags

**Example**:
```yaml
metadata:
  author: Jane Developer
  version: 1.2.0
  created: 2024-01-15
  updated: 2024-03-20
  category: development
  tags: git, workflow, automation
```

**Note**: Metadata fields are preserved but not used by OpenCode for discovery or loading. They're useful for documentation and organization.

## Unknown Fields

Any frontmatter fields not listed in this specification are **ignored** by OpenCode.

```yaml
---
name: my-skill
description: This skill...
custom_field: ignored
another_field: also ignored
---
```

This allows forward compatibility if new fields are added in the future.

## Complete Example

Here's a complete frontmatter example with all standard fields:

```yaml
---
name: api-design
description: This skill should be used when the user asks to "design a REST API", "create API endpoints", "structure API responses", "version an API", or needs guidance on RESTful design principles, HTTP methods, status codes, or API documentation.
license: MIT
compatibility: opencode
metadata:
  author: API Team
  version: 2.1.0
  created: 2024-01-10
  updated: 2024-03-15
  category: architecture
  tags: api, rest, http, design
---

# API Design Skill

[Markdown content starts here...]
```

## Validation Rules

### Syntax Validation

Frontmatter must be valid YAML:

```yaml
# Valid
---
name: my-skill
description: This skill does X
---

# Invalid - missing closing ---
---
name: my-skill
description: This skill does X

# Invalid - malformed YAML
---
name my-skill
description: This skill does X
---

# Invalid - not at start of file
Some text before frontmatter
---
name: my-skill
description: This skill does X
---
```

### Required Field Validation

Both `name` and `description` must be present:

```yaml
# Valid
---
name: my-skill
description: This skill...
---

# Invalid - missing description
---
name: my-skill
---

# Invalid - missing name
---
description: This skill...
---

# Invalid - missing both
---
license: MIT
---
```

### Name-Directory Matching

The skill name must match the directory:

```
# Directory structure
.opencode/skills/git-helper/SKILL.md

# Valid SKILL.md
---
name: git-helper
description: ...
---

# Invalid SKILL.md - name doesn't match directory
---
name: git-tool
description: ...
---
```

## Parsing Behavior

OpenCode parses frontmatter with these behaviors:

**Case sensitivity**:
- Field names are case-sensitive
- Use lowercase field names (name, description, license, etc.)
- Values are case-preserved

**Whitespace**:
- Leading/trailing whitespace in values is trimmed
- Internal whitespace is preserved

**Quotes**:
- Values can be quoted or unquoted
- Use quotes for values with special characters
- Description often needs quotes due to punctuation

**Example**:
```yaml
---
name: my-skill  # Unquoted
description: "This skill should be used when the user asks to \"create X\", \"do Y\", or needs Z guidance."  # Quoted due to internal quotes
license: MIT  # Unquoted
---
```

## Common Mistakes

### Mistake 1: Uppercase in name

```yaml
# Wrong
name: Git-Release

# Right
name: git-release
```

### Mistake 2: Underscores in name

```yaml
# Wrong
name: git_release

# Right
name: git-release
```

### Mistake 3: Name doesn't match directory

```
Directory: .opencode/skills/api-helper/

# Wrong
---
name: api-design
---

# Right
---
name: api-helper
---
```

### Mistake 4: Vague description

```yaml
# Wrong - too vague
description: Helps with APIs

# Right - specific triggers
description: This skill should be used when the user asks to "create an API endpoint", "design REST API", "structure API response", or needs guidance on RESTful design patterns.
```

### Mistake 5: Missing trigger phrases

```yaml
# Wrong - no quotes around trigger phrases
description: This skill helps with database design and optimization.

# Right - quoted trigger phrases
description: This skill should be used when the user asks to "design a database schema", "optimize SQL queries", or needs database normalization guidance.
```

### Mistake 6: Description too long

```yaml
# Wrong - exceeds 1024 characters
description: This skill should be used when the user asks to... [3000 character description]

# Right - concise with essential triggers
description: This skill should be used when the user asks to "trigger 1", "trigger 2", "trigger 3", or needs guidance on topic X, Y, and Z.
```

## Validation Tools

### Manual Validation

Check frontmatter manually:

```bash
# Extract frontmatter
sed -n '/^---$/,/^---$/p' SKILL.md | sed '1d;$d'

# Check for required fields
grep "^name:" SKILL.md
grep "^description:" SKILL.md

# Validate name pattern
grep "^name: " SKILL.md | cut -d' ' -f2 | grep -E '^[a-z0-9]+(-[a-z0-9]+)*$'
```

### Automated Validation

Use the included validation script:

```bash
.opencode/skills/skill-creation/scripts/validate-skill.sh path/to/skill
```

The script checks:
- YAML syntax
- Required fields present
- Name pattern validation
- Name matches directory
- Description length
- Referenced files exist

## Best Practices

**DO**:
- Use lowercase names with hyphens
- Include 3-5 specific trigger phrases in quotes
- Keep descriptions under 300 characters when possible
- Match name to directory exactly
- Use standard SPDX license identifiers
- Add metadata for documentation

**DON'T**:
- Use uppercase, underscores, or spaces in names
- Write vague descriptions without triggers
- Exceed 1024 characters in description
- Mismatch name and directory
- Forget closing `---`
- Skip required fields

## Summary

**Minimal valid frontmatter**:
```yaml
---
name: skill-name
description: This skill should be used when the user asks to "do X", "do Y", or needs Z guidance.
---
```

**Recommended frontmatter**:
```yaml
---
name: skill-name
description: This skill should be used when the user asks to "trigger 1", "trigger 2", "trigger 3", or needs guidance on topic X and Y.
license: MIT
compatibility: opencode
metadata:
  author: Your Name
  version: 1.0.0
---
```

Follow these specifications to ensure your skill is properly discovered and loaded by OpenCode agents.
