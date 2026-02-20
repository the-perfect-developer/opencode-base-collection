# Security Guidelines for Shell Scripts

This reference covers security best practices for Bash shell scripting.

## Core Security Principles

### 1. Use Safe Shell Options

Always enable these options at the start of your scripts:

```bash
#!/bin/bash

# Exit on error
set -e

# Exit on undefined variable
set -u

# Exit on pipe failure
set -o pipefail

# Or combine them:
set -euo pipefail
```

**What they do**:
- `set -e`: Exit immediately if any command fails
- `set -u`: Treat undefined variables as errors
- `set -o pipefail`: Return exit code of rightmost failed command in pipeline

**When to disable temporarily**:
```bash
# Disable for specific command that may fail
set +e
command_that_might_fail
exit_code=$?
set -e

# Handle the error
if (( exit_code != 0 )); then
  handle_error
fi
```

### 2. Never Use SUID/SGID

**SUID and SGID are forbidden on shell scripts** due to security vulnerabilities.

```bash
# NEVER do this
chmod u+s script.sh    # SUID - FORBIDDEN
chmod g+s script.sh    # SGID - FORBIDDEN
```

**Use sudo instead**:
```bash
#!/bin/bash
# Script that needs root privileges

if [[ "${EUID}" -ne 0 ]]; then
  echo "This script must be run as root" >&2
  echo "Please run: sudo $0 $*" >&2
  exit 1
fi

# Continue with privileged operations
```

### 3. Validate All Input

Never trust user input or external data.

```bash
# Bad - vulnerable to injection
file="$1"
rm "${file}"

# Good - validate input
file="$1"

# Check file is in expected directory
if [[ ! "${file}" =~ ^/safe/directory/ ]]; then
  err "File must be in /safe/directory/"
  exit 1
fi

# Check file exists and is a regular file
if [[ ! -f "${file}" ]]; then
  err "Not a valid file: ${file}"
  exit 1
fi

# Now safe to remove
rm "${file}"
```

**Validate patterns**:
```bash
# Validate numeric input
if ! [[ "${port}" =~ ^[0-9]+$ ]]; then
  err "Port must be numeric"
  exit 1
fi

if (( port < 1 || port > 65535 )); then
  err "Port must be between 1 and 65535"
  exit 1
fi

# Validate filename (no path traversal)
if [[ "${filename}" =~ \.\./|^/ ]]; then
  err "Invalid filename: ${filename}"
  exit 1
fi

# Validate alphanumeric with dashes
if ! [[ "${name}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  err "Name contains invalid characters"
  exit 1
fi
```

## Preventing Injection Attacks

### Command Injection Prevention

**Always quote variables** and use arrays for commands:

```bash
# Vulnerable to command injection
file="$1"
cat $file    # If file="test.txt; rm -rf /"

# Safe - variable is quoted
file="$1"
cat "${file}"

# Vulnerable - using eval
cmd="ls ${dir}"
eval "${cmd}"    # If dir="; rm -rf /"

# Safe - don't use eval, call command directly
ls "${dir}"
```

### SQL Injection Prevention

If your script interacts with databases:

```bash
# Bad - SQL injection vulnerability
username="$1"
mysql -e "SELECT * FROM users WHERE name='${username}'"

# Better - use parameterized queries via script
username="$1"
mysql -e "SELECT * FROM users WHERE name=?" <<< "${username}"

# Best - validate input first
username="$1"

if ! [[ "${username}" =~ ^[a-zA-Z0-9_]+$ ]]; then
  err "Invalid username format"
  exit 1
fi

mysql -e "SELECT * FROM users WHERE name='${username}'"
```

### Path Traversal Prevention

```bash
# Vulnerable
filename="$1"
cat "/data/${filename}"    # If filename="../../etc/passwd"

# Safe - validate no path traversal
filename="$1"

if [[ "${filename}" =~ \.\./|^/ ]]; then
  err "Path traversal not allowed"
  exit 1
fi

# Additional safety - resolve to real path and check prefix
realpath="$(realpath -m "/data/${filename}")"
if [[ ! "${realpath}" =~ ^/data/ ]]; then
  err "File must be in /data directory"
  exit 1
fi

cat "${realpath}"
```

## Secure File Operations

### Temporary File Creation

**Always use mktemp** for temporary files:

```bash
# Bad - predictable filename, race condition
tmpfile="/tmp/myscript.$$"
echo "data" > "${tmpfile}"

# Good - secure temporary file
tmpfile="$(mktemp)" || {
  err "Failed to create temporary file"
  exit 1
}

# Cleanup on exit
trap 'rm -f "${tmpfile}"' EXIT

# Use the temporary file
echo "data" > "${tmpfile}"
```

**Temporary directories**:
```bash
# Create secure temporary directory
tmpdir="$(mktemp -d)" || {
  err "Failed to create temporary directory"
  exit 1
}

# Cleanup on exit
trap 'rm -rf "${tmpdir}"' EXIT

# Use the directory
cp files/* "${tmpdir}/"
```

### File Permission Handling

Set restrictive permissions on sensitive files:

```bash
# Create file with restricted permissions
config_file="/etc/myapp/config"

# Create with secure permissions (owner read/write only)
(umask 077 && touch "${config_file}")

# Write sensitive data
echo "api_key=secret123" > "${config_file}"

# Verify permissions
chmod 600 "${config_file}"

# For directories with sensitive content
mkdir -p /var/lib/myapp
chmod 700 /var/lib/myapp
```

### Atomic File Operations

Use atomic operations to prevent race conditions:

```bash
# Bad - race condition between check and write
if [[ ! -f "${lockfile}" ]]; then
  echo $$ > "${lockfile}"    # Another process might create it first
fi

# Good - atomic creation
lockfile="/var/run/myapp.lock"

# Create lock file atomically
if ! (set -o noclobber; echo $$ > "${lockfile}") 2>/dev/null; then
  err "Another instance is already running"
  exit 1
fi

# Remove lock on exit
trap 'rm -f "${lockfile}"' EXIT

# Safe file update - write to temp, then move
config_file="/etc/myapp/config"
tmpfile="$(mktemp)"

# Write new content
generate_config > "${tmpfile}"

# Atomic move (rename is atomic on same filesystem)
mv -f "${tmpfile}" "${config_file}"
```

## Environment Security

### Clean Environment

Don't rely on environment variables for security:

```bash
# Bad - PATH manipulation can cause running wrong commands
find /data -name "*.txt"    # Could run malicious 'find'

# Good - use full paths for critical commands
/usr/bin/find /data -name "*.txt"

# Or at script start, set safe PATH
readonly PATH="/usr/local/bin:/usr/bin:/bin"
```

### Sensitive Data Handling

**Never hardcode secrets**:

```bash
# Bad - hardcoded password
password="secretpass123"
mysql -u root -p"${password}"

# Better - read from secure config file
readonly CONFIG_FILE="/etc/myapp/secrets.conf"

# Ensure config file has correct permissions
if [[ "$(stat -c %a "${CONFIG_FILE}")" != "600" ]]; then
  err "Config file has insecure permissions"
  exit 1
fi

# Source configuration
# shellcheck source=/dev/null
source "${CONFIG_FILE}"

# Use the password
mysql -u root -p"${DB_PASSWORD}"

# Best - use credential manager or environment
# Let the user set environment variable
: "${DB_PASSWORD:?Error: DB_PASSWORD environment variable must be set}"
mysql -u root -p"${DB_PASSWORD}"
```

**Clear sensitive data**:
```bash
# Read password
read -rsp "Enter password: " password
echo

# Use password
authenticate "${password}"

# Clear password from memory
password=""
```

### Secure Downloads

Verify downloads with checksums:

```bash
download_and_verify() {
  local url="$1"
  local expected_sha256="$2"
  local output_file="$3"
  
  # Download file
  if ! curl -fsSL "${url}" -o "${output_file}"; then
    err "Failed to download ${url}"
    return 1
  fi
  
  # Verify checksum
  local actual_sha256
  actual_sha256="$(sha256sum "${output_file}" | awk '{print $1}')"
  
  if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
    err "Checksum mismatch for ${output_file}"
    err "Expected: ${expected_sha256}"
    err "Got:      ${actual_sha256}"
    rm -f "${output_file}"
    return 1
  fi
  
  return 0
}

# Usage
if ! download_and_verify \
  "https://example.com/file.tar.gz" \
  "abc123..." \
  "file.tar.gz"; then
  exit 1
fi
```

## Input Validation Patterns

### Whitelist Validation

Prefer whitelist over blacklist:

```bash
# Bad - blacklist approach (easy to miss dangerous chars)
if [[ "${input}" =~ [\;\&\|] ]]; then
  err "Invalid characters"
  exit 1
fi

# Good - whitelist approach (only allow safe chars)
if ! [[ "${input}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  err "Input contains invalid characters"
  exit 1
fi
```

### Length Validation

Prevent buffer overflow and DoS:

```bash
# Check string length
max_length=255
if (( ${#input} > max_length )); then
  err "Input too long (max ${max_length} characters)"
  exit 1
fi

# Check array size
max_files=1000
if (( ${#files[@]} > max_files )); then
  err "Too many files (max ${max_files})"
  exit 1
fi
```

### Type Validation

Ensure data is expected type:

```bash
# Validate integer
if ! [[ "${count}" =~ ^[0-9]+$ ]]; then
  err "Count must be a positive integer"
  exit 1
fi

# Validate email format (basic)
if ! [[ "${email}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  err "Invalid email format"
  exit 1
fi

# Validate IP address (basic)
if ! [[ "${ip}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  err "Invalid IP address format"
  exit 1
fi

# Validate date format
if ! [[ "${date}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  err "Invalid date format (expected YYYY-MM-DD)"
  exit 1
fi
```

## Secure Defaults

### Principle of Least Privilege

Run with minimum required permissions:

```bash
# Check if running as root when not needed
if [[ "${EUID}" -eq 0 ]]; then
  err "This script should not be run as root"
  exit 1
fi

# Drop privileges after initialization
if [[ "${EUID}" -eq 0 ]]; then
  # Do privileged setup
  setup_as_root
  
  # Drop to regular user
  exec su - regularuser -c "$0 $*"
fi
```

### Fail Securely

Default to deny:

```bash
# Bad - defaults to allowing
allowed=true
if [[ "${user}" == "admin" ]]; then
  allowed=true
fi

# Good - defaults to denying
allowed=false
if [[ "${user}" == "admin" ]]; then
  allowed=true
fi

if [[ "${allowed}" != "true" ]]; then
  err "Access denied"
  exit 1
fi
```

## Logging Security Events

Log security-relevant events:

```bash
# Security event logging
security_log() {
  local event="$1"
  logger -t "$(basename "$0")" -p auth.warning "SECURITY: ${event}"
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] SECURITY: ${event}" >&2
}

# Log authentication attempts
authenticate_user() {
  local username="$1"
  
  if verify_credentials "${username}"; then
    security_log "Successful authentication for user: ${username}"
    return 0
  else
    security_log "Failed authentication attempt for user: ${username}"
    return 1
  fi
}

# Log file access
access_file() {
  local file="$1"
  
  if [[ ! -r "${file}" ]]; then
    security_log "Denied access to file: ${file}"
    return 1
  fi
  
  security_log "Granted access to file: ${file}"
  cat "${file}"
}
```

## Resource Limits

Prevent resource exhaustion:

```bash
# Limit script execution time
timeout 300 long_running_command || {
  err "Command timed out after 5 minutes"
  exit 1
}

# Limit disk usage
max_size=$((100 * 1024 * 1024))  # 100 MB
if (( $(stat -c%s "${file}") > max_size )); then
  err "File too large"
  exit 1
fi

# Limit memory usage with ulimit
ulimit -v $((512 * 1024))  # 512 MB virtual memory

# Limit number of processes
ulimit -u 50
```

## Common Vulnerabilities to Avoid

### 1. Avoid eval

```bash
# NEVER do this
user_input="$1"
eval "${user_input}"    # Arbitrary code execution!

# Use alternatives
case "${user_input}" in
  option1)
    do_option1
    ;;
  option2)
    do_option2
    ;;
  *)
    err "Invalid option"
    exit 1
    ;;
esac
```

### 2. Avoid Unquoted Variables

```bash
# Vulnerable to word splitting and globbing
file=$1
cat $file    # If file="test.txt ../../etc/passwd"

# Safe
file="$1"
cat "${file}"
```

### 3. Avoid Backticks

```bash
# Old style - harder to read and nest
result=`command`

# Modern style
result="$(command)"
```

### 4. Avoid Predictable Filenames

```bash
# Bad
tmpfile="/tmp/myscript_${USER}"

# Good
tmpfile="$(mktemp)"
```

## Security Checklist

Before deploying a shell script, verify:

- [ ] Uses `set -euo pipefail`
- [ ] No SUID/SGID bits set
- [ ] All user input is validated
- [ ] Variables are quoted
- [ ] No use of `eval`
- [ ] Temporary files use `mktemp`
- [ ] Sensitive files have restrictive permissions (600 or 700)
- [ ] No hardcoded secrets
- [ ] Commands use full paths or sanitized PATH
- [ ] Error messages don't leak sensitive information
- [ ] Security events are logged
- [ ] Resource limits are in place
- [ ] Runs with least privilege
- [ ] Fails securely (default deny)

## References

- [OWASP Command Injection](https://owasp.org/www-community/attacks/Command_Injection)
- [Bash Security](https://github.com/paragonie/awesome-appsec#bash)
- [ShellCheck](https://www.shellcheck.net/) - Automated security checks
