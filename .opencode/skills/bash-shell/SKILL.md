---
name: bash-shell
description: This skill should be used when the user asks to "write a bash script", "follow shell style guide", "format shell scripts", "create shell utilities", or needs guidance on Bash/shell scripting best practices and conventions.
license: Apache-2.0
---

# Bash Shell Style Guide Skill

Apply Google's Shell Style Guide conventions to write clean, maintainable, and secure Bash scripts.

## Overview

This skill provides comprehensive guidance for writing professional Bash shell scripts following Google's established conventions. Use this when creating new shell scripts, reviewing existing code, or establishing shell scripting standards for a project.

## When to Use Shell Scripts

Shell scripts are appropriate for:
- Small utilities and simple wrapper scripts
- Tasks primarily calling other utilities with minimal data manipulation
- Scripts under 100 lines with straightforward control flow

**Avoid shell scripts when**:
- Performance is critical
- Complex data manipulation is required
- The script exceeds 100 lines or uses non-straightforward control flow
- Maintainability by others is a concern

If writing a script that grows beyond these limits, rewrite in a more structured language early to avoid costly rewrites later.

## Essential Requirements

### Shebang and Shell Selection

Always use Bash for executable shell scripts:

```bash
#!/bin/bash
```

**Key points**:
- Bash is the only permitted shell scripting language for executables
- Use `set` to configure shell options for consistent behavior
- No need to strive for POSIX compatibility unless required by legacy systems

### File Extensions

**Executables**:
- Use `.sh` extension if a build rule will rename the source file
- Use no extension if the executable goes directly into user's `PATH`

**Libraries**:
- Must have `.sh` extension
- Should not be executable

## Core Style Guidelines

### Indentation and Formatting

**Indentation**: 2 spaces, no tabs

```bash
if [[ -f "${config_file}" ]]; then
  source "${config_file}"
fi
```

**Line length**: Maximum 80 characters

For long strings, use here-documents or embedded newlines:

```bash
# Using here-document
cat <<END
This is a long message that
spans multiple lines.
END

# Using embedded newlines
long_string="This is a long message
that spans multiple lines."
```

### Control Flow

Put `; then` and `; do` on the same line as control statements:

```bash
# Correct
for dir in "${dirs_to_cleanup[@]}"; do
  if [[ -d "${dir}" ]]; then
    rm -rf "${dir}"
  fi
done

# Loop variables should be local in functions
local dir
for dir in "${dirs_to_cleanup[@]}"; do
  # Process directory
done
```

### Variable Expansion and Quoting

**Variable expansion**: Prefer `"${var}"` over `"$var"`

```bash
# Preferred
echo "PATH=${PATH}, PWD=${PWD}, mine=${some_var}"

# Acceptable for special variables
echo "Positional: $1" "$5" "$3"
echo "Exit status: $?"
```

**Quoting rules**:
- Always quote strings containing variables, command substitutions, spaces, or shell meta characters
- Use arrays for safe quoting of lists
- Use `"$@"` for passing arguments (not `$*`)

```bash
# Quote variables
echo "${flag}"

# Quote command substitutions
flag="$(some_command and its args "$@")"

# Use arrays for lists
declare -a FLAGS
FLAGS=(--foo --bar='baz')
mybinary "${FLAGS[@]}"
```

### Testing and Conditionals

**Use `[[ … ]]` over `[ … ]`**:

```bash
# Preferred - supports pattern matching
if [[ "${filename}" =~ ^[[:alnum:]]+name ]]; then
  echo "Match"
fi

# String comparisons
if [[ "${my_var}" == "some_string" ]]; then
  do_something
fi

# Test for empty strings
if [[ -z "${my_var}" ]]; then
  echo "Variable is empty"
fi

# Test for non-empty strings
if [[ -n "${my_var}" ]]; then
  echo "Variable is not empty"
fi
```

**Use `(( … ))` for arithmetic**:

```bash
# Arithmetic comparisons
if (( my_var > 3 )); then
  do_something
fi

# Calculations
local -i hundred="$(( 10 * 10 ))"
(( i += 3 ))
```

### Functions

**Function syntax**:

```bash
# Single function
my_func() {
  local arg1="$1"
  local result
  
  result="$(process "${arg1}")"
  echo "${result}"
}

# Package-namespaced function
mypackage::my_func() {
  …
}
```

**Function comments**: Required for non-obvious functions

```bash
#######################################
# Cleanup files from the backup directory.
# Globals:
#   BACKUP_DIR
#   ORACLE_SID
# Arguments:
#   None
# Returns:
#   0 on success, non-zero on error
#######################################
cleanup() {
  rm -rf "${BACKUP_DIR}/${ORACLE_SID}/"*
}
```

### Naming Conventions

**Functions and variables**: lowercase with underscores

```bash
my_function() {
  local my_variable="value"
}
```

**Constants and environment variables**: UPPERCASE with underscores

```bash
readonly PATH_TO_FILES='/some/path'
declare -xr ORACLE_SID='PROD'
```

**Loop variables**: Descriptive names matching what you're looping through

```bash
for zone in "${zones[@]}"; do
  process_zone "${zone}"
done
```

## Error Handling

### Output to STDERR

Error messages go to STDERR:

```bash
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

if ! do_something; then
  err "Unable to do_something"
  exit 1
fi
```

### Check Return Values

Always check return values:

```bash
# Direct check
if ! mv "${file}" "${dest_dir}/"; then
  echo "Unable to move ${file} to ${dest_dir}" >&2
  exit 1
fi

# Using $?
mv "${file}" "${dest_dir}/"
if (( $? != 0 )); then
  echo "Unable to move ${file}" >&2
  exit 1
fi

# Check pipeline status
tar -cf - ./* | (cd "${dir}" && tar -xf -)
if (( PIPESTATUS[0] != 0 || PIPESTATUS[1] != 0 )); then
  echo "Unable to tar files to ${dir}" >&2
fi
```

## Best Practices

### Use ShellCheck

Run [ShellCheck](https://www.shellcheck.net/) on all scripts to identify common bugs and issues.

### Command Substitution

Use `$(command)` instead of backticks:

```bash
# Preferred
var="$(command "$(command1)")"

# Avoid
var="`command \`command1\``"
```

### Arrays

Use arrays for lists to avoid quoting issues:

```bash
# Good
declare -a files
files=(file1.txt file2.txt "file with spaces.txt")
for file in "${files[@]}"; do
  process "${file}"
done

# Avoid
files="file1.txt file2.txt file with spaces.txt"
for file in ${files}; do  # Breaks on spaces
  process "${file}"
done
```

### Local Variables

Declare function-specific variables with `local`:

```bash
my_func() {
  local name="$1"
  local my_var
  
  # Separate declaration and assignment for command substitution
  my_var="$(get_value)"
  (( $? == 0 )) || return
}
```

### Main Function

For scripts with multiple functions, use a `main` function:

```bash
main() {
  local config_file="$1"
  
  if [[ ! -f "${config_file}" ]]; then
    err "Config file not found: ${config_file}"
    return 1
  fi
  
  process_config "${config_file}"
}

main "$@"
```

### Avoid Common Pitfalls

**Don't use `eval`** - It's unsafe and makes debugging difficult

**Wildcard expansion** - Use explicit paths:

```bash
# Good
rm -v ./*

# Bad - files starting with - cause issues
rm -v *
```

**Pipes to while** - Use process substitution or `readarray`:

```bash
# Good - preserves variables
while read -r line; do
  last_line="${line}"
done < <(your_command)

# Or use readarray
readarray -t lines < <(your_command)
for line in "${lines[@]}"; do
  process "${line}"
done

# Bad - creates subshell, variables don't persist
your_command | while read -r line; do
  last_line="${line}"  # Won't be visible outside
done
```

## Quick Reference

**File header**:
```bash
#!/bin/bash
#
# Brief description of what this script does.
```

**Error output function**:
```bash
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
```

**Standard patterns**:
```bash
# Check command success
if ! command; then
  err "Command failed"
  exit 1
fi

# Test string equality
if [[ "${var}" == "value" ]]; then
  do_something
fi

# Test numeric comparison
if (( num > 10 )); then
  do_something
fi

# Loop over array
for item in "${array[@]}"; do
  process "${item}"
done

# Safe command substitution
result="$(command)"
if (( $? != 0 )); then
  err "Command failed"
  exit 1
fi
```

## Additional Resources

### Reference Files

For comprehensive style rules and patterns:
- **`references/google-shell-guide.md`** - Complete Google Shell Style Guide reference
- **`references/common-patterns.md`** - Frequently used patterns and idioms
- **`references/security-guidelines.md`** - Security best practices for shell scripts

### Example Scripts

Working examples in `examples/`:
- **`basic-script.sh`** - Simple utility script template
- **`advanced-script.sh`** - Script with functions, error handling, and argument parsing
- **`library-example.sh`** - Reusable function library example

## When in Doubt

**Be consistent**:
- Follow existing style in the codebase
- Consistency allows automation and reduces cognitive load
- Pick one style and stick with it throughout the project
