# Advanced Techniques

This reference demonstrates how to structure advanced content for a skill.

## Purpose

Advanced content should:
- Build on fundamentals from SKILL.md
- Cover complex scenarios
- Provide optimization strategies
- Handle edge cases

Keep advanced content in references/ to avoid bloating SKILL.md.

## Advanced Skill Development Techniques

### Technique 1: Multi-Tier Reference Organization

**Concept**: Organize references into basic, intermediate, and advanced tiers

**When to use**:
- Skill covers wide range of expertise levels
- Content spans beginner to expert topics
- Want clear progression path

**Implementation**:

```
references/
├── fundamentals.md      - Detailed basics (for those who need more than SKILL.md)
├── intermediate.md      - Common advanced patterns
├── advanced.md          - Expert techniques
└── edge-cases.md        - Unusual scenarios
```

**SKILL.md pointers**:
```markdown
## Additional Resources

### For Deeper Understanding
- **`references/fundamentals.md`** - Detailed foundational concepts

### For Practical Application
- **`references/intermediate.md`** - Common advanced patterns

### For Expert Users
- **`references/advanced.md`** - Expert techniques and optimizations
- **`references/edge-cases.md`** - Unusual scenarios and solutions
```

**Benefits**:
- Clear skill level expectations
- Users can self-select appropriate depth
- Natural learning progression

---

### Technique 2: Conditional Resource Loading

**Concept**: Reference resources conditionally based on user's context

**When to use**:
- Skill supports multiple platforms/environments
- Different resources for different scenarios
- Want to minimize unnecessary loading

**Implementation**:

SKILL.md:
```markdown
## Platform-Specific Resources

### For Linux Users
See `references/linux-specific.md` for Linux-specific configurations

### For macOS Users
See `references/macos-specific.md` for macOS-specific configurations

### For Windows (WSL) Users
See `references/windows-wsl.md` for Windows WSL-specific configurations
```

**Benefits**:
- Users load only relevant content
- Reduces context waste
- Clearer platform-specific guidance

---

### Technique 3: Cross-Skill References

**Concept**: Reference other skills when appropriate

**When to use**:
- Skill builds on another skill's concepts
- Related skills provide complementary information
- Want to avoid duplicating other skills' content

**Implementation**:

SKILL.md:
```markdown
## Prerequisites

This skill assumes familiarity with:
- **git-basics** skill - For fundamental git operations
- **command-line** skill - For shell command usage

Load these skills first if needed.

## Related Skills

For related workflows:
- **ci-cd** skill - Continuous integration and deployment
- **code-review** skill - Code review best practices
```

**Benefits**:
- Avoids content duplication
- Leverages existing skills
- Creates skill ecosystem

---

### Technique 4: Version-Aware Content

**Concept**: Support multiple versions of tools/platforms

**When to use**:
- Tool has multiple common versions in use
- Significant differences between versions
- Users might be on different versions

**Implementation**:

SKILL.md:
```markdown
## Version Support

This skill covers:
- Python 3.8+ (recommended)
- Python 2.7 (legacy, see `references/python2-legacy.md`)

Most examples use Python 3.8+ syntax.
```

references/python2-legacy.md:
```markdown
# Python 2.7 Legacy Support

## Important Note
Python 2.7 reached end-of-life on January 1, 2020.
Migrate to Python 3.8+ when possible.

## Python 2.7 Equivalents

For users still on Python 2.7, here are the equivalent patterns...

[Detailed Python 2.7 content]
```

**Benefits**:
- Supports users on different versions
- Doesn't clutter main content with legacy info
- Clear migration path

---

### Technique 5: Performance Optimization Guidance

**Concept**: Provide performance considerations separately from functional guidance

**When to use**:
- Performance matters for the skill domain
- Optimizations add complexity
- Want to keep basic usage simple

**Implementation**:

SKILL.md:
```markdown
## Basic Usage
[Simple, straightforward approach]

## Performance Considerations
For performance-critical applications, see `references/optimization.md`
```

references/optimization.md:
```markdown
# Performance Optimization

## When Performance Matters
[Criteria for when to optimize]

## Profiling
[How to identify bottlenecks]

## Optimization Techniques

### Technique 1: Caching
[Detailed caching strategies]

### Technique 2: Lazy Loading
[Detailed lazy loading approaches]

### Technique 3: Parallelization
[Detailed parallelization methods]

## Benchmarks
[Performance comparisons with data]
```

**Benefits**:
- Keeps basic usage simple
- Provides optimization path for those who need it
- Avoids premature optimization

---

### Technique 6: Interactive Script Examples

**Concept**: Create examples that prompt for user input

**When to use**:
- Users need guided workflows
- Configuration requires user decisions
- Want to demonstrate interactive processes

**Implementation**:

examples/interactive-setup.sh:
```bash
#!/bin/bash
# Interactive setup wizard

echo "=== Skill Setup Wizard ==="
echo

# Prompt for configuration
read -p "Enter your API key: " api_key
read -p "Enter timeout (seconds) [default: 30]: " timeout
timeout=${timeout:-30}

# Confirm choices
echo
echo "Configuration:"
echo "  API Key: ${api_key:0:10}..."
echo "  Timeout: $timeout seconds"
echo

read -p "Proceed with setup? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
    echo "Setup cancelled"
    exit 1
fi

# Perform setup
echo "Creating configuration..."
cat > config.json <<EOF
{
  "api_key": "$api_key",
  "timeout": $timeout
}
EOF

echo "Setup complete! Configuration saved to config.json"
```

**Benefits**:
- Guided experience for users
- Reduces errors from manual configuration
- Demonstrates interactive patterns

---

### Technique 7: Validation at Multiple Levels

**Concept**: Provide validation scripts for different stages

**When to use**:
- Multi-step setup or configuration
- Want to catch errors early
- Users benefit from validation feedback

**Implementation**:

```
scripts/
├── validate-environment.sh    - Check prerequisites
├── validate-config.sh         - Check configuration
├── validate-setup.sh          - Check complete setup
└── validate-all.sh           - Run all validations
```

SKILL.md:
```markdown
## Validation

Validate at each stage:

1. **Before starting**: `./scripts/validate-environment.sh`
2. **After configuration**: `./scripts/validate-config.sh`
3. **After setup**: `./scripts/validate-setup.sh`
4. **Complete validation**: `./scripts/validate-all.sh`
```

**Benefits**:
- Catches errors early
- Clear validation points
- Easier troubleshooting

---

### Technique 8: Comprehensive Error Catalogs

**Concept**: Document common errors and solutions

**When to use**:
- Domain has common error patterns
- Errors are cryptic or confusing
- Want to reduce support burden

**Implementation**:

references/troubleshooting.md:
```markdown
# Troubleshooting Guide

## Error Catalog

### Error: "Permission denied"

**Symptoms**:
```
bash: ./script.sh: Permission denied
```

**Cause**: Script is not executable

**Solution**:
```bash
chmod +x script.sh
```

**Prevention**: Always run `chmod +x` when creating scripts

---

### Error: "Command not found: jq"

**Symptoms**:
```
bash: jq: command not found
```

**Cause**: Missing dependency

**Solution**:
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Fedora/RHEL
sudo dnf install jq
```

**Prevention**: Run validation script to check dependencies

[Continue with more errors...]
```

**Benefits**:
- Quick problem resolution
- Reduces frustration
- Common errors well-documented

---

### Technique 9: Migration Guides

**Concept**: Help users migrate from old patterns to new ones

**When to use**:
- Skill has evolved significantly
- Breaking changes introduced
- Want to help users upgrade

**Implementation**:

references/migration.md:
```markdown
# Migration Guide

## Migrating from v1 to v2

### Breaking Changes

#### Change 1: Configuration Format

**Old format** (v1):
```json
{
  "apiKey": "...",
  "timeoutMs": 30000
}
```

**New format** (v2):
```json
{
  "api_key": "...",
  "timeout": 30
}
```

**Migration**:
```bash
# Run migration script
./scripts/migrate-config-v1-to-v2.sh config.json
```

**Manual migration**:
1. Rename `apiKey` to `api_key`
2. Change `timeoutMs` to `timeout` (divide by 1000)

[Continue with more changes...]

### Deprecated Features

#### Feature: Legacy API
- **Status**: Deprecated in v2, removed in v3
- **Replacement**: New API (see `references/new-api.md`)
- **Timeline**: Support ends December 2024
```

**Benefits**:
- Smooth upgrade path
- Clear migration steps
- Reduces breaking change impact

## Advanced Content Organization

### Organizing Large Reference Libraries

When references/ becomes large:

**Problem**: 10+ reference files, hard to navigate

**Solution**: Sub-directories

```
references/
├── core/
│   ├── concepts.md
│   ├── workflows.md
│   └── best-practices.md
├── advanced/
│   ├── optimization.md
│   ├── scaling.md
│   └── security.md
├── platform/
│   ├── linux.md
│   ├── macos.md
│   └── windows.md
└── troubleshooting/
    ├── common-errors.md
    ├── debugging.md
    └── performance.md
```

**SKILL.md references**:
```markdown
## Additional Resources

### Core Concepts
- **`references/core/concepts.md`** - Fundamental concepts
- **`references/core/workflows.md`** - Common workflows

### Advanced Topics
- **`references/advanced/optimization.md`** - Performance optimization
- **`references/advanced/scaling.md`** - Scaling strategies

### Platform-Specific
- **`references/platform/linux.md`** - Linux-specific guidance
- **`references/platform/macos.md`** - macOS-specific guidance

### Troubleshooting
- **`references/troubleshooting/common-errors.md`** - Error catalog
- **`references/troubleshooting/debugging.md`** - Debugging techniques
```

## Summary

**Advanced techniques for skill development**:

1. **Multi-Tier References** - Organize by skill level
2. **Conditional Loading** - Platform/context-specific content
3. **Cross-Skill References** - Leverage other skills
4. **Version-Aware Content** - Support multiple versions
5. **Performance Guidance** - Separate optimization from basics
6. **Interactive Examples** - Guided workflows
7. **Multi-Level Validation** - Validate at each stage
8. **Error Catalogs** - Document common problems
9. **Migration Guides** - Help users upgrade

**When to use advanced techniques**:
- Skill domain is complex
- Users have diverse needs/contexts
- Skill has evolved significantly
- Performance matters
- Common support questions exist

**Benefits**:
- Better user experience
- More maintainable skills
- Reduced support burden
- Clearer organization

These techniques are optional but valuable for sophisticated skills with complex requirements.
