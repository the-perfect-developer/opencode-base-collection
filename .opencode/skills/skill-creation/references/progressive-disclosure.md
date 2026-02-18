# Progressive Disclosure Strategy

This document provides a deep dive into the progressive disclosure design principle for OpenCode skills, explaining how to efficiently manage context through three-level loading.

## Overview

Progressive disclosure is the core architectural principle of OpenCode skills. It ensures that agents load only the information they need, when they need it, rather than consuming context with unused documentation.

**The problem**: Without progressive disclosure, every skill would need to be fully loaded into context at all times, quickly exhausting the context window and degrading performance.

**The solution**: Three-level loading that progressively reveals information:
1. **Level 1**: Metadata (always loaded) - ~50-100 words
2. **Level 2**: SKILL.md body (loaded when triggered) - ~1,500-2,000 words
3. **Level 3**: Bundled resources (loaded as needed) - Unlimited*

*Scripts can be executed without loading into context.

## Three-Level Loading System

### Level 1: Metadata (Always Loaded)

**What**: Skill name and description from frontmatter  
**When**: Always in agent context  
**Size**: ~50-100 words  
**Purpose**: Help agents decide which skills to load

**Content**:
```yaml
---
name: git-release
description: This skill should be used when the user asks to "create a release", "draft changelog", "tag version", or needs guidance on release workflows and versioning.
---
```

**Key principles**:
- Extremely concise
- Includes specific trigger phrases
- Appears in `<available_skills>` list shown to agents
- Low context cost (all skills can show metadata)

**Example of what agents see**:
```xml
<available_skills>
  <skill>
    <name>git-release</name>
    <description>This skill should be used when the user asks to "create a release"...</description>
  </skill>
  <skill>
    <name>api-design</name>
    <description>This skill should be used when the user asks to "design REST API"...</description>
  </skill>
</available_skills>
```

Agents can scan all available skills without consuming significant context.

### Level 2: SKILL.md Body (Loaded When Triggered)

**What**: Main skill content after frontmatter  
**When**: When agent decides skill is relevant  
**Size**: 1,500-2,000 words ideal (<5,000 max)  
**Purpose**: Provide core procedures and essential knowledge

**Content includes**:
- Overview and key concepts
- Essential procedures and workflows
- Quick reference tables
- Common use cases
- Pointers to references/, examples/, scripts/

**What to include**:
```markdown
# Git Release Workflow

## Overview
[2-3 sentence summary]

## Core Workflow
[Step-by-step essential procedure]

## Version Numbering
[Quick reference table of semantic versioning]

## Common Patterns
[Most frequent use cases]

## Additional Resources
- **`references/advanced-workflows.md`** - Complex release scenarios
- **`examples/release-script.sh`** - Automated release example
- **`scripts/validate-changelog.sh`** - Changelog validation tool
```

**What NOT to include**:
- Detailed troubleshooting guides → Move to references/
- Extensive examples → Move to examples/
- Edge cases and advanced techniques → Move to references/
- Complete API documentation → Move to references/

**Size guidelines**:
- **Ideal**: 1,500-2,000 words
  - Fits comfortably in context with other information
  - Comprehensive enough to be useful
  - Focused on essentials
  
- **Acceptable**: 2,000-3,000 words
  - Still manageable
  - Consider moving some content to references/
  
- **Too large**: >3,000 words
  - High context cost
  - Should definitely use references/ for detailed content
  - Slows agent performance

**Measuring word count**:
```bash
# Count words in SKILL.md body (excluding frontmatter)
sed -n '/^---$/,/^---$/!p' SKILL.md | wc -w
```

### Level 3: Bundled Resources (Loaded As Needed)

**What**: Supporting files in references/, examples/, scripts/  
**When**: When agents need specific details  
**Size**: Unlimited (each file can be 2,000-5,000+ words)  
**Purpose**: Provide detailed information without bloating SKILL.md

**Three types**:

#### references/ - Detailed Documentation

**Purpose**: In-depth information loaded when agents need specifics

**When to use**:
- Detailed patterns and techniques
- Complete API documentation
- Schema definitions
- Migration guides
- Troubleshooting guides
- Advanced use cases

**Size**: 2,000-5,000+ words per file

**Example structure**:
```
references/
├── patterns.md          - Common patterns (2,500 words)
├── api-reference.md     - Complete API docs (4,200 words)
├── advanced.md          - Advanced techniques (3,800 words)
└── troubleshooting.md   - Edge cases and fixes (2,100 words)
```

**Loading behavior**:
- Agents read these files when they need specific information
- Not automatically loaded with SKILL.md
- Referenced in SKILL.md so agents know they exist

**Example reference in SKILL.md**:
```markdown
## Additional Resources

### Reference Files

For detailed information:
- **`references/patterns.md`** - Common design patterns and anti-patterns
- **`references/api-reference.md`** - Complete API specification with all endpoints
- **`references/advanced.md`** - Advanced techniques for complex scenarios
- **`references/troubleshooting.md`** - Edge cases and problem resolution
```

#### examples/ - Working Code

**Purpose**: Runnable code samples agents can copy and adapt

**When to use**:
- Complete working scripts
- Configuration files
- Template files
- Real-world usage examples

**Size**: Varies (complete working examples)

**Example structure**:
```
examples/
├── basic-release.sh      - Simple release script
├── advanced-release.sh   - Full automation
├── config.json          - Example configuration
└── template.md          - Changelog template
```

**Loading behavior**:
- Agents read when they need to see working code
- Can be copied directly by users
- Referenced in SKILL.md

**Example reference in SKILL.md**:
```markdown
### Example Files

Working examples in `examples/`:
- **`basic-release.sh`** - Simple release automation
- **`advanced-release.sh`** - Full CI/CD integration
- **`config.json`** - Release configuration template
- **`template.md`** - Changelog structure
```

#### scripts/ - Utility Tools

**Purpose**: Executable scripts for validation, testing, or automation

**When to use**:
- Validation tools
- Testing helpers
- Parsing utilities
- Automation scripts
- Repetitive operations

**Size**: Varies (complete working scripts)

**Special property**: Scripts can be **executed without reading into context**, making them context-free.

**Example structure**:
```
scripts/
├── validate-version.sh    - Check version format
├── generate-changelog.sh  - Auto-generate changelog
├── test-release.sh       - Validate release readiness
└── bump-version.sh       - Increment version numbers
```

**Loading behavior**:
- Can be executed directly without reading
- Can be read if agents need to understand or modify them
- Most efficient for repetitive operations

**Example reference in SKILL.md**:
```markdown
### Utility Scripts

Helper scripts in `scripts/`:
- **`validate-version.sh`** - Verify version number format
- **`generate-changelog.sh`** - Create changelog from commits
- **`test-release.sh`** - Run pre-release validation
- **`bump-version.sh`** - Increment version numbers

Usage:
\`\`\`bash
# Validate version
./scripts/validate-version.sh 1.2.3

# Generate changelog
./scripts/generate-changelog.sh v1.0.0 v1.1.0
\`\`\`
```

## Content Allocation Strategy

### Decision Framework

Use this framework to decide where content belongs:

**SKILL.md** (always loaded when skill triggers):
- [ ] Is this information needed in >80% of use cases?
- [ ] Is it essential background for understanding the skill?
- [ ] Is it a core procedure or workflow?
- [ ] Is it a quick reference (table, common commands)?

If yes to any: Keep in SKILL.md

**references/** (loaded when details needed):
- [ ] Is this detailed documentation?
- [ ] Is it needed for edge cases or advanced scenarios?
- [ ] Is it comprehensive API documentation?
- [ ] Is it troubleshooting or migration guidance?

If yes to any: Move to references/

**examples/** (loaded when samples needed):
- [ ] Is this complete working code?
- [ ] Would users copy and adapt this?
- [ ] Is it a template or configuration file?

If yes to any: Create as example/

**scripts/** (executed or loaded as needed):
- [ ] Is this a repetitive operation?
- [ ] Would automation improve consistency?
- [ ] Is it a validation or testing tool?
- [ ] Does it require deterministic behavior?

If yes to any: Create as script/

### Example Allocations

**Scenario**: Creating a `database-design` skill

**SKILL.md** (~1,800 words):
- Overview of database design principles
- Core workflow: requirements → schema → normalization → indexes
- Quick reference table of normal forms
- Common patterns (one-to-many, many-to-many)
- Pointers to references and examples

**references/normalization.md** (~3,200 words):
- Detailed explanation of each normal form
- When to denormalize
- Performance implications
- Real-world examples of normalization decisions

**references/indexing-strategies.md** (~2,800 words):
- Index types (B-tree, hash, full-text)
- When to create indexes
- Index maintenance
- Performance tuning

**examples/schema.sql**:
- Complete working database schema
- Demonstrates normalization
- Shows indexing strategy
- Includes relationships

**scripts/validate-schema.sh**:
- Checks schema syntax
- Validates foreign key relationships
- Ensures indexes exist for foreign keys
- Reports potential issues

## Progressive Loading in Practice

### Example: git-release Skill

**Level 1: Metadata** (agents always see this):
```yaml
name: git-release
description: This skill should be used when the user asks to "create a release", "draft changelog", "tag version", or needs release workflow guidance.
```

**Level 2: SKILL.md Body** (loaded when user says "create a release"):
```markdown
# Git Release Workflow

## Overview
Guide for creating consistent releases with proper versioning and changelogs.

## Core Workflow

1. **Update version** - Increment version number
2. **Generate changelog** - Document changes since last release
3. **Create tag** - Tag commit with version
4. **Push release** - Push tag and create GitHub release

[Quick reference tables, common patterns]

## Additional Resources
- `references/semantic-versioning.md` - Version numbering details
- `references/changelog-format.md` - Changelog standards
- `examples/release-script.sh` - Automated workflow
- `scripts/validate-changelog.sh` - Validation tool
```

**Level 3: Bundled Resources** (loaded if needed):

When agent needs version numbering details → Reads `references/semantic-versioning.md`  
When agent needs to see working example → Reads `examples/release-script.sh`  
When validating changelog → Executes `scripts/validate-changelog.sh`

### Context Efficiency

**Without progressive disclosure** (everything in SKILL.md):
- Single file: 8,000 words
- Loaded every time skill triggers
- High context cost
- Includes content rarely needed

**With progressive disclosure**:
- SKILL.md: 1,800 words (always loaded)
- references/: 4,500 words (loaded if needed)
- examples/: 1,200 words (loaded if needed)
- scripts/: 500 words (can execute without loading)

**Result**: 77% reduction in typical context usage (1,800 vs 8,000 words)

## Best Practices

### DO

**Keep SKILL.md focused**:
```markdown
# Good - Essential overview
## Core Workflow
1. Step one
2. Step two
3. Step three

## Quick Reference
[Table of common commands]

## Additional Resources
- `references/advanced.md` - Detailed patterns
```

**Use references for details**:
```markdown
# Good - In references/advanced.md
## Advanced Patterns

### Pattern 1: Complex Scenario
[3,000 words of detailed explanation]

### Pattern 2: Edge Cases
[2,500 words of troubleshooting]
```

**Reference resources clearly**:
```markdown
# Good - Clear pointers
## Additional Resources

### Reference Files
- **`references/patterns.md`** - Common design patterns
  Use when: Designing complex workflows
  
- **`references/api-ref.md`** - Complete API documentation
  Use when: Integrating with external services
```

### DON'T

**Don't bloat SKILL.md**:
```markdown
# Bad - Everything in SKILL.md (8,000 words)
## Core Workflow
[500 words]

## Advanced Patterns
[3,000 words] ← Move to references/

## Complete API Reference
[2,500 words] ← Move to references/

## Troubleshooting
[2,000 words] ← Move to references/
```

**Don't duplicate content**:
```markdown
# Bad - Same content in multiple places

# In SKILL.md:
## Version Numbering
[800 words of semantic versioning explanation]

# Also in references/versioning.md:
## Version Numbering
[800 words of the same content] ← Duplication
```

**Don't leave resources unreferenced**:
```markdown
# Bad - Resources exist but aren't mentioned in SKILL.md

# SKILL.md:
[Core content]
[No mention of references/]

# References exist but the LLM doesn't know:
references/
├── patterns.md      ← LLM doesn't know this exists
└── advanced.md      ← LLM doesn't know this exists
```

## Optimization Strategies

### Strategy 1: Extract Common Patterns

**Before** (in SKILL.md):
```markdown
## Use Case 1
[Explanation with pattern X - 400 words]

## Use Case 2
[Explanation with pattern X - 400 words]

## Use Case 3
[Explanation with pattern X - 400 words]
```

**After**:

SKILL.md:
```markdown
## Common Patterns
Pattern X applies to multiple scenarios. See `references/patterns.md` for detailed examples.

Quick reference:
- Use case 1: Apply pattern X with config A
- Use case 2: Apply pattern X with config B
- Use case 3: Apply pattern X with config C
```

references/patterns.md:
```markdown
## Pattern X

### Detailed Explanation
[Comprehensive explanation - 1,200 words]

### Use Case 1
[Specific application - 400 words]

### Use Case 2
[Specific application - 400 words]

### Use Case 3
[Specific application - 400 words]
```

### Strategy 2: Extract Examples to Files

**Before** (in SKILL.md):
```markdown
## Example Configuration

\`\`\`json
{
  "setting1": "value1",
  "setting2": {
    "nested1": "value2",
    "nested2": "value3"
  },
  ...
  [50 lines of configuration]
}
\`\`\`

## Another Example

\`\`\`bash
#!/bin/bash
[40 lines of script]
\`\`\`
```

**After**:

SKILL.md:
```markdown
## Example Configuration

See `examples/config.json` for complete configuration template.

Key settings:
- `setting1` - Controls feature A
- `setting2.nested1` - Configures option B

See `examples/workflow.sh` for automation script.
```

examples/config.json:
```json
{
  "setting1": "value1",
  ...
  [Complete configuration]
}
```

examples/workflow.sh:
```bash
#!/bin/bash
[Complete script]
```

### Strategy 3: Create Utility Scripts

**Before** (agents rewrite code each time):
- User asks to validate configuration
- LLM writes validation code (150 lines)
- Code loads into context
- Process repeats each time

**After** (reusable script):

scripts/validate-config.sh:
```bash
#!/bin/bash
[150 lines of validation logic]
```

SKILL.md:
```markdown
## Configuration Validation

Validate configuration files:
\`\`\`bash
./scripts/validate-config.sh path/to/config.json
\`\`\`
```

**Benefit**: Script executes without loading 150 lines into context.

## Measuring Success

### Metrics

**SKILL.md size**:
- Ideal: 1,500-2,000 words
- Good: 2,000-3,000 words
- Needs improvement: >3,000 words

**Resource organization**:
- Count: How many reference files?
- Coverage: Does SKILL.md reference all files?
- Usage: Are resources actually loaded when needed?

**Context efficiency**:
- Calculate: SKILL.md size ÷ Total content size
- Target: 20-40% (most content in references/)
- Poor: >60% (too much in SKILL.md)

### Example Calculation

Total content:
- SKILL.md body: 1,800 words
- references/: 4,500 words (3 files)
- examples/: 1,200 words (2 files)
- scripts/: 500 words (1 file)
- **Total**: 8,000 words

Context efficiency:
- Initial load: 1,800 words (SKILL.md only)
- Efficiency: 1,800 ÷ 8,000 = 22.5%
- **Result**: Excellent (most content deferred)

## Summary

**Progressive disclosure checklist**:

- [ ] Metadata (name + description) is concise (~50-100 words)
- [ ] SKILL.md body is focused (1,500-2,000 words)
- [ ] Detailed content moved to references/ (2,000-5,000+ words each)
- [ ] Working code in examples/
- [ ] Utility operations in scripts/
- [ ] SKILL.md references all bundled resources
- [ ] No content duplication across files
- [ ] Context efficiency <40%

**Remember**:
- Level 1 (metadata): Always loaded - Be concise
- Level 2 (SKILL.md): Loaded when triggered - Be focused
- Level 3 (resources): Loaded as needed - Be comprehensive

Progressive disclosure ensures skills are powerful without consuming excessive context, enabling agents to work efficiently with many specialized skills available.
