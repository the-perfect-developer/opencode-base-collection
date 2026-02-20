# Complete Google Shell Style Guide Reference

This document contains the complete Google Shell Style Guide for detailed reference.

## Table of Contents

1. [Background](#background)
2. [Shell Files and Interpreter Invocation](#shell-files-and-interpreter-invocation)
3. [Environment](#environment)
4. [Comments](#comments)
5. [Formatting](#formatting)
6. [Features and Bugs](#features-and-bugs)
7. [Naming Conventions](#naming-conventions)
8. [Calling Commands](#calling-commands)

## Background

### Which Shell to Use

**Bash is the only shell scripting language permitted for executables.**

Executables must start with `#!/bin/bash` and minimal flags. Use `set` to set shell options so that calling your script as `bash script_name` does not break its functionality.

Restricting all executable shell scripts to bash gives us a consistent shell language that's installed on all our machines. There is generally no need to strive for POSIX-compatibility or avoid "bashisms".

**Exception**: Legacy operating systems or constrained execution environments may require plain Bourne shell.

### When to Use Shell

**Shell should only be used for small utilities or simple wrapper scripts.**

Guidelines:
- If you're mostly calling other utilities with little data manipulation, shell is acceptable
- If performance matters, use something other than shell
- If writing a script over 100 lines or with complex control flow, rewrite it in a more structured language now
- Scripts grow - rewrite early to avoid costly rewrites later
- Consider maintainability by people other than the author

## Shell Files and Interpreter Invocation

### File Extensions

**Executables**: `.sh` extension or no extension

- Use `.sh` if a build rule will rename the source file (e.g., `foo.sh` → `foo`)
- Use no extension if added directly to user's `PATH`
- Either choice is acceptable if neither applies

**Libraries**: Must have `.sh` extension and should not be executable

### SUID/SGID

**SUID and SGID are forbidden on shell scripts.**

There are too many security issues with shell to allow SUID/SGID. Use `sudo` to provide elevated access.

## Environment

### STDOUT vs STDERR

**All error messages should go to STDERR.**

This separates normal status from actual issues.

Example error output function:

```bash
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

if ! do_something; then
  err "Unable to do_something"
  exit 1
fi
```

## Comments

### File Header

**Start each file with a description of its contents.**

Every file must have a top-level comment with a brief overview. Copyright notice and author information are optional.

Example:

```bash
#!/bin/bash
#
# Perform hot backups of Oracle databases.
```

### Function Comments

**Any function that is not both obvious and short must have a function header comment.**

Any function in a library must have a comment regardless of length or complexity.

Function comments should describe the intended API using:
- **Description**: What the function does
- **Globals**: List of global variables used and modified
- **Arguments**: Arguments taken
- **Outputs**: Output to STDOUT or STDERR
- **Returns**: Returned values other than default exit status

Example:

```bash
#######################################
# Cleanup files from the backup directory.
# Globals:
#   BACKUP_DIR
#   ORACLE_SID
# Arguments:
#   None
#######################################
cleanup() {
  rm -rf "${BACKUP_DIR}/${ORACLE_SID}/"*
}

#######################################
# Get configuration directory.
# Globals:
#   SOMEDIR
# Arguments:
#   None
# Outputs:
#   Writes location to stdout
#######################################
get_dir() {
  echo "${SOMEDIR}"
}

#######################################
# Delete a file in a sophisticated manner.
# Arguments:
#   File to delete, a path.
# Returns:
#   0 if thing was deleted, non-zero on error.
#######################################
del_thing() {
  rm "$1"
}
```

### Implementation Comments

**Comment tricky, non-obvious, interesting or important parts of your code.**

Follow general Google coding comment practice. Don't comment everything. If there's a complex algorithm or something unusual, add a short comment.

### TODO Comments

**Use TODO comments for temporary, short-term, or good-enough-but-not-perfect code.**

Format: `TODO` in all caps, followed by name, email, or identifier of person with best context.

Example:

```bash
# TODO(mrmonkey): Handle the unlikely edge cases (bug ####)
```

## Formatting

### Indentation

**Indent 2 spaces. No tabs.**

Use blank lines between blocks for readability. For existing files, stay faithful to existing indentation.

**Exception**: Only use tabs for the body of `<<-` tab-indented here-documents.

### Line Length and Long Strings

**Maximum line length is 80 characters.**

For strings longer than 80 characters, use here-documents or embedded newlines:

```bash
# Using here-document
cat <<END
I am an exceptionally long
string.
END

# Embedded newlines
long_string="I am an exceptionally
long string."

# Long paths are OK on their own line
long_file="/very/long/path/to/file"

# Line continuation for readability
long_string_alt="including ${long_file} in this long\
 string"
```

Avoid:

```bash
# Just because a line contains an exception doesn't mean the rest shouldn't wrap
bad_long_string="i am including /very/long/file in this long string."
```

### Pipelines

**Split pipelines one per line if they don't all fit on one line.**

If a pipeline fits on one line, keep it on one line. Otherwise, split at one pipe segment per line with the pipe on the newline and 2-space indent:

```bash
# All fits on one line
command1 | command2

# Long commands
command1 \
  | command2 \
  | command3 \
  | command4
```

This applies to chains using `|`, `||`, and `&&`.

### Control Flow

**Put `; then` and `; do` on the same line as the `if`, `for`, or `while`.**

`else` should be on its own line. Closing statements (`fi`, `done`) should be on their own line, vertically aligned with the opening statement.

Example:

```bash
# If inside a function, declare the loop variable as local
local dir
for dir in "${dirs_to_cleanup[@]}"; do
  if [[ -d "${dir}/${SESSION_ID}" ]]; then
    log_date "Cleaning up old files in ${dir}/${SESSION_ID}"
    rm "${dir}/${SESSION_ID}/"* || error_message
  else
    mkdir -p "${dir}/${SESSION_ID}" || error_message
  fi
done
```

**Consistently include `in "$@"` in for loops** for clarity, even though it can be omitted:

```bash
for arg in "$@"; do
  echo "argument: ${arg}"
done
```

### Case Statement

**Indent alternatives by 2 spaces.**

Guidelines:
- One-line alternative needs space after close parenthesis and before `;;`
- Long/multi-command alternatives split over multiple lines
- No need to quote match expressions
- Pattern expressions should not be preceded by open parenthesis
- Avoid `;&` and `;;&` notations

```bash
case "${expression}" in
  a)
    variable="…"
    some_command "${variable}" "${other_expr}"
    ;;
  absolute)
    actions="relative"
    another_command "${actions}" "${other_expr}"
    ;;
  *)
    error "Unexpected expression '${expression}'"
    ;;
esac
```

Simple one-line alternatives:

```bash
verbose='false'
aflag=''
bflag=''
files=''
while getopts 'abf:v' flag; do
  case "${flag}" in
    a) aflag='true' ;;
    b) bflag='true' ;;
    f) files="${OPTARG}" ;;
    v) verbose='true' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
done
```

### Variable Expansion

**In order of precedence: Stay consistent; quote variables; prefer `"${var}"` over `"$var"`.**

These are strongly recommended guidelines:
1. Stay consistent with existing code
2. Quote variables (see Quoting section)
3. Don't brace-delimit single character shell specials/positional parameters unless necessary
4. Prefer brace-delimiting all other variables

```bash
# Preferred style for 'special' variables
echo "Positional: $1" "$5" "$3"
echo "Specials: !=$!, -=$-, _=$_. ?=$?, #=$# *=$* @=$@ \$=$$"

# Braces necessary
echo "many parameters: ${10}"

# Braces avoiding confusion
# Output is "a0b0c0"
set -- a b c
echo "${1}0${2}0${3}0"

# Preferred style for other variables
echo "PATH=${PATH}, PWD=${PWD}, mine=${some_var}"
while read -r f; do
  echo "file=${f}"
done < <(find /tmp)
```

Discouraged:

```bash
# Unquoted vars, unbraced vars, brace-delimited single letter specials
echo a=$avar "b=$bvar" "PID=${$}" "${1}"

# Confusing - expanded as "${1}0${2}0${3}0", not "${10}${20}${30}"
set -- a b c
echo "$10$20$30"
```

**Note**: Braces are not quoting - double quotes must still be used.

### Quoting

**Rules**:
- Always quote strings containing variables, command substitutions, spaces, or shell meta characters (unless careful unquoted expansion is required or it's a shell-internal integer)
- Use arrays for safe quoting of lists (especially command-line flags)
- Optionally quote shell-internal readonly special variables that are integers: `$?`, `$#`, `$$`, `$!`
- Prefer quoting "named" internal integer variables (e.g., `PPID`)
- Prefer quoting strings that are "words" (vs command options or paths)
- Be aware of quoting rules for pattern matches in `[[ … ]]`
- Use `"$@"` unless you have a specific reason to use `$*`

```bash
# Simple examples

# Quote command substitutions
flag="$(some_command and its args "$@" 'quoted separately')"

# Quote variables
echo "${flag}"

# Use arrays with quoted expansion for lists
declare -a FLAGS
FLAGS=(--foo --bar='baz')
readonly FLAGS
mybinary "${FLAGS[@]}"

# OK to not quote internal integer variables
if (( $# > 3 )); then
  echo "ppid=${PPID}"
fi

# Never quote literal integers
value=32

# Quote command substitutions, even when expecting integers
number="$(generate_number)"

# Prefer quoting words
readonly USE_INTEGER='true'

# Quote shell meta characters
echo 'Hello stranger, and well met. Earn lots of $$$'
echo "Process $$: Done making \$\$\$."

# Command options or path names
grep -li Hugo /dev/null "$1"

# Less simple examples

# Quote variables unless proven false
git send-email --to "${reviewers}" ${ccs:+"--cc" "${ccs}"}

# Positional parameter precautions
grep -cP '([Ss]pecial|\|?characters*)$' ${1:+"$1"}

# For passing arguments:
# "$@" retains arguments as-is (almost always what you want)
# $* and $@ split on spaces, clobbering arguments with spaces
# "$*" expands to one argument with all args joined by spaces

(set -- 1 "2 two" "3 three tres"; echo $#; set -- "$*"; echo "$#, $@")
(set -- 1 "2 two" "3 three tres"; echo $#; set -- "$@"; echo "$#, $@")
```

## Features and Bugs

### ShellCheck

**Use [ShellCheck](https://www.shellcheck.net/) for all scripts.**

ShellCheck identifies common bugs and warnings. Recommended for all scripts, large or small.

### Command Substitution

**Use `$(command)` instead of backticks.**

Nested backticks require escaping with `\`. The `$(command)` format doesn't change when nested and is easier to read.

```bash
# Preferred
var="$(command "$(command1)")"

# Not preferred
var="`command \`command1\``"
```

### Test, `[ … ]`, and `[[ … ]]`

**`[[ … ]]` is preferred over `[ … ]`, `test`, and `/usr/bin/[`.**

Benefits:
- No pathname expansion or word splitting between `[[` and `]]`
- Allows pattern and regular expression matching
- Reduces errors

```bash
# Pattern matching
if [[ "filename" =~ ^[[:alnum:]]+name ]]; then
  echo "Match"
fi

# Exact pattern (Does not match in this case)
if [[ "filename" == "f*" ]]; then
  echo "Match"
fi
```

Avoid:

```bash
# Gives "too many arguments" error - f* expands to directory contents
# Also `[` doesn't support `==`, only `=`
if [ "filename" == f* ]; then
  echo "Match"
fi
```

See E14 in the [Bash FAQ](http://tiswww.case.edu/php/chet/bash/FAQ) for details.

### Testing Strings

**Use quotes rather than filler characters.**

Bash handles empty strings in tests. Use tests for empty/non-empty strings instead of filler characters.

```bash
# Preferred
if [[ "${my_var}" == "some_string" ]]; then
  do_something
fi

# -z (length zero) and -n (length not zero) are preferred
if [[ -z "${my_var}" ]]; then
  do_something
fi

# This is OK but not preferred
if [[ "${my_var}" == "" ]]; then
  do_something
fi
```

Avoid:

```bash
# Not this
if [[ "${my_var}X" == "some_stringX" ]]; then
  do_something
fi
```

**Explicitly use `-z` or `-n`** to avoid confusion:

```bash
# Use this
if [[ -n "${my_var}" ]]; then
  do_something
fi

# Instead of this
if [[ "${my_var}" ]]; then
  do_something
fi
```

**Use `==` for equality** rather than `=` (though both work). The former encourages `[[` and the latter can be confused with assignment.

**Be careful with `<` and `>`** in `[[ … ]]` - they perform lexicographical comparison. Use `(( … ))` or `-lt`/`-gt` for numerical comparison.

```bash
# Preferred
if [[ "${my_var}" == "val" ]]; then
  do_something
fi

if (( my_var > 3 )); then
  do_something
fi

if [[ "${my_var}" -gt 3 ]]; then
  do_something
fi

# Avoid
if [[ "${my_var}" = "val" ]]; then
  do_something
fi

# Probably unintended lexicographical comparison
# True for 4, false for 22
if [[ "${my_var}" > 3 ]]; then
  do_something
fi
```

### Wildcard Expansion of Filenames

**Use an explicit path when doing wildcard expansion.**

Filenames can begin with `-`, so it's safer to expand with `./*` instead of `*`.

```bash
# Incorrectly deletes almost everything by force
$ rm -v *
removed directory: `somedir'
removed `somefile'

# Correct
$ rm -v ./*
removed `./-f'
removed `./-r'
rm: cannot remove `./somedir': Is a directory
removed `./somefile'
```

### Eval

**`eval` should be avoided.**

Eval munges input and can set variables without allowing checks.

```bash
# What does this set? Did it succeed?
eval $(set_my_variables)

# What happens if a returned value has a space?
variable="$(eval some_function)"
```

### Arrays

**Use arrays to store lists of elements.**

This avoids quoting complications, especially for argument lists. Arrays should not facilitate complex data structures.

Arrays store ordered collections of strings and can be safely expanded into individual elements.

```bash
# Preferred
declare -a flags
flags=(--foo --bar='baz')
flags+=(--greeting="Hello ${name}")
mybinary "${flags[@]}"
```

Avoid:

```bash
# Don't use strings for sequences
flags='--foo --bar=baz'
flags+=' --greeting="Hello world"'  # Won't work as intended
mybinary ${flags}
```

Avoid:

```bash
# Command expansions return single strings
# Unquoted expansion in array assignment doesn't work with special chars/whitespace

# Bad - ls output goes through expansion and splitting
declare -a files=($(ls /directory))

# Bad - get_arguments output goes through same process
mybinary $(get_arguments)
```

#### Arrays Pros

- Allow lists without confusing quoting semantics
- Safely store sequences/lists of arbitrary strings, including those with whitespace

#### Arrays Cons

- Can risk script complexity growing

#### Arrays Decision

Use arrays to safely create and pass around lists. When building command arguments, use arrays to avoid quoting issues. Use quoted expansion `"${array[@]}"` to access arrays.

If more advanced data manipulation is required, avoid shell scripting altogether.

### Pipes to While

**Use process substitution or `readarray` builtin (bash4+) instead of piping to while.**

Pipes create a subshell, so variables modified within a pipeline don't propagate to the parent shell.

```bash
# Bad - last_line will always be 'NULL'
last_line='NULL'
your_command | while read -r line; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done
echo "${last_line}"  # Outputs 'NULL'
```

**Process substitution** creates a subshell but allows redirecting from it:

```bash
# Good - outputs last non-empty line
last_line='NULL'
while read -r line; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done < <(your_command)
echo "${last_line}"
```

**readarray alternative**:

```bash
# Also good
last_line='NULL'
readarray -t lines < <(your_command)
for line in "${lines[@]}"; do
  if [[ -n "${line}" ]]; then
    last_line="${line}"
  fi
done
echo "${last_line}"
```

**Note**: Be cautious using for-loop over output like `for var in $(...)` - output is split by whitespace, not by line. A `while read` loop or `readarray` is often safer and clearer.

### Arithmetic

**Always use `(( … ))` or `$(( … ))` rather than `let`, `$[ … ]`, or `expr`.**

Never use `$[ … ]` syntax, `expr` command, or `let` built-in.

`<` and `>` don't perform numerical comparison inside `[[ … ]]` (they're lexicographical). Don't use `[[ … ]]` for numeric comparisons - use `(( … ))` instead.

Avoid using `(( … ))` as a standalone statement with `set -e` enabled (particularly when expression can evaluate to zero, like `(( i++ ))` when `i=0`).

```bash
# Simple calculation as text
echo "$(( 2 + 2 )) is 4"

# Arithmetic comparisons for testing
if (( a < b )); then
  …
fi

# Calculation assigned to variable
(( i = 10 * j + 400 ))
```

Avoid:

```bash
# Non-portable and deprecated
i=$[2 * 10]

# 'let' isn't declarative - unquoted assignments subject to globbing/wordsplitting
let i="2 + 2"

# expr is external program, not builtin
i=$( expr 4 + 4 )

# Quoting can be error prone with expr
i=$( expr 4 '*' 4 )
```

Shell's built-in arithmetic is many times faster than `expr`.

**Within `$(( … ))`, `${var}` and `$var` forms are not required**. The shell looks up variables automatically:

```bash
# Declare variables as integers when possible, prefer local over globals
local -i hundred="$(( 10 * 10 ))"
declare -i five="$(( 10 / 2 ))"

# Increment by three
# Note: no ${i} or $i, space after (( and before ))
(( i += 3 ))

# Decrement by five
(( i -= 5 ))

# Complicated computations
# Normal arithmetic operator precedence is observed
hr=2
min=5
sec=30
echo "$(( hr * 3600 + min * 60 + sec ))" # prints 7530
```

### Aliases

**Avoid aliases in scripts.**

Although commonly seen in `.bashrc`, aliases should be avoided in scripts. The [Bash manual](https://www.gnu.org/software/bash/manual/html_node/Aliases.html) notes: "For almost every purpose, shell functions are preferred over aliases."

Aliases are cumbersome - they require careful quoting and escaping, and mistakes are hard to notice.

```bash
# Bad - evaluates $RANDOM once when alias is defined
# Echo'ed string will be the same on each invocation
alias random_name="echo some_prefix_${RANDOM}"
```

Functions provide a superset of alias functionality:

```bash
# Good
random_name() {
  echo "some_prefix_${RANDOM}"
}

# Note: unlike aliases, function arguments are accessed via $@
fancy_ls() {
  ls -lh "$@"
}
```

## Naming Conventions

### Function Names

**Lowercase, with underscores to separate words. Separate libraries with `::`.**

Parentheses are required after the function name. The `function` keyword is optional but must be used consistently throughout a project.

For single functions, use lowercase with underscores. For packages, separate package names with `::`. Functions for interactive use may avoid colons (confuses bash auto-completion).

Braces must be on the same line as the function name, with no space between function name and parenthesis.

```bash
# Single function
my_func() {
  …
}

# Part of a package
mypackage::my_func() {
  …
}
```

The `function` keyword is extraneous when `()` is present but enhances quick identification of functions.

### Variable Names

**Same as for function names.**

Loop variables should be similarly named for what you're looping through:

```bash
for zone in "${zones[@]}"; do
  something_with "${zone}"
done
```

### Constants, Environment Variables, and readonly Variables

**Capitalized, separated with underscores, declared at top of file.**

```bash
# Constant
readonly PATH_TO_FILES='/some/path'

# Both constant and exported to environment
declare -xr ORACLE_SID='PROD'
```

For clarity, `readonly` or `export` is recommended vs equivalent `declare` commands. You can do one after the other:

```bash
readonly PATH_TO_FILES='/some/path'
export PATH_TO_FILES
```

**OK to set a constant at runtime or conditionally, but make readonly immediately**:

```bash
ZIP_VERSION="$(dpkg --status zip | sed -n 's/^Version: //p')"
if [[ -z "${ZIP_VERSION}" ]]; then
  ZIP_VERSION="$(pacman -Q --info zip | sed -n 's/^Version *: //p')"
fi
if [[ -z "${ZIP_VERSION}" ]]; then
  handle_error_and_quit
fi
readonly ZIP_VERSION
```

### Source Filenames

**Lowercase, with underscores to separate words if desired.**

For consistency: `maketemplate` or `make_template` but not `make-template`.

### Use Local Variables

**Declare function-specific variables with `local`.**

Ensures local variables are only seen inside a function and its children. Avoids polluting global namespace and inadvertently setting variables with significance outside the function.

**Declaration and assignment must be separate when assignment value is from command substitution** - the `local` builtin doesn't propagate the exit code.

```bash
# Correct
my_func2() {
  local name="$1"

  # Separate lines for declaration and assignment
  local my_var
  my_var="$(my_func)"
  (( $? == 0 )) || return

  …
}
```

Avoid:

```bash
# Wrong - $? will always be zero (exit code of 'local', not my_func)
my_func2() {
  local my_var="$(my_func)"
  (( $? == 0 )) || return
  …
}
```

### Function Location

**Put all functions together near the top of file, just below constants.**

Don't hide executable code between functions - makes code hard to follow and debugging difficult.

Only includes, `set` statements, and setting constants may be done before declaring functions.

### main

**A function called `main` is required for scripts with at least one other function.**

To easily find the program start, put the main program in a function called `main` as the bottom-most function. This provides consistency and allows defining more variables as `local`.

The last non-comment line should be:

```bash
main "$@"
```

For short scripts with linear flow, `main` is overkill and not required.

## Calling Commands

### Checking Return Values

**Always check return values and give informative return values.**

For unpiped commands, use `$?` or check directly via `if` statement.

```bash
# Direct check
if ! mv "${file_list[@]}" "${dest_dir}/"; then
  echo "Unable to move ${file_list[*]} to ${dest_dir}" >&2
  exit 1
fi

# Using $?
mv "${file_list[@]}" "${dest_dir}/"
if (( $? != 0 )); then
  echo "Unable to move ${file_list[*]} to ${dest_dir}" >&2
  exit 1
fi
```

**PIPESTATUS** allows checking return codes from all parts of a pipe:

```bash
# Check success/failure of whole pipe
tar -cf - ./* | (cd "${dir}" && tar -xf -)
if (( PIPESTATUS[0] != 0 || PIPESTATUS[1] != 0 )); then
  echo "Unable to tar files to ${dir}" >&2
fi
```

**PIPESTATUS is overwritten** by any other command. If you need to act differently based on where error occurred, assign PIPESTATUS immediately (don't forget `[` is a command and wipes PIPESTATUS):

```bash
tar -cf - ./* | (cd "${DIR}" && tar -xf -)
return_codes=( "${PIPESTATUS[@]}" )
if (( return_codes[0] != 0 )); then
  do_something
fi
if (( return_codes[1] != 0 )); then
  do_something_else
fi
```

### Builtin Commands vs. External Commands

**Given the choice, choose the builtin.**

Prefer builtins like [Parameter Expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) functionality - more efficient, robust, and portable than tools like `sed`.

```bash
# Preferred
addition="$(( X + Y ))"
substitution="${string/#foo/bar}"
if [[ "${string}" =~ foo:(\d+) ]]; then
  extraction="${BASH_REMATCH[1]}"
fi

# Avoid
addition="$(expr "${X}" + "${Y}")"
substitution="$(echo "${string}" | sed -e 's/^foo/bar/')"
extraction="$(echo "${string}" | sed -e 's/foo:\([0-9]\)/\1/')"
```

## Conclusion

**When in doubt: Be consistent.**

Using one style consistently lets us focus on more important issues. Consistency allows automation. "Be Consistent" often means "Just pick one and stop worrying about it" - the value of flexibility is outweighed by the cost of arguing.

However, consistency has limits. It's a good tiebreaker when there's no clear technical argument or long-term direction. Don't use consistency to justify old styles without considering benefits of new styles or the codebase's tendency to converge on newer styles over time.
