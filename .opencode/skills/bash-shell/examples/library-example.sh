#!/bin/bash
#
# Example reusable function library following Google Shell Style Guide.
#
# This file contains common utility functions that can be sourced
# by other scripts. It should not be executed directly.
#
# Usage: source library-example.sh

# Prevent direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This is a library file and should not be executed directly." >&2
  echo "Usage: source ${BASH_SOURCE[0]}" >&2
  exit 1
fi

# Library version
readonly LIBRARY_VERSION="1.0.0"

#######################################
# Check if a command exists in PATH
# Arguments:
#   Command name
# Returns:
#   0 if command exists, 1 otherwise
#######################################
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

#######################################
# Print error message to stderr with timestamp
# Arguments:
#   Error message
#######################################
lib::err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] ERROR: $*" >&2
}

#######################################
# Print warning message to stderr with timestamp
# Arguments:
#   Warning message
#######################################
lib::warn() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] WARN: $*" >&2
}

#######################################
# Print info message with timestamp
# Arguments:
#   Info message
#######################################
lib::info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] INFO: $*"
}

#######################################
# Check if script is running as root
# Returns:
#   0 if root, 1 otherwise
#######################################
lib::is_root() {
  [[ "${EUID}" -eq 0 ]]
}

#######################################
# Require root privileges or exit
# Outputs:
#   Error message if not root
#######################################
lib::require_root() {
  if ! lib::is_root; then
    lib::err "This script must be run as root"
    exit 1
  fi
}

#######################################
# Check if running on specific OS
# Arguments:
#   OS name (linux, darwin, etc.)
# Returns:
#   0 if match, 1 otherwise
#######################################
lib::is_os() {
  local expected_os="$1"
  local current_os
  
  current_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  
  [[ "${current_os}" == "${expected_os}" ]]
}

#######################################
# Retry a command with exponential backoff
# Arguments:
#   Max attempts (optional, default: 3)
#   Command and its arguments
# Returns:
#   Exit code of command on success, 1 on failure
#######################################
lib::retry() {
  local max_attempts=3
  local attempt=1
  local delay=1
  
  # If first argument is a number, use it as max_attempts
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    max_attempts="$1"
    shift
  fi
  
  while (( attempt <= max_attempts )); do
    if "$@"; then
      return 0
    fi
    
    if (( attempt < max_attempts )); then
      lib::warn "Command failed (attempt ${attempt}/${max_attempts}), retrying in ${delay}s..."
      sleep "${delay}"
      (( delay *= 2 ))  # Exponential backoff
    fi
    
    (( attempt++ ))
  done
  
  lib::err "Command failed after ${max_attempts} attempts"
  return 1
}

#######################################
# Validate email address format
# Arguments:
#   Email address
# Returns:
#   0 if valid format, 1 otherwise
#######################################
lib::validate_email() {
  local email="$1"
  
  [[ "${email}" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

#######################################
# Validate IP address format
# Arguments:
#   IP address
# Returns:
#   0 if valid format, 1 otherwise
#######################################
lib::validate_ip() {
  local ip="$1"
  local -a octets
  
  # Check basic format
  if ! [[ "${ip}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    return 1
  fi
  
  # Check each octet is 0-255
  IFS='.' read -ra octets <<< "${ip}"
  local octet
  for octet in "${octets[@]}"; do
    if (( octet > 255 )); then
      return 1
    fi
  done
  
  return 0
}

#######################################
# Validate URL format
# Arguments:
#   URL
# Returns:
#   0 if valid format, 1 otherwise
#######################################
lib::validate_url() {
  local url="$1"
  
  [[ "${url}" =~ ^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$ ]]
}

#######################################
# Create a backup of a file
# Arguments:
#   File path
# Outputs:
#   Path to backup file
# Returns:
#   0 on success, 1 on error
#######################################
lib::backup_file() {
  local file="$1"
  local backup_file
  
  if [[ ! -f "${file}" ]]; then
    lib::err "File not found: ${file}"
    return 1
  fi
  
  backup_file="${file}.backup.$(date +%Y%m%d_%H%M%S)"
  
  if ! cp "${file}" "${backup_file}"; then
    lib::err "Failed to create backup: ${backup_file}"
    return 1
  fi
  
  echo "${backup_file}"
  return 0
}

#######################################
# Download a file with verification
# Arguments:
#   URL
#   Output file path
#   Expected SHA256 checksum (optional)
# Returns:
#   0 on success, 1 on error
#######################################
lib::download_file() {
  local url="$1"
  local output_file="$2"
  local expected_checksum="${3:-}"
  
  if ! command_exists curl; then
    lib::err "curl is not installed"
    return 1
  fi
  
  if ! lib::validate_url "${url}"; then
    lib::err "Invalid URL: ${url}"
    return 1
  fi
  
  lib::info "Downloading ${url} to ${output_file}"
  
  if ! curl -fsSL "${url}" -o "${output_file}"; then
    lib::err "Failed to download ${url}"
    return 1
  fi
  
  # Verify checksum if provided
  if [[ -n "${expected_checksum}" ]]; then
    if ! command_exists sha256sum; then
      lib::warn "sha256sum not available, skipping checksum verification"
      return 0
    fi
    
    local actual_checksum
    actual_checksum="$(sha256sum "${output_file}" | awk '{print $1}')"
    
    if [[ "${actual_checksum}" != "${expected_checksum}" ]]; then
      lib::err "Checksum verification failed"
      lib::err "Expected: ${expected_checksum}"
      lib::err "Got:      ${actual_checksum}"
      rm -f "${output_file}"
      return 1
    fi
    
    lib::info "Checksum verified successfully"
  fi
  
  return 0
}

#######################################
# Get a random string
# Arguments:
#   Length (default: 16)
# Outputs:
#   Random alphanumeric string
#######################################
lib::random_string() {
  local length="${1:-16}"
  
  # Use /dev/urandom for randomness
  LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "${length}"
}

#######################################
# Join array elements with a delimiter
# Arguments:
#   Delimiter
#   Array elements (remaining arguments)
# Outputs:
#   Joined string
#######################################
lib::join() {
  local delimiter="$1"
  shift
  
  local first=1
  local item
  
  for item in "$@"; do
    if (( first )); then
      printf '%s' "${item}"
      first=0
    else
      printf '%s%s' "${delimiter}" "${item}"
    fi
  done
}

#######################################
# Check if array contains element
# Arguments:
#   Element to find
#   Array elements (remaining arguments)
# Returns:
#   0 if found, 1 if not found
#######################################
lib::array_contains() {
  local needle="$1"
  shift
  
  local item
  for item in "$@"; do
    if [[ "${item}" == "${needle}" ]]; then
      return 0
    fi
  done
  
  return 1
}

#######################################
# Get file extension
# Arguments:
#   Filename
# Outputs:
#   File extension without dot
#######################################
lib::get_extension() {
  local filename="$1"
  local extension
  
  extension="${filename##*.}"
  
  # Return empty if no extension
  if [[ "${extension}" == "${filename}" ]]; then
    return 1
  fi
  
  echo "${extension}"
}

#######################################
# Get filename without extension
# Arguments:
#   Filename
# Outputs:
#   Filename without extension
#######################################
lib::get_basename() {
  local filename="$1"
  
  echo "${filename%.*}"
}

#######################################
# Convert string to lowercase
# Arguments:
#   String
# Outputs:
#   Lowercase string
#######################################
lib::to_lower() {
  echo "${1,,}"
}

#######################################
# Convert string to uppercase
# Arguments:
#   String
# Outputs:
#   Uppercase string
#######################################
lib::to_upper() {
  echo "${1^^}"
}

#######################################
# Trim whitespace from string
# Arguments:
#   String
# Outputs:
#   Trimmed string
#######################################
lib::trim() {
  local str="$1"
  
  # Remove leading whitespace
  str="${str#"${str%%[![:space:]]*}"}"
  
  # Remove trailing whitespace
  str="${str%"${str##*[![:space:]]}"}"
  
  echo "${str}"
}

#######################################
# Ask user for yes/no confirmation
# Arguments:
#   Prompt message
#   Default answer (y or n, optional)
# Returns:
#   0 for yes, 1 for no
#######################################
lib::confirm() {
  local prompt="$1"
  local default="${2:-}"
  local response
  
  # Build prompt
  if [[ "${default}" == "y" ]]; then
    prompt="${prompt} [Y/n] "
  elif [[ "${default}" == "n" ]]; then
    prompt="${prompt} [y/N] "
  else
    prompt="${prompt} [y/n] "
  fi
  
  # Read response
  read -rp "${prompt}" response
  
  # Use default if no response
  if [[ -z "${response}" && -n "${default}" ]]; then
    response="${default}"
  fi
  
  # Check response
  case "${response}" in
    [Yy]|[Yy][Ee][Ss])
      return 0
      ;;
    [Nn]|[Nn][Oo])
      return 1
      ;;
    *)
      lib::err "Please answer yes or no"
      lib::confirm "$1" "${default}"
      ;;
  esac
}

# Export functions for use in subshells (optional)
# Uncomment if needed
# export -f command_exists
# export -f lib::err
# ... (export other functions as needed)
