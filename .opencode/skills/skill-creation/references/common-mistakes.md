# Common Mistakes and How to Avoid Them

This document catalogs frequent errors when creating OpenCode skills and provides solutions.

## Overview

Learning from common mistakes helps you create effective skills faster. This guide covers:

- Frontmatter errors
- Content organization issues
- Progressive disclosure mistakes
- Validation problems
- Discovery failures

Each mistake includes:
- ❌ What's wrong
- ⚠️ Why it's a problem
- ✅ How to fix it
- 💡 Best practice

## Frontmatter Mistakes

### Mistake 1: Uppercase in Skill Name

❌ **Wrong**:
```yaml
---
name: Git-Release
description: ...
---
```

⚠️ **Why it's a problem**:
- Violates name pattern: `^[a-z0-9]+(-[a-z0-9]+)*$`
- Skill won't be discovered
- Validation fails

✅ **Fix**:
```yaml
---
name: git-release
description: ...
---
```

💡 **Best practice**: Always use lowercase letters, numbers, and single hyphens only.

---

### Mistake 2: Using Underscores in Name

❌ **Wrong**:
```yaml
---
name: git_release
description: ...
---
```

⚠️ **Why it's a problem**:
- Underscores not allowed in name pattern
- Skill won't validate
- Discovery fails

✅ **Fix**:
```yaml
---
name: git-release
description: ...
---
```

💡 **Best practice**: Use hyphens, not underscores or spaces.

---

### Mistake 3: Name Doesn't Match Directory

❌ **Wrong**:
```
Directory: .opencode/skills/api-helper/

SKILL.md:
---
name: api-design
description: ...
---
```

⚠️ **Why it's a problem**:
- OpenCode requires exact directory-name match
- Skill won't load correctly
- Confusing for maintenance

✅ **Fix**:
```
Directory: .opencode/skills/api-helper/

SKILL.md:
---
name: api-helper
description: ...
---
```

💡 **Best practice**: Set skill name to match directory exactly, or rename directory to match skill name.

---

### Mistake 4: Vague Description Without Triggers

❌ **Wrong**:
```yaml
---
name: api-design
description: Helps with APIs.
---
```

⚠️ **Why it's a problem**:
- Too vague for agents to decide when to load
- No specific trigger phrases
- Agents won't know what "helps with APIs" means

✅ **Fix**:
```yaml
---
name: api-design
description: This skill should be used when the user asks to "design a REST API", "create API endpoints", "structure API responses", or needs guidance on RESTful design principles and HTTP methods.
---
```

💡 **Best practice**: Include 3-5 specific phrases in quotes that users would actually say.

---

### Mistake 5: Missing Required Fields

❌ **Wrong**:
```yaml
---
name: my-skill
license: MIT
---
```

⚠️ **Why it's a problem**:
- Missing required `description` field
- Skill won't be discoverable
- Validation fails

✅ **Fix**:
```yaml
---
name: my-skill
description: This skill should be used when the user asks to "do X", "do Y", or needs Z guidance.
license: MIT
---
```

💡 **Best practice**: Always include both `name` and `description`. Other fields are optional.

---

### Mistake 6: Description Too Long

❌ **Wrong**:
```yaml
---
name: my-skill
description: This skill should be used when the user asks to do many different things including create, update, delete, modify, configure, optimize, troubleshoot, debug, test, deploy, monitor, analyze, review, refactor, document, integrate, migrate, validate, verify, authenticate, authorize, encrypt, decrypt, compress, decompress, parse, format, transform, convert, export, import, backup, restore, sync, clone, merge, split, join, filter, sort, search, replace, rename, move, copy, and many other operations that might be relevant to this particular domain which is very broad and encompasses many different scenarios and use cases. [continues for 1500 characters...]
---
```

⚠️ **Why it's a problem**:
- Exceeds 1,024 character limit
- Validation fails
- Too much metadata loaded into context

✅ **Fix**:
```yaml
---
name: my-skill
description: This skill should be used when the user asks to "create X", "configure Y", "optimize Z", or needs guidance on core domain operations.
---
```

💡 **Best practice**: Keep descriptions under 300 characters. Be specific but concise.

---

### Mistake 7: Invalid YAML Syntax

❌ **Wrong**:
```yaml
---
name my-skill
description: Missing colons
---
```

⚠️ **Why it's a problem**:
- Invalid YAML syntax (missing colons)
- Parser fails
- Skill won't load

✅ **Fix**:
```yaml
---
name: my-skill
description: Proper YAML with colons
---
```

💡 **Best practice**: Validate YAML syntax. Use `yamllint` or online validators.

---

### Mistake 8: Using First or Second Person in Description

❌ **Wrong**:
```yaml
---
name: my-skill
description: I can help you process files and analyze data when you need assistance.
---
```

⚠️ **Why it's a problem**:
- Descriptions are injected into system prompts
- Inconsistent point-of-view causes discovery problems
- Confusing for agents

✅ **Fix**:
```yaml
---
name: my-skill
description: Processes files and analyzes data. Use when the user asks to "process files", "analyze data", or needs data processing guidance.
---
```

💡 **Best practice**: Always write descriptions in third person, not first ("I") or second ("you") person.

---

### Mistake 9: Missing Closing Delimiter

❌ **Wrong**:
```yaml
---
name: my-skill
description: Missing closing delimiter

# Content starts here...
```

⚠️ **Why it's a problem**:
- Frontmatter not properly closed
- Parser can't determine where frontmatter ends
- Content might be parsed as frontmatter

✅ **Fix**:
```yaml
---
name: my-skill
description: Proper delimiters
---

# Content starts here...
```

💡 **Best practice**: Always close frontmatter with `---` on its own line.

### Mistake 9: Missing Closing Delimiter

❌ **Wrong**:
```yaml
---
name: my-skill
description: Missing closing delimiter

# Content starts here...
```

⚠️ **Why it's a problem**:
- Frontmatter not properly closed
- Parser can't determine where frontmatter ends
- Content might be parsed as frontmatter

✅ **Fix**:
```yaml
---
name: my-skill
description: Proper delimiters
---

# Content starts here...
```

💡 **Best practice**: Always close frontmatter with `---` on its own line.

---

### Mistake 10: Using Windows-Style Paths

❌ **Wrong**:
```markdown
See `references\patterns.md` for details.
Run `scripts\validate.sh` to check.
```

⚠️ **Why it's a problem**:
- Windows-style backslashes fail on Unix systems
- Cross-platform compatibility issues
- Inconsistent with skill conventions

✅ **Fix**:
```markdown
See `references/patterns.md` for details.
Run `scripts/validate.sh` to check.
```

💡 **Best practice**: Always use forward slashes in file paths, even on Windows.

## Content Organization Mistakes

### Mistake 11: Everything in SKILL.md

❌ **Wrong**:
```
skill-name/
└── SKILL.md  (8,000 words - everything in one file)
```

⚠️ **Why it's a problem**:
- Bloats context when skill loads
- Loads detailed content unnecessarily
- Poor progressive disclosure
- Degrades performance

✅ **Fix**:
```
skill-name/
├── SKILL.md  (1,800 words - core essentials)
└── references/
    ├── patterns.md (2,500 words)
    ├── advanced.md (2,200 words)
    └── troubleshooting.md (1,500 words)
```

💡 **Best practice**: Keep SKILL.md under 2,000 words. Move details to references/.

---

### Mistake 11: Everything in SKILL.md

❌ **Wrong**:
```
skill-name/
└── SKILL.md  (8,000 words - everything in one file)
```

⚠️ **Why it's a problem**:
- Bloats context when skill loads
- Loads detailed content unnecessarily
- Poor progressive disclosure
- Degrades performance

✅ **Fix**:
```
skill-name/
├── SKILL.md  (1,800 words - core essentials)
└── references/
    ├── patterns.md (2,500 words)
    ├── advanced.md (2,200 words)
    └── troubleshooting.md (1,500 words)
```

💡 **Best practice**: Keep SKILL.md under 2,000 words. Move details to references/.

---

### Mistake 12: Being Too Verbose

❌ **Wrong**:
```markdown
## Extract PDF text

PDF (Portable Document Format) files are a common file format that contains
text, images, and other content. To extract text from a PDF, you'll need to
use a library. There are many libraries available for PDF processing, but we
recommend pdfplumber because it's easy to use and handles most cases well.
First, you'll need to install it using pip. Then you can use the code below...
[150+ tokens of explanation]
```

⚠️ **Why it's a problem**:
- Wastes tokens on information Claude already knows
- High context cost for simple operations
- Assumes Claude doesn't understand basic concepts

✅ **Fix**:
````markdown
## Extract PDF text

Use pdfplumber for text extraction:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

💡 **Best practice**: Assume the LLM has prior knowledge. Only add context the LLM doesn't have.

---

### Mistake 13: No References to Bundled Resources

❌ **Wrong**:

SKILL.md:
```markdown
# My Skill

[Core content - 1,800 words]

[No mention of references/ or examples/]
```

Directory structure:
```
skill-name/
├── SKILL.md
├── references/
│   └── advanced.md  ← Exists but not referenced
└── examples/
    └── example.sh  ← Exists but not referenced
```

⚠️ **Why it's a problem**:
- Agents don't know resources exist
- Resources never get loaded
- Wasted effort creating unused files

✅ **Fix**:

SKILL.md:
```markdown
# My Skill

[Core content - 1,800 words]

## Additional Resources

### Reference Files

For detailed information:
- **`references/advanced.md`** - Advanced techniques and patterns

### Example Files

Working examples in `examples/`:
- **`example.sh`** - Complete workflow demonstration
```

💡 **Best practice**: Always reference bundled resources in an "Additional Resources" section.

---

### Mistake 11: Duplicating Content Across Files

❌ **Wrong**:

SKILL.md:
```markdown
## Database Normalization

[800 words explaining normalization]
```

references/normalization.md:
```markdown
## Database Normalization

[Same 800 words explaining normalization]
```

⚠️ **Why it's a problem**:
- Wastes context loading duplicate content
- Maintenance burden (update in two places)
- Confusing for agents

✅ **Fix**:

SKILL.md:
```markdown
## Database Normalization

Quick overview:
- 1NF: Atomic values
- 2NF: No partial dependencies
- 3NF: No transitive dependencies

For detailed explanation, see `references/normalization.md`.
```

references/normalization.md:
```markdown
## Database Normalization

[Comprehensive 800-word explanation]
```

💡 **Best practice**: Each piece of information should exist in exactly one place. SKILL.md has summaries, references/ have details.

---

### Mistake 12: Inline Examples Instead of Files

❌ **Wrong**:

SKILL.md:
```markdown
## Example Configuration

\`\`\`json
{
  "setting1": "value1",
  "setting2": {
    "nested": {
      "deep": {
        "config": "value2"
      }
    }
  },
  ...
  [100 lines of JSON]
}
\`\`\`

## Example Script

\`\`\`bash
#!/bin/bash
...
[80 lines of script]
\`\`\`
```

⚠️ **Why it's a problem**:
- Bloats SKILL.md with code
- Reduces readability
- Loads code into context unnecessarily

✅ **Fix**:

SKILL.md:
```markdown
## Example Configuration

See `examples/config.json` for complete configuration template.

Key settings:
- `setting1`: Controls feature A
- `setting2.nested.deep.config`: Configures option B

## Example Script

See `examples/workflow.sh` for complete automation script.
```

examples/config.json:
```json
{
  "setting1": "value1",
  ...
}
```

examples/workflow.sh:
```bash
#!/bin/bash
...
```

💡 **Best practice**: Keep code in examples/ files. Reference them from SKILL.md with brief descriptions.

## Progressive Disclosure Mistakes

### Mistake 13: Not Using Progressive Disclosure

❌ **Wrong**:
```
skill-name/
└── SKILL.md  (5,000 words with everything)
```

⚠️ **Why it's a problem**:
- High context cost every time skill loads
- Includes rarely-needed information
- Slows agent performance

✅ **Fix**:
```
skill-name/
├── SKILL.md  (1,500 words - essentials)
├── references/
│   ├── detailed-patterns.md
│   └── advanced-guide.md
└── examples/
    └── working-example.sh
```

💡 **Best practice**: Use three-level loading: metadata → SKILL.md → references/examples/scripts.

---

### Mistake 14: Wrong Content in Wrong Level

❌ **Wrong**:

Metadata (always loaded):
```yaml
description: This skill provides comprehensive guidance on database design including normalization, denormalization strategies, indexing approaches, query optimization techniques, transaction management, concurrency control, ACID properties, CAP theorem implications, and many other advanced database concepts. [500 characters]
```

SKILL.md (loaded when triggered):
```markdown
Quick start:
1. Do X
2. Do Y
```

⚠️ **Why it's a problem**:
- Metadata too detailed (high constant context cost)
- SKILL.md too brief (not useful)
- Backward allocation

✅ **Fix**:

Metadata:
```yaml
description: This skill should be used when the user asks to "design database schema", "normalize tables", "optimize queries", or needs database design guidance.
```

SKILL.md:
```markdown
# Database Design

## Overview
[200 words]

## Core Workflow
[800 words with essential procedures]

## Quick Reference
[300 words with tables and commands]

## Additional Resources
- `references/normalization.md` - Detailed normalization guide
- `references/optimization.md` - Query optimization techniques
```

💡 **Best practice**: Metadata = trigger phrases. SKILL.md = core workflows. References = detailed docs.

## Writing Style Mistakes

### Mistake 15: Using Second Person

❌ **Wrong**:
```markdown
You should start by reading the configuration file.
You need to validate the input before processing.
You can use the grep tool to search for patterns.
```

⚠️ **Why it's a problem**:
- Not imperative form
- Less direct and actionable
- Inconsistent with skill conventions

✅ **Fix**:
```markdown
Start by reading the configuration file.
Validate the input before processing.
Use the grep tool to search for patterns.
```

💡 **Best practice**: Use imperative/infinitive form (verb-first). No "you" or "you should".

---

### Mistake 16: Unclear or Missing Instructions

❌ **Wrong**:
```markdown
## Configuration

Configure the settings appropriately.
```

⚠️ **Why it's a problem**:
- Too vague
- No specific steps
- Agents don't know what "appropriately" means

✅ **Fix**:
```markdown
## Configuration

Configure settings in `config.json`:

1. Set `api_key` to your API key
2. Set `timeout` to desired timeout in seconds (default: 30)
3. Set `retry_attempts` to number of retries (default: 3)

Example:
\`\`\`json
{
  "api_key": "your-key-here",
  "timeout": 60,
  "retry_attempts": 5
}
\`\`\`
```

💡 **Best practice**: Provide specific, actionable steps with examples.

## Validation Mistakes

### Mistake 17: Skipping Validation

❌ **Wrong**:
```bash
# Create skill
mkdir my-skill
echo "---" > my-skill/SKILL.md
echo "name: my-skill" >> my-skill/SKILL.md
echo "---" >> my-skill/SKILL.md

# Immediately start using without validation
```

⚠️ **Why it's a problem**:
- Missing required fields
- Possible syntax errors
- Skill might not load
- Waste time debugging later

✅ **Fix**:
```bash
# Create skill
mkdir my-skill
# ... create SKILL.md with proper frontmatter ...

# Validate before using
.opencode/skills/skill-creation/scripts/validate-skill.sh my-skill

# Check output for errors
# Fix any issues
# Re-validate until clean
```

💡 **Best practice**: Always validate skills before using. Fix errors early.

---

### Mistake 18: Ignoring Validation Errors

❌ **Wrong**:
```bash
$ validate-skill.sh my-skill
ERROR: Name 'My-Skill' doesn't match pattern
ERROR: Description missing
WARNING: Referenced file 'references/guide.md' not found

# User: "I'll fix it later" and proceeds to use the skill
```

⚠️ **Why it's a problem**:
- Skill won't work correctly
- Harder to debug later
- Wastes time troubleshooting

✅ **Fix**:
```bash
$ validate-skill.sh my-skill
ERROR: Name 'My-Skill' doesn't match pattern
ERROR: Description missing
WARNING: Referenced file 'references/guide.md' not found

# Fix immediately:
# 1. Change name to 'my-skill'
# 2. Add description
# 3. Create references/guide.md or remove reference

$ validate-skill.sh my-skill
✓ All validations passed
```

💡 **Best practice**: Fix all validation errors before using the skill.

## Discovery Mistakes

### Mistake 19: Skill in Wrong Location

❌ **Wrong**:
```
# Creating skill in arbitrary location
/tmp/my-skill/SKILL.md

# Or wrong directory name
.opencode/my-skill/SKILL.md  # Missing 'skills/' directory
```

⚠️ **Why it's a problem**:
- OpenCode won't discover the skill
- Not in searchable locations
- Skill never appears to agents

✅ **Fix**:
```
# Project-local
.opencode/skills/my-skill/SKILL.md

# Or global
~/.config/opencode/skills/my-skill/SKILL.md
```

💡 **Best practice**: Use standard locations: `.opencode/skills/` or `~/.config/opencode/skills/`.

---

### Mistake 20: Filename Not All Caps

❌ **Wrong**:
```
.opencode/skills/my-skill/skill.md  # Lowercase
.opencode/skills/my-skill/Skill.md  # Mixed case
```

⚠️ **Why it's a problem**:
- OpenCode looks for `SKILL.md` (all caps)
- Skill won't be discovered
- Case-sensitive file systems fail

✅ **Fix**:
```
.opencode/skills/my-skill/SKILL.md  # All caps
```

💡 **Best practice**: Always use `SKILL.md` in all caps.

---

### Mistake 21: Duplicate Skill Names

❌ **Wrong**:
```
# Project skill
.opencode/skills/git-helper/SKILL.md
  name: git-helper

# Global skill
~/.config/opencode/skills/git-helper/SKILL.md
  name: git-helper
```

⚠️ **Why it's a problem**:
- Name collision
- Unclear which skill loads
- Confusing behavior

✅ **Fix**:
```
# Option 1: Use different names
.opencode/skills/project-git-helper/SKILL.md
  name: project-git-helper

~/.config/opencode/skills/git-helper/SKILL.md
  name: git-helper

# Option 2: Use only one location
# Either project-local OR global, not both
```

💡 **Best practice**: Ensure unique skill names across all locations.

## Permission Mistakes

### Mistake 22: Forgetting Permission Configuration

❌ **Wrong**:
```json
{
  "permission": {
    "skill": {
      "internal-*": "deny"
    }
  }
}
```

Creating skill:
```
.opencode/skills/internal-docs/SKILL.md
  name: internal-docs
```

⚠️ **Why it's a problem**:
- Skill matches `internal-*` pattern
- Permission denies access
- Skill hidden from agents
- User confused why skill doesn't appear

✅ **Fix**:
```json
{
  "permission": {
    "skill": {
      "internal-*": "deny",
      "internal-docs": "allow"  # Specific override
    }
  }
}
```

Or rename skill:
```
.opencode/skills/project-docs/SKILL.md
  name: project-docs
```

💡 **Best practice**: Check permission configuration when skills don't appear. Use specific overrides when needed.

## Testing Mistakes

### Mistake 23: Not Testing Trigger Phrases

❌ **Wrong**:
```yaml
---
name: git-release
description: This skill should be used when the user asks to "perform release operations".
---
```

Testing:
```
User: "Create a release"
Agent: [Doesn't load skill because "create a release" ≠ "perform release operations"]
```

⚠️ **Why it's a problem**:
- Trigger phrases don't match user language
- Skill doesn't load when expected
- Poor user experience

✅ **Fix**:
```yaml
---
name: git-release
description: This skill should be used when the user asks to "create a release", "make a release", "tag a version", or needs release guidance.
---
```

Testing:
```
User: "Create a release"
Agent: [Loads git-release skill] ✓

User: "Tag a version"
Agent: [Loads git-release skill] ✓
```

💡 **Best practice**: Test with actual phrases users would say. Include variations.

---

### Mistake 24: Not Iterating Based on Usage

❌ **Wrong**:
```
# Create skill
# Test once
# Never update again

# Months later: skill doesn't work well for evolved use cases
```

⚠️ **Why it's a problem**:
- Use cases evolve
- New patterns emerge
- Skill becomes outdated

✅ **Fix**:
```
# Create skill
# Use skill on real tasks
# Notice: "Agent struggles with X"
# Update: Add section about X to SKILL.md
# Notice: "Need more examples of Y"
# Update: Create examples/y-example.sh
# Continuous improvement
```

💡 **Best practice**: Iterate on skills based on real usage. Update regularly.

## Summary Checklist

Before finalizing a skill, check for these common mistakes:

**Frontmatter**:
- [ ] Name is lowercase with hyphens only
- [ ] Name matches directory
- [ ] Description includes specific trigger phrases in quotes
- [ ] Description is 1-1,024 characters
- [ ] Valid YAML syntax with proper delimiters
- [ ] Both required fields present (name, description)

**Content Organization**:
- [ ] SKILL.md is focused (1,500-2,000 words)
- [ ] Detailed content in references/
- [ ] Working code in examples/
- [ ] Utility scripts in scripts/
- [ ] All resources referenced in SKILL.md
- [ ] No content duplication

**Progressive Disclosure**:
- [ ] Metadata is concise (~50-100 words)
- [ ] SKILL.md has core workflows
- [ ] References have detailed docs
- [ ] Context efficiency <40%

**Writing Style**:
- [ ] Uses imperative form (not second person)
- [ ] Specific and actionable
- [ ] Clear instructions with examples

**Validation**:
- [ ] Ran validation script
- [ ] Fixed all errors
- [ ] Verified all referenced files exist

**Discovery**:
- [ ] Skill in correct location
- [ ] Filename is SKILL.md (all caps)
- [ ] Unique skill name
- [ ] Permission configuration allows access

**Testing**:
- [ ] Tested with trigger phrases
- [ ] Verified skill loads
- [ ] Confirmed content is helpful
- [ ] Iterated based on usage

Avoid these mistakes to create effective, discoverable, and maintainable OpenCode skills.
