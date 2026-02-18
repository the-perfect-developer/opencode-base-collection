# Template Syntax Reference

Complete reference for all template syntax features in OpenCode commands.

## Overview

Command templates support special syntax to make prompts dynamic and context-aware:

1. **Arguments** - `$ARGUMENTS`, `$1`, `$2`, etc.
2. **Shell output** - *!`command`*
3. **File references** - `@path/to/file`

These features can be combined within a single template.

## Arguments

### $ARGUMENTS

Captures all arguments as a single string.

**Template**:
```markdown
Create a new component named $ARGUMENTS
```

**Usage**:
```
/component Button
```

**Result**:
```
Create a new component named Button
```

**With multiple words**:
```
/component "User Profile Card"
```

**Result**:
```
Create a new component named User Profile Card
```

### Positional Arguments ($1, $2, $3, ...)

Access individual arguments by position (1-indexed).

**Template**:
```markdown
Create file $1 in directory $2 with content: $3
```

**Usage**:
```
/create-file config.json src/utils "export default {}"
```

**Result**:
```
Create file config.json in directory src/utils with content: export default {}
```

### Combining $ARGUMENTS and Positional

You can use both in the same template:

**Template**:
```markdown
Deploy $1 to environment $2
All args: $ARGUMENTS
```

**Usage**:
```
/deploy myapp staging
```

**Result**:
```
Deploy myapp to environment staging
All args: myapp staging
```

### Missing Arguments

If an argument is not provided, the placeholder remains unchanged:

**Template**:
```markdown
File: $1, Directory: $2
```

**Usage**:
```
/command file.txt
```

**Result**:
```
File: file.txt, Directory: $2
```

**Best practice**: Document required arguments in the command description.

### Argument Escaping

Arguments with spaces should be quoted:

**Usage**:
```
/command "argument with spaces" "another argument"
```

**Positional mapping**:
- `$1` = `argument with spaces`
- `$2` = `another argument`

## Shell Command Output

### Syntax: !`command`

Execute bash commands and inject their output into the prompt.

**Template**:
```markdown
Current git status:
!`git status`

Analyze the working directory state.
```

**Result** (output injected):
```markdown
Current git status:
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

Analyze the working directory state.
```

### Execution Context

Commands execute from the **project root directory** (where `.opencode` exists or where OpenCode was initialized).

**Template**:
```markdown
Files in project:
!`ls -la`
```

This lists files in the project root, not the current shell directory.

### Multiple Commands

Include multiple shell commands in one template:

**Template**:
```markdown
Branch: !`git branch --show-current`
Status: !`git status --short`
Recent commits: !`git log --oneline -5`

Review the repository state.
```

### Command Failure

If a command fails, the error output is included in the prompt:

**Template**:
```markdown
Dependencies:
!`npm list --depth=0`
```

**If npm not installed**:
```
Dependencies:
bash: npm: command not found
```

**Best practice**: Use commands that are likely available in the target environment.

### Complex Commands

Use full bash syntax including pipes, redirects, etc.:

**Template**:
```markdown
Modified files:
!`git status --short | grep "^ M"`

Staged files:
!`git status --short | grep "^M "`
```

**With arguments**:
```markdown
Files matching pattern:
!`find . -name "$1" -type f`
```

Usage: `/find-files "*.ts"`

### Security Considerations

**Safe commands** (read-only):
- `git status`, `git log`, `git diff`
- `ls`, `cat`, `grep`
- `npm list`, `npm outdated`

**Unsafe commands** (avoid):
- `rm`, `mv`, `cp` (file modifications)
- `git push`, `git commit` (state changes)
- `npm install` (system modifications)

**Best practice**: Keep commands read-only and non-destructive.

## File References

### Syntax: @path/to/file

Include file contents in the prompt automatically.

**Template**:
```markdown
Review this component:
@src/components/Button.tsx

Suggest improvements for performance and accessibility.
```

**Result**:
```markdown
Review this component:
[Full contents of Button.tsx]

Suggest improvements for performance and accessibility.
```

### Relative Paths

Paths are relative to the project root:

**Template**:
```markdown
Compare these files:
@src/old-api.ts
@src/new-api.ts
```

### Multiple Files

Reference multiple files in one template:

**Template**:
```markdown
Configuration files:
@package.json
@tsconfig.json
@.eslintrc.js

Ensure these are consistent.
```

### File Reference with Arguments

Combine file references with arguments:

**Template**:
```markdown
Document this file:
@$1

Include examples and usage notes.
```

**Usage**:
```
/doc src/utils/parser.ts
```

**Result**:
```markdown
Document this file:
[Full contents of src/utils/parser.ts]

Include examples and usage notes.
```

### Glob Patterns

File references don't support glob patterns. To include multiple files, use shell commands:

**Template**:
```markdown
TypeScript files in components:
!`find src/components -name "*.tsx" -exec cat {} \;`
```

**Better approach**: Use file references for specific files, or use shell commands to list then reference individually.

### Missing Files

If a referenced file doesn't exist, an error message is included:

**Template**:
```markdown
Config file:
@nonexistent.json
```

**Result**:
```markdown
Config file:
Error: File not found: nonexistent.json
```

## Combining Features

### Arguments + Shell Commands

**Template**:
```markdown
Analyze test results for $1:
!`npm test -- $1 --coverage`

Suggest improvements for failing tests.
```

**Usage**: `/analyze Button.test.tsx`

### Arguments + File References

**Template**:
```markdown
Create component $1 based on this template:
@templates/component.tsx

Follow the same patterns and structure.
```

**Usage**: `/create-component UserProfile`

### Shell Commands + File References

**Template**:
```markdown
Modified files:
!`git diff --name-only`

Current implementation of changed util:
@src/utils/helper.ts

Review changes and suggest improvements.
```

### All Three Combined

**Template**:
```markdown
Deploy $1 to $2 environment.

Current version:
@package.json

Build status:
!`npm run build 2>&1 | tail -20`

Verify readiness for deployment.
```

**Usage**: `/deploy myapp production`

## Advanced Patterns

### Conditional Content

Use shell commands for conditional content:

**Template**:
```markdown
!`if [ -f .env ]; then echo "Environment file found"; else echo "No .env file"; fi`

Verify configuration before deployment.
```

### Dynamic File References

Use shell command output to determine which files to reference:

**Template**:
```markdown
Test files that changed:
!`git diff --name-only | grep ".test."`

Review test coverage for these changes.
```

### Nested Arguments

Combine positional arguments creatively:

**Template**:
```markdown
Operation: $1
Target: $2
Environment: ${3:-development}

Run $1 on $2 in environment ${3:-development}.
```

Note: Bash-style default values (`${3:-default}`) work if the template is processed by bash.

### Multi-line Shell Commands

Use multi-line shell commands for complex operations:

**Template**:
```markdown
Repository analysis:
!`
echo "Branch: $(git branch --show-current)"
echo "Commits ahead: $(git rev-list --count @{u}..HEAD)"
echo "Uncommitted changes: $(git status --short | wc -l)"
`

Review the repository state.
```

## Best Practices

### Arguments

**DO**:
- Use `$ARGUMENTS` for single variable-length input
- Use positional args for multiple distinct values
- Document required arguments in description
- Validate argument format if needed

**DON'T**:
- Mix `$ARGUMENTS` and positional args for the same input
- Assume arguments are always provided
- Use too many positional arguments (>4 gets confusing)

### Shell Commands

**DO**:
- Keep commands read-only
- Test commands in terminal first
- Use common, widely-available commands
- Include error handling where possible

**DON'T**:
- Modify system state
- Use destructive operations
- Assume all environments have same tools
- Create security vulnerabilities with user input

### File References

**DO**:
- Use specific file paths
- Verify files exist in expected location
- Reference relevant files only
- Combine with arguments for flexibility

**DON'T**:
- Reference too many large files (context limit)
- Use absolute paths (breaks portability)
- Reference files with sensitive data
- Assume file structure across projects

## Debugging Templates

### Test Argument Replacement

Create a test command to see argument replacement:

**Template**:
```markdown
All args: $ARGUMENTS
Arg 1: $1
Arg 2: $2
Arg 3: $3
```

**Usage**: `/test arg1 arg2 arg3`

### Test Shell Commands

Verify shell commands work correctly:

**Template**:
```markdown
!`echo "Current directory: $(pwd)"`
!`echo "User: $(whoami)"`
!`echo "Date: $(date)"`
```

### Test File References

Verify file references resolve correctly:

**Template**:
```markdown
Package file:
@package.json

[Should show package.json contents]
```

## Common Issues

### Issue: Arguments not replaced

**Problem**: Template shows `$1` instead of argument value.

**Solutions**:
- Verify you passed arguments: `/command value`
- Check argument syntax: `$1` not `${1}`
- Ensure template uses correct placeholder

### Issue: Shell command not executing

**Problem**: Template shows *!`command`* literally.

**Solutions**:
- Check syntax: *!`command`* not `$(command)` or `` `command` ``
- Verify command works in terminal
- Check command is available on system

### Issue: File not found

**Problem**: Error message instead of file contents.

**Solutions**:
- Verify file path relative to project root
- Check file exists: `ls path/to/file`
- Use forward slashes: `src/file.ts` not `src\file.ts`

### Issue: Command output truncated

**Problem**: Shell command output cut off.

**Solutions**:
- Limit output with `head` or `tail`: *!`command | head -20`*
- Filter output: *!`command | grep pattern`*
- Split into multiple commands
