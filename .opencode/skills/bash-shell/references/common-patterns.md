# Common Bash Patterns and Idioms

This reference provides frequently used patterns and idioms for Bash scripting following the Google Shell Style Guide.

## Script Template

### Basic Script Structure

```bash
#!/bin/bash
#
# Brief description of what this script does.
# 
# Usage: script_name [options] arguments

set -euo pipefail  # Exit on error, undefined variables, pipe failures

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Global variables
declare -g CONFIG_FILE=""
declare -g VERBOSE=0

#######################################
# Print error message to stderr
# Arguments:
#   Error message
#######################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

#######################################
# Print usage information
#######################################
usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [options] arguments

Description of what this script does.

Options:
  -h, --help       Show this help message
  -v, --verbose    Enable verbose output
  -c, --config     Specify config file

Examples:
  ${SCRIPT_NAME} -c config.ini
EOF
}

#######################################
# Main function
# Arguments:
#   All script arguments
# Returns:
#   0 on success, non-zero on error
#######################################
main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -v|--verbose)
        VERBOSE=1
        shift
        ;;
      -c|--config)
        CONFIG_FILE="$2"
        shift 2
        ;;
      *)
        err "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done

  # Main script logic here
  
  return 0
}

main "$@"
```

## Error Handling Patterns

### Exit on Error with Cleanup

```bash
# Cleanup function
cleanup() {
  local exit_code=$?
  
  # Perform cleanup tasks
  if [[ -n "${TEMP_DIR:-}" ]]; then
    rm -rf "${TEMP_DIR}"
  fi
  
  exit "${exit_code}"
}

# Register cleanup on exit
trap cleanup EXIT INT TERM

# Script continues...
```

### Check Command Success

```bash
# Pattern 1: Direct check in if statement
if ! command arg1 arg2; then
  err "Command failed"
  exit 1
fi

# Pattern 2: Check $?
command arg1 arg2
if (( $? != 0 )); then
  err "Command failed"
  exit 1
fi

# Pattern 3: With custom error message
if ! command arg1 arg2; then
  err "Failed to process ${file}: command returned $?"
  exit 1
fi
```

### Check Pipeline Success

```bash
# Check entire pipeline
tar -cf - ./* | (cd "${dest}" && tar -xf -)
if (( PIPESTATUS[0] != 0 || PIPESTATUS[1] != 0 )); then
  err "Pipeline failed"
  exit 1
fi

# Check individual pipeline components
command1 | command2 | command3
declare -a pipe_status=( "${PIPESTATUS[@]}" )
if (( pipe_status[0] != 0 )); then
  err "command1 failed"
  exit 1
fi
if (( pipe_status[1] != 0 )); then
  err "command2 failed"
  exit 1
fi
```

## Argument Parsing Patterns

### Simple Positional Arguments

```bash
main() {
  if (( $# < 2 )); then
    err "Expected at least 2 arguments, got $#"
    usage
    exit 1
  fi
  
  local input_file="$1"
  local output_file="$2"
  
  # Process files...
}
```

### getopts Pattern (Short Options)

```bash
main() {
  local verbose=0
  local config_file=""
  local mode="default"
  
  while getopts "hvc:m:" opt; do
    case "${opt}" in
      h)
        usage
        exit 0
        ;;
      v)
        verbose=1
        ;;
      c)
        config_file="${OPTARG}"
        ;;
      m)
        mode="${OPTARG}"
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  done
  
  # Shift to remaining positional arguments
  shift $((OPTIND - 1))
  
  # Process positional arguments
  local input_file="$1"
}
```

### Manual Long Options Pattern

```bash
main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -v|--verbose)
        VERBOSE=1
        shift
        ;;
      -c|--config)
        if [[ -z "${2:-}" ]]; then
          err "--config requires an argument"
          exit 1
        fi
        CONFIG_FILE="$2"
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*)
        err "Unknown option: $1"
        exit 1
        ;;
      *)
        break
        ;;
    esac
  done
  
  # Remaining arguments in "$@"
}
```

## File and Directory Patterns

### Check File Existence and Type

```bash
# Check if file exists and is readable
if [[ ! -r "${config_file}" ]]; then
  err "Config file not found or not readable: ${config_file}"
  exit 1
fi

# Check if directory exists
if [[ ! -d "${data_dir}" ]]; then
  err "Directory not found: ${data_dir}"
  exit 1
fi

# Check if file is executable
if [[ ! -x "${script}" ]]; then
  err "Script not executable: ${script}"
  exit 1
fi

# Check if file is empty
if [[ ! -s "${data_file}" ]]; then
  err "File is empty: ${data_file}"
  exit 1
fi
```

### Create Temporary Directory

```bash
# Create secure temporary directory
readonly TEMP_DIR="$(mktemp -d -t script-XXXXXX)"

# Cleanup on exit
cleanup() {
  if [[ -n "${TEMP_DIR:-}" && -d "${TEMP_DIR}" ]]; then
    rm -rf "${TEMP_DIR}"
  fi
}
trap cleanup EXIT
```

### Find Script Directory

```bash
# Get the directory where the script is located
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the script name
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"

# Real path (follows symlinks)
readonly REAL_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
readonly REAL_SCRIPT_DIR="$(dirname "${REAL_SCRIPT}")"
```

### Safe File Operations

```bash
# Safe copy with verification
if ! cp "${source}" "${dest}"; then
  err "Failed to copy ${source} to ${dest}"
  exit 1
fi

# Atomic move
if ! mv "${temp_file}" "${final_file}"; then
  err "Failed to move ${temp_file} to ${final_file}"
  exit 1
fi

# Create directory if it doesn't exist
mkdir -p "${output_dir}" || {
  err "Failed to create directory: ${output_dir}"
  exit 1
}

# Remove files safely with wildcard
if [[ -d "${cleanup_dir}" ]]; then
  rm -f "${cleanup_dir}/"*.tmp || {
    err "Failed to clean up temporary files"
    exit 1
  }
fi
```

## String Manipulation Patterns

### String Tests

```bash
# Test if string is empty
if [[ -z "${var}" ]]; then
  echo "Variable is empty"
fi

# Test if string is not empty
if [[ -n "${var}" ]]; then
  echo "Variable is not empty"
fi

# String equality
if [[ "${var}" == "value" ]]; then
  echo "Match"
fi

# String inequality
if [[ "${var}" != "value" ]]; then
  echo "No match"
fi

# Pattern matching
if [[ "${filename}" == *.txt ]]; then
  echo "Text file"
fi

# Regex matching
if [[ "${email}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo "Valid email format"
fi
```

### String Manipulation

```bash
# Remove prefix
filename="path/to/file.txt"
echo "${filename#*/}"        # to/file.txt (shortest match)
echo "${filename##*/}"       # file.txt (longest match)

# Remove suffix
echo "${filename%/*}"        # path/to (shortest match)
echo "${filename%%/*}"       # path (longest match)

# Replace substring
string="hello world"
echo "${string/world/there}"           # hello there (first match)
echo "${string//o/O}"                  # hellO wOrld (all matches)

# Replace prefix
echo "${string/#hello/hi}"             # hi world

# Replace suffix
echo "${string/%world/there}"          # hello there

# Convert case
upper="${string^^}"          # HELLO WORLD
lower="${upper,,}"           # hello world

# Get length
echo "${#string}"            # 11

# Substring
echo "${string:0:5}"         # hello
echo "${string:6}"           # world
```

### Default Values

```bash
# Use default if variable is unset or empty
config_file="${CONFIG_FILE:-/etc/default.conf}"

# Assign default if variable is unset or empty
: "${CONFIG_FILE:=/etc/default.conf}"

# Use default only if variable is unset (not if empty)
config_file="${CONFIG_FILE-/etc/default.conf}"

# Error if variable is unset or empty
required_var="${REQUIRED_VAR:?Error: REQUIRED_VAR must be set}"
```

## Array Patterns

### Array Creation and Manipulation

```bash
# Create array
declare -a files
files=(file1.txt file2.txt file3.txt)

# Add elements
files+=(file4.txt)
files+=(file5.txt file6.txt)

# Array from command output (careful with whitespace)
readarray -t lines < <(command)

# Array length
echo "${#files[@]}"

# Access elements
echo "${files[0]}"           # First element
echo "${files[-1]}"          # Last element

# All elements (quoted)
echo "${files[@]}"

# All elements as single string
echo "${files[*]}"
```

### Iterating Arrays

```bash
# Iterate over elements
for file in "${files[@]}"; do
  echo "Processing: ${file}"
done

# Iterate with indices
for i in "${!files[@]}"; do
  echo "Index ${i}: ${files[i]}"
done

# Filter array elements
declare -a txt_files
for file in "${files[@]}"; do
  if [[ "${file}" == *.txt ]]; then
    txt_files+=("${file}")
  fi
done
```

### Array as Function Arguments

```bash
process_files() {
  local -a files=("$@")
  
  for file in "${files[@]}"; do
    echo "Processing: ${file}"
  done
}

# Call with array elements
process_files "${files[@]}"
```

## Loop Patterns

### Reading Files Line by Line

```bash
# Pattern 1: While read with process substitution
while IFS= read -r line; do
  echo "Line: ${line}"
done < <(command)

# Pattern 2: While read from file
while IFS= read -r line; do
  echo "Line: ${line}"
done < "${input_file}"

# Pattern 3: Using readarray
readarray -t lines < "${input_file}"
for line in "${lines[@]}"; do
  echo "Line: ${line}"
done
```

### Reading CSV/Delimited Files

```bash
# Read CSV file
while IFS=',' read -r col1 col2 col3; do
  echo "Column 1: ${col1}"
  echo "Column 2: ${col2}"
  echo "Column 3: ${col3}"
done < data.csv

# Skip header line
{
  IFS=',' read -r header  # Read and discard header
  while IFS=',' read -r col1 col2 col3; do
    process "${col1}" "${col2}" "${col3}"
  done
} < data.csv
```

### Loop with Counter

```bash
# For loop with range
for i in {1..10}; do
  echo "Iteration: ${i}"
done

# For loop with variable range
start=1
end=10
for i in $(seq "${start}" "${end}"); do
  echo "Iteration: ${i}"
done

# While loop with counter
i=0
while (( i < 10 )); do
  echo "Iteration: ${i}"
  (( i++ ))
done
```

## Numeric Comparison Patterns

```bash
# Comparison operators in (( ))
if (( var > 10 )); then
  echo "Greater than 10"
fi

if (( var >= 10 )); then
  echo "Greater than or equal to 10"
fi

if (( var < 10 )); then
  echo "Less than 10"
fi

if (( var <= 10 )); then
  echo "Less than or equal to 10"
fi

if (( var == 10 )); then
  echo "Equal to 10"
fi

if (( var != 10 )); then
  echo "Not equal to 10"
fi

# Multiple conditions
if (( var > 5 && var < 15 )); then
  echo "Between 5 and 15"
fi

if (( var < 5 || var > 15 )); then
  echo "Outside 5-15 range"
fi
```

## Function Patterns

### Function with Return Value

```bash
# Function that returns status code
check_file() {
  local file="$1"
  
  if [[ -f "${file}" ]]; then
    return 0
  else
    return 1
  fi
}

# Usage
if check_file "/path/to/file"; then
  echo "File exists"
else
  echo "File not found"
fi
```

### Function with Output

```bash
# Function that outputs result
get_timestamp() {
  date +'%Y%m%d_%H%M%S'
}

# Usage
timestamp="$(get_timestamp)"
echo "Current timestamp: ${timestamp}"
```

### Function with Multiple Return Values

```bash
# Use global variables or output multiple lines
parse_version() {
  local version="$1"
  local major minor patch
  
  IFS='.' read -r major minor patch <<< "${version}"
  
  # Output as separate lines
  echo "${major}"
  echo "${minor}"
  echo "${patch}"
}

# Usage
version_info="$(parse_version "1.2.3")"
readarray -t parts <<< "${version_info}"
major="${parts[0]}"
minor="${parts[1]}"
patch="${parts[2]}"
```

### Function with Named Arguments

```bash
# Use local variables with clear names
process_data() {
  local input_file="$1"
  local output_file="$2"
  local mode="${3:-default}"
  
  if [[ -z "${input_file}" ]]; then
    err "Input file required"
    return 1
  fi
  
  # Process data...
  return 0
}

# Usage
process_data "input.txt" "output.txt" "fast"
```

## Logging Patterns

### Simple Logging

```bash
# Timestamp function
timestamp() {
  date +'%Y-%m-%d %H:%M:%S'
}

# Log levels
log_info() {
  echo "[$(timestamp)] INFO: $*"
}

log_warn() {
  echo "[$(timestamp)] WARN: $*" >&2
}

log_error() {
  echo "[$(timestamp)] ERROR: $*" >&2
}

# Usage
log_info "Starting process"
log_warn "Low disk space"
log_error "Failed to connect to database"
```

### Logging with Verbosity Control

```bash
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

log_debug() {
  if [[ "${LOG_LEVEL}" == "DEBUG" ]]; then
    echo "[$(timestamp)] DEBUG: $*" >&2
  fi
}

log_info() {
  if [[ "${LOG_LEVEL}" =~ ^(DEBUG|INFO)$ ]]; then
    echo "[$(timestamp)] INFO: $*"
  fi
}

log_warn() {
  if [[ "${LOG_LEVEL}" =~ ^(DEBUG|INFO|WARN)$ ]]; then
    echo "[$(timestamp)] WARN: $*" >&2
  fi
}

log_error() {
  echo "[$(timestamp)] ERROR: $*" >&2
}
```

## Configuration File Patterns

### Source Configuration File

```bash
# Load configuration file
load_config() {
  local config_file="$1"
  
  if [[ ! -f "${config_file}" ]]; then
    err "Config file not found: ${config_file}"
    return 1
  fi
  
  # Source the configuration
  # shellcheck source=/dev/null
  source "${config_file}" || {
    err "Failed to load config: ${config_file}"
    return 1
  }
  
  return 0
}

# Usage
if ! load_config "/etc/myapp/config.sh"; then
  exit 1
fi
```

### Parse Simple INI-style Config

```bash
# Read simple key=value config
load_simple_config() {
  local config_file="$1"
  local key value
  
  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    [[ "${key}" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${key}" ]] && continue
    
    # Trim whitespace
    key="${key//[[:space:]]/}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    
    # Export as environment variable
    export "${key}=${value}"
  done < "${config_file}"
}
```

## Parallel Processing Pattern

### Simple Background Jobs

```bash
# Run jobs in parallel
process_file() {
  local file="$1"
  echo "Processing: ${file}"
  sleep 2
  echo "Done: ${file}"
}

# Start background jobs
for file in "${files[@]}"; do
  process_file "${file}" &
done

# Wait for all background jobs
wait

echo "All jobs completed"
```

### Parallel with Job Limit

```bash
# Limit concurrent jobs
readonly MAX_JOBS=4

run_parallel() {
  local -a files=("$@")
  local job_count=0
  
  for file in "${files[@]}"; do
    # Wait if at job limit
    while (( job_count >= MAX_JOBS )); do
      wait -n  # Wait for any job to finish
      (( job_count-- ))
    done
    
    # Start new job
    process_file "${file}" &
    (( job_count++ ))
  done
  
  # Wait for remaining jobs
  wait
}
```

## Summary

These patterns cover the most common Bash scripting scenarios following the Google Shell Style Guide. Use them as building blocks for your scripts, adapting as needed while maintaining consistency and readability.
