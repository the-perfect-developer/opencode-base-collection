#!/bin/bash
#
# Advanced script example demonstrating comprehensive error handling,
# logging, configuration management, and parallel processing.
#
# This script shows best practices for more complex shell scripts.
#
# Usage: advanced-script.sh [options] file1 [file2 ...]

set -euo pipefail

# Constants
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DEFAULT_CONFIG="/etc/myapp/config.sh"
readonly LOG_FILE="/var/log/myapp/process.log"
readonly MAX_PARALLEL_JOBS=4

# Global variables
declare -g CONFIG_FILE="${DEFAULT_CONFIG}"
declare -g VERBOSE=0
declare -g DRY_RUN=0
declare -g TEMP_DIR=""
declare -a INPUT_FILES=()

#######################################
# Cleanup function - removes temporary files
# Called automatically on exit via trap
#######################################
cleanup() {
  local exit_code=$?
  
  if [[ -n "${TEMP_DIR:-}" && -d "${TEMP_DIR}" ]]; then
    if (( VERBOSE )); then
      echo "Cleaning up temporary directory: ${TEMP_DIR}" >&2
    fi
    rm -rf "${TEMP_DIR}"
  fi
  
  exit "${exit_code}"
}

# Register cleanup function
trap cleanup EXIT INT TERM

#######################################
# Get current timestamp in ISO 8601 format
# Outputs:
#   Timestamp string
#######################################
timestamp() {
  date +'%Y-%m-%dT%H:%M:%S%z'
}

#######################################
# Print error message to stderr and log file
# Arguments:
#   Error message
#######################################
err() {
  local msg="[$(timestamp)] ERROR: $*"
  echo "${msg}" >&2
  
  if [[ -w "${LOG_FILE}" ]]; then
    echo "${msg}" >> "${LOG_FILE}"
  fi
}

#######################################
# Print warning message to stderr and log file
# Arguments:
#   Warning message
#######################################
warn() {
  local msg="[$(timestamp)] WARN: $*"
  echo "${msg}" >&2
  
  if [[ -w "${LOG_FILE}" ]]; then
    echo "${msg}" >> "${LOG_FILE}"
  fi
}

#######################################
# Print informational message if verbose mode enabled
# Globals:
#   VERBOSE
# Arguments:
#   Info message
#######################################
info() {
  if (( VERBOSE )); then
    local msg="[$(timestamp)] INFO: $*"
    echo "${msg}"
    
    if [[ -w "${LOG_FILE}" ]]; then
      echo "${msg}" >> "${LOG_FILE}"
    fi
  fi
}

#######################################
# Display usage information
#######################################
usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [options] file1 [file2 ...]

Advanced file processing script with parallel execution support.

Options:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output
  -n, --dry-run           Show what would be done without executing
  -c, --config FILE       Use alternative config file
  -j, --jobs NUM          Number of parallel jobs (default: ${MAX_PARALLEL_JOBS})

Configuration:
  Default config: ${DEFAULT_CONFIG}
  Log file: ${LOG_FILE}

Examples:
  ${SCRIPT_NAME} -v file1.txt file2.txt
  ${SCRIPT_NAME} -n --config myconfig.sh *.txt
  ${SCRIPT_NAME} -j 8 large_file1.txt large_file2.txt
EOF
}

#######################################
# Load and validate configuration file
# Globals:
#   CONFIG_FILE
# Returns:
#   0 on success, 1 on error
#######################################
load_config() {
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    warn "Config file not found: ${CONFIG_FILE}, using defaults"
    return 0
  fi
  
  if [[ ! -r "${CONFIG_FILE}" ]]; then
    err "Config file not readable: ${CONFIG_FILE}"
    return 1
  fi
  
  info "Loading configuration from ${CONFIG_FILE}"
  
  # Source configuration file
  # shellcheck source=/dev/null
  if ! source "${CONFIG_FILE}"; then
    err "Failed to load configuration file"
    return 1
  fi
  
  return 0
}

#######################################
# Validate a single input file
# Arguments:
#   Path to file
# Returns:
#   0 if valid, 1 if invalid
#######################################
validate_file() {
  local file="$1"
  
  # Check file exists
  if [[ ! -e "${file}" ]]; then
    err "File not found: ${file}"
    return 1
  fi
  
  # Check it's a regular file
  if [[ ! -f "${file}" ]]; then
    err "Not a regular file: ${file}"
    return 1
  fi
  
  # Check it's readable
  if [[ ! -r "${file}" ]]; then
    err "File not readable: ${file}"
    return 1
  fi
  
  # Check file is not empty
  if [[ ! -s "${file}" ]]; then
    warn "File is empty: ${file}"
  fi
  
  return 0
}

#######################################
# Process a single file
# Arguments:
#   Path to input file
# Returns:
#   0 on success, non-zero on error
#######################################
process_single_file() {
  local input_file="$1"
  local output_file
  local line_count
  local word_count
  
  info "Processing file: ${input_file}"
  
  # Generate output filename in temp directory
  output_file="${TEMP_DIR}/$(basename "${input_file}").result"
  
  if (( DRY_RUN )); then
    echo "Would process: ${input_file} -> ${output_file}"
    return 0
  fi
  
  # Example processing: count lines and words
  line_count="$(wc -l < "${input_file}")"
  word_count="$(wc -w < "${input_file}")"
  
  # Create output with statistics
  cat > "${output_file}" <<EOF
File: ${input_file}
Lines: ${line_count}
Words: ${word_count}
Processed: $(timestamp)

Content:
$(cat "${input_file}")
EOF
  
  if [[ ! -f "${output_file}" ]]; then
    err "Failed to create output file: ${output_file}"
    return 1
  fi
  
  info "Completed processing: ${input_file} (${line_count} lines, ${word_count} words)"
  
  return 0
}

#######################################
# Process all files in parallel
# Globals:
#   INPUT_FILES
#   MAX_PARALLEL_JOBS
# Returns:
#   0 on success, 1 if any file failed
#######################################
process_all_files() {
  local job_count=0
  local -a pids=()
  local failed=0
  local pid
  
  info "Processing ${#INPUT_FILES[@]} files with up to ${MAX_PARALLEL_JOBS} parallel jobs"
  
  # Start processing files
  for file in "${INPUT_FILES[@]}"; do
    # Wait if we've reached the job limit
    while (( job_count >= MAX_PARALLEL_JOBS )); do
      # Wait for any job to finish
      wait -n
      local exit_code=$?
      
      if (( exit_code != 0 )); then
        warn "A background job failed with exit code ${exit_code}"
        failed=1
      fi
      
      (( job_count-- ))
    done
    
    # Start processing this file in background
    process_single_file "${file}" &
    pids+=($!)
    (( job_count++ ))
  done
  
  # Wait for all remaining jobs
  for pid in "${pids[@]}"; do
    if ! wait "${pid}"; then
      warn "Job ${pid} failed"
      failed=1
    fi
  done
  
  if (( failed )); then
    err "One or more files failed to process"
    return 1
  fi
  
  info "All files processed successfully"
  return 0
}

#######################################
# Initialize script environment
# Returns:
#   0 on success, 1 on error
#######################################
initialize() {
  info "Initializing script"
  
  # Create temporary directory
  TEMP_DIR="$(mktemp -d -t "${SCRIPT_NAME}-XXXXXX")" || {
    err "Failed to create temporary directory"
    return 1
  }
  
  info "Created temporary directory: ${TEMP_DIR}"
  
  # Ensure log directory exists
  local log_dir
  log_dir="$(dirname "${LOG_FILE}")"
  
  if [[ ! -d "${log_dir}" ]]; then
    if ! mkdir -p "${log_dir}"; then
      warn "Could not create log directory: ${log_dir}"
    fi
  fi
  
  # Ensure log file is writable
  if [[ ! -w "${LOG_FILE}" ]]; then
    if ! touch "${LOG_FILE}" 2>/dev/null; then
      warn "Log file not writable: ${LOG_FILE}"
    fi
  fi
  
  return 0
}

#######################################
# Main function
# Arguments:
#   All command line arguments
# Returns:
#   0 on success, non-zero on error
#######################################
main() {
  local jobs="${MAX_PARALLEL_JOBS}"
  
  # Parse command line arguments
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
      -n|--dry-run)
        DRY_RUN=1
        echo "DRY RUN MODE - no files will be modified"
        shift
        ;;
      -c|--config)
        if [[ -z "${2:-}" ]]; then
          err "Option --config requires an argument"
          usage
          exit 1
        fi
        CONFIG_FILE="$2"
        shift 2
        ;;
      -j|--jobs)
        if [[ -z "${2:-}" ]]; then
          err "Option --jobs requires an argument"
          usage
          exit 1
        fi
        
        if ! [[ "$2" =~ ^[0-9]+$ ]]; then
          err "Jobs must be a positive integer"
          exit 1
        fi
        
        jobs="$2"
        shift 2
        ;;
      -*)
        err "Unknown option: $1"
        usage
        exit 1
        ;;
      *)
        INPUT_FILES+=("$1")
        shift
        ;;
    esac
  done
  
  # Check if any files were specified
  if (( ${#INPUT_FILES[@]} == 0 )); then
    err "No input files specified"
    usage
    exit 1
  fi
  
  # Update parallel jobs setting
  if (( jobs > 0 && jobs != MAX_PARALLEL_JOBS )); then
    readonly MAX_PARALLEL_JOBS="${jobs}"
    info "Using ${MAX_PARALLEL_JOBS} parallel jobs"
  fi
  
  # Initialize environment
  if ! initialize; then
    exit 1
  fi
  
  # Load configuration
  if ! load_config; then
    exit 1
  fi
  
  # Validate all input files
  info "Validating ${#INPUT_FILES[@]} input files"
  local file
  for file in "${INPUT_FILES[@]}"; do
    if ! validate_file "${file}"; then
      exit 1
    fi
  done
  
  # Process all files
  if ! process_all_files; then
    err "Processing failed"
    exit 1
  fi
  
  echo "Successfully processed ${#INPUT_FILES[@]} files"
  echo "Results are in: ${TEMP_DIR}"
  
  return 0
}

# Execute main function with all arguments
main "$@"
