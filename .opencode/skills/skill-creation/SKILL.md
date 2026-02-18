---
name: skill-creation
description: This skill should be used when the user asks to "create a skill", "write a new skill", "add a skill", "SKILL.md format", "skill frontmatter", or needs guidance on skill structure, progressive disclosure, or OpenCode skill development.
---

# Skill Creation for OpenCode

Create reusable, discoverable skills that extend OpenCode's capabilities through on-demand loading.

## What Skills Are

Skills are modular instruction sets that OpenCode agents can load when needed. Each skill provides:

- **Specialized workflows** - Multi-step procedures for specific domains
- **Domain expertise** - Project-specific knowledge, schemas, conventions
- **Tool integrations** - Instructions for working with specific formats or APIs
- **Bundled resources** - Scripts, references, and assets for complex tasks

Skills use **progressive disclosure**: agents see skill names and descriptions initially, then load full content only when triggered by relevant user requests.

## Quick Start

Create a skill in three steps:

1. **Create directory structure**:
   ```bash
   mkdir -p .opencode/skills/my-skill
   cd .opencode/skills/my-skill
   touch SKILL.md
   ```

2. **Add frontmatter** to `SKILL.md`:
   ```yaml
   ---
   name: my-skill
   description: This skill should be used when the user asks to "do X", "configure Y", or needs Z guidance.
   ---
   ```

3. **Add markdown content** below frontmatter explaining what the skill does and how to use it.

That's it! OpenCode will automatically discover and offer the skill to agents.

## File Locations

OpenCode searches for skills in these locations (in order):

**Project-local** (searches up to git worktree):
- `.opencode/skills/<name>/SKILL.md`
- `.claude/skills/<name>/SKILL.md`
- `.agents/skills/<name>/SKILL.md`

**Global** (user-wide):
- `~/.config/opencode/skills/<name>/SKILL.md`
- `~/.claude/skills/<name>/SKILL.md`
- `~/.agents/skills/<name>/SKILL.md`

Use project-local for repository-specific workflows. Use global for general-purpose skills.

## Skill Creation Workflow

### Step 1: Understand the Use Case

Before creating a skill, clarify:

- **What problem does it solve?** - Identify specific user requests or workflows
- **What would users say?** - Collect concrete trigger phrases
- **What context is needed?** - Determine required domain knowledge

Example: For a `git-release` skill, users might say "create a release", "draft changelog", or "tag a new version".

### Step 2: Plan the Structure

Decide what resources the skill needs:

**SKILL.md only** - Simple knowledge, no complex resources  
**SKILL.md + references/** - Detailed docs, schemas, API specs  
**SKILL.md + examples/** - Working code samples users can copy  
**SKILL.md + scripts/** - Utility scripts for validation or automation  

Most skills benefit from the **standard structure** (SKILL.md + references/).

### Step 3: Create Directories

Create the skill directory and subdirectories:

```bash
# Minimal skill
mkdir -p .opencode/skills/skill-name

# Standard skill (recommended)
mkdir -p .opencode/skills/skill-name/references

# Complete skill
mkdir -p .opencode/skills/skill-name/{references,examples,scripts}
```

Always start with the minimal or standard structure. Add examples/ and scripts/ only when needed.

### Step 4: Write Frontmatter

Every `SKILL.md` must begin with YAML frontmatter containing at minimum `name` and `description`.

**Required fields**:
```yaml
---
name: skill-name
description: This skill should be used when the user asks to "trigger phrase 1", "trigger phrase 2", or needs specific guidance.
---
```

**Name requirements**:
- 1-64 characters
- Lowercase alphanumeric with single hyphens
- Must match directory name
- Pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`

**Description requirements**:
- 1-1024 characters
- Include specific trigger phrases in quotes
- Be concrete about when to use the skill
- Helps agents decide whether to load the skill

**Optional fields**:
```yaml
---
name: skill-name
description: ...
license: MIT
compatibility: opencode
metadata:
  author: Your Name
  version: 1.0.0
---
```

For complete frontmatter specification, see `references/frontmatter-spec.md`.

### Step 5: Write Body Content

After frontmatter, write markdown content explaining:

**Essential sections**:
1. **Overview** - What the skill provides (2-3 sentences)
2. **Core procedures** - Step-by-step workflows
3. **Key concepts** - Domain-specific knowledge agents need
4. **Quick reference** - Tables, commands, or patterns

**Keep it focused**:
- Target 1,500-2,000 words
- Focus on essential procedures
- Move detailed content to references/
- Use clear headings and examples

**Writing style**:
- Use imperative form: "Configure the setting" not "You should configure"
- Be direct and actionable
- Include code examples where helpful
- Reference bundled resources clearly

### Step 6: Add Bundled Resources

Organize supporting materials by type:

**references/** - Documentation loaded as needed:
- Detailed patterns and techniques
- API documentation
- Schema definitions
- Troubleshooting guides
- Each file: 2,000-5,000+ words

**examples/** - Working code users can copy:
- Complete, runnable scripts
- Configuration files
- Template files
- Real-world usage examples

**scripts/** - Utility scripts:
- Validation tools
- Testing helpers
- Automation scripts
- Must be executable

**Reference resources in SKILL.md**:
```markdown
## Additional Resources

### Reference Files

For detailed information, consult:
- **`references/patterns.md`** - Common patterns and best practices
- **`references/api-reference.md`** - Complete API documentation

### Example Files

Working examples in `examples/`:
- **`example-config.json`** - Sample configuration
- **`example-script.sh`** - Usage demonstration
```

For progressive disclosure strategy, see `references/progressive-disclosure.md`.

### Step 7: Validate and Test

Before using your skill:

**Validate structure**:
```bash
# Run validation script
.opencode/skills/skill-creation/scripts/validate-skill.sh .opencode/skills/your-skill
```

**Check manually**:
- [ ] SKILL.md exists with valid YAML frontmatter
- [ ] Frontmatter has `name` and `description`
- [ ] Name matches directory name
- [ ] Name follows pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`
- [ ] Description is 1-1024 characters
- [ ] Description includes specific trigger phrases
- [ ] All referenced files exist

**Test with OpenCode**:
1. Start a new OpenCode session
2. Ask a question using trigger phrases from description
3. Verify skill appears in available skills
4. Confirm skill loads correctly
5. Check if content is helpful for the task

**Iterate**:
- Use the skill on real tasks
- Notice gaps or unclear instructions
- Update SKILL.md or references/
- Re-test and refine

## Frontmatter Essentials

### Required Fields

**name** - Skill identifier
- Must match directory name
- 1-64 characters
- Lowercase alphanumeric with single hyphens
- Pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`
- Examples: `git-release`, `api-design`, `frontend-testing`

**description** - When to use the skill
- 1-1024 characters
- Include specific trigger phrases users would say
- Be concrete about use cases
- Determines when agents load the skill

Good description:
```yaml
description: This skill should be used when the user asks to "create a database schema", "design SQL tables", "optimize queries", or needs guidance on relational database design.
```

Bad description:
```yaml
description: Helps with databases.  # Too vague, no trigger phrases
```

### Optional Fields

**license** - Legal terms (e.g., MIT, Apache-2.0)  
**compatibility** - Target platform (e.g., opencode)  
**metadata** - String-to-string map for custom fields

Unknown frontmatter fields are ignored.

## Progressive Disclosure Principle

Skills use three-level loading to manage context efficiently:

**Level 1: Metadata (always loaded)**
- Skill name and description
- ~50-100 words
- Helps agents decide which skills to load

**Level 2: SKILL.md body (loaded when triggered)**
- Core concepts and workflows
- 1,500-2,000 words ideal (<5,000 max)
- Essential procedures and quick reference

**Level 3: Bundled resources (loaded as needed)**
- references/ - Detailed documentation
- examples/ - Working code samples
- scripts/ - Utility tools (can execute without reading)

**What goes where**:

**SKILL.md** (always loaded when skill triggers):
- Core concepts and overview
- Essential procedures
- Quick reference tables
- Pointers to references/examples/scripts

**references/** (loaded when agents need details):
- Detailed patterns and techniques
- Complete API documentation
- Migration guides
- Troubleshooting and edge cases

**examples/** (loaded when agents need samples):
- Complete working scripts
- Configuration files
- Templates

**scripts/** (executed or loaded when needed):
- Validation tools
- Testing helpers
- Automation scripts

For detailed strategy, see `references/progressive-disclosure.md`.

## Examples

Study the bundled examples to see skills in action:

**Minimal skill** (`examples/minimal-skill/`)
- Single SKILL.md file
- Simple knowledge domain
- No bundled resources

**Standard skill** (`examples/standard-skill/`) - Recommended
- SKILL.md with core content
- references/ for detailed documentation
- Best for most use cases

**Complete skill** (`examples/complete-skill/`)
- All features demonstrated
- references/, examples/, scripts/
- Shows full progressive disclosure

## Validation Script

Use the included validation script to check skill structure:

```bash
# Validate a skill
.opencode/skills/skill-creation/scripts/validate-skill.sh path/to/skill

# Example
.opencode/skills/skill-creation/scripts/validate-skill.sh .opencode/skills/my-skill
```

The script checks:
- SKILL.md exists
- Valid YAML frontmatter
- Required fields present
- Name matches directory
- Name follows regex pattern
- Description length
- Referenced files exist

## Permissions

Control which skills agents can access in `opencode.json`:

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

**Permission levels**:
- `allow` - Skill loads immediately
- `deny` - Skill hidden from agents
- `ask` - Prompt user before loading

Patterns support wildcards for flexible control.

## Troubleshooting

**Skill doesn't appear**:
1. Verify SKILL.md is all caps
2. Check frontmatter has `name` and `description`
3. Ensure skill name is unique across all locations
4. Check permissions in opencode.json

**Skill loads but content is wrong**:
1. Check YAML frontmatter syntax
2. Verify markdown starts after `---` closing
3. Review referenced file paths

**Name validation fails**:
1. Must be lowercase only
2. Use single hyphens (no consecutive `--`)
3. Cannot start/end with hyphen
4. Only alphanumeric and hyphens

## Best Practices

### Core Principles

**Concise is key** - Assume the LLM already has knowledge. Only add context the LLM doesn't have. Challenge each piece:
- Does the LLM really need this explanation?
- Can I assume the LLM knows this?
- Does this paragraph justify its token cost?

**Write in third person** - Descriptions are injected into system prompts:
- ✓ Good: "Processes Excel files and generates reports"
- ✗ Avoid: "I can help you process Excel files" or "You can use this to..."

**Set appropriate degrees of freedom**:
- **High freedom** (text-based instructions): Multiple approaches valid, context-dependent decisions
- **Medium freedom** (pseudocode/templates): Preferred pattern exists, some variation acceptable
- **Low freedom** (specific scripts): Operations fragile, consistency critical

**Use consistent terminology** - Choose one term and use throughout:
- ✓ Always "API endpoint", "field", "extract"
- ✗ Mix "API endpoint"/"URL"/"API route", "field"/"box"/"element"

### DO

- Include specific trigger phrases in description (3-5 phrases users would actually say)
- Keep SKILL.md focused (1,500-2,000 words, <5,000 max)
- Use progressive disclosure for large skills
- Write in imperative form ("Configure the setting" not "You should configure")
- Write descriptions in third person
- Provide working examples in examples/
- Reference bundled resources clearly in "Additional Resources" section
- Test with real use cases
- Use forward slashes in file paths (not backslashes)
- Keep references one level deep from SKILL.md
- Add table of contents to reference files >100 lines
- Use consistent terminology throughout

### DON'T

- Use vague descriptions without trigger phrases
- Put everything in SKILL.md (>3,000 words without references/)
- Write in second person ("you should") or first person ("I can help")
- Leave resources unreferenced
- Skip validation before using
- Create duplicate information across files
- Include time-sensitive information (use "old patterns" sections instead)
- Use Windows-style paths (backslashes)
- Create deeply nested references (keep one level)
- Offer too many options without a clear default

## Additional Resources

### Reference Files

For complete specifications and strategies:
- **`references/frontmatter-spec.md`** - Complete YAML frontmatter specification
- **`references/progressive-disclosure.md`** - Deep dive on 3-level loading strategy
- **`references/common-mistakes.md`** - Anti-patterns and how to avoid them
- **`references/best-practices-guide.md`** - Comprehensive best practices from Claude documentation adapted for OpenCode

### Example Skills

Study these working examples:
- **`examples/minimal-skill/`** - Simplest possible skill
- **`examples/standard-skill/`** - Recommended structure with references
- **`examples/complete-skill/`** - All features demonstrated

### Validation Script

- **`scripts/validate-skill.sh`** - Automated skill structure checker

## Quick Reference

**Minimal skill structure**:
```
skill-name/
└── SKILL.md
```

**Standard skill structure** (recommended):
```
skill-name/
├── SKILL.md
└── references/
    └── detailed-guide.md
```

**Complete skill structure**:
```
skill-name/
├── SKILL.md
├── references/
│   ├── patterns.md
│   └── advanced.md
├── examples/
│   └── working-example.sh
└── scripts/
    └── validate.sh
```

**Frontmatter template**:
```yaml
---
name: skill-name
description: This skill should be used when the user asks to "trigger 1", "trigger 2", or needs specific guidance.
---
```

**Validation command**:
```bash
.opencode/skills/skill-creation/scripts/validate-skill.sh path/to/skill
```
