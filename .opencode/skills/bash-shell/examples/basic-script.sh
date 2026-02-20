#!/bin/bash
#
# Example of a basic utility script following Google Shell Style Guide.
#
# This script demonstrates proper structure for a simple utility that
# processes files and follows all style guidelines.
#
# Usage: basic-script.sh [options] input_file

set -euo pipefail

# Constants
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly DEFAULT_OUTPUT_DIR="/tmp"

# Global variables
declare -g OUTPUT_DIR="${DEFAULT_OUTPUT_DIR}"
declare -g VERBOSE=0

#######################################
# Print error message to stderr with timestamp
# Arguments:
#   Error message to print
#######################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

#######################################
# Print informational message if verbose mode is enabled
# Globals:
#   VERBOSE
# Arguments:
#   Message to print
#######################################
info() {
  if (( VERBOSE )); then
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*"
  fi
}

#######################################
# Display usage information
#######################################
usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [options] input_file

Process a file and generate output.

Options:
  -h, --help              Show this help message
  -v, --verbose           Enable verbose output
  -o, --output-dir DIR    Set output directory (default: ${DEFAULT_OUTPUT_DIR})

Examples:
  ${SCRIPT_NAME} data.txt
  ${SCRIPT_NAME} -v -o /var/output data.txt
EOF
}

#######################################
# Validate input file exists and is readable
# Arguments:
#   Path to input file
# Returns:
#   0 if valid, 1 if invalid
#######################################
validate_input_file() {
  local input_file="$1"
  
  if [[ ! -f "${input_file}" ]]; then
    err "Input file not found: ${input_file}"
    return 1
  fi
  
  if [[ ! -r "${input_file}" ]]; then
    err "Input file not readable: ${input_file}"
    return 1
  fi
  
  return 0
}

#######################################
# Process the input file
# Arguments:
#   Path to input file
# Outputs:
#   Writes processed file to OUTPUT_DIR
# Returns:
#   0 on success, non-zero on error
#######################################
process_file() {
  local input_file="$1"
  local output_file
  local line_count
  
  # Generate output filename
  output_file="${OUTPUT_DIR}/$(basename "${input_file}").processed"
  
  info "Processing ${input_file}"
  info "Output will be written to ${output_file}"
  
  # Create output directory if it doesn't exist
  if [[ ! -d "${OUTPUT_DIR}" ]]; then
    mkdir -p "${OUTPUT_DIR}" || {
      err "Failed to create output directory: ${OUTPUT_DIR}"
      return 1
    }
  fi
  
  # Process file - convert to uppercase as example
  if ! tr '[:lower:]' '[:upper:]' < "${input_file}" > "${output_file}"; then
    err "Failed to process file"
    return 1
  fi
  
  # Count lines
  line_count="$(wc -l < "${output_file}")"
  
  info "Processed ${line_count} lines"
  echo "Output written to: ${output_file}"
  
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
  local input_file=""
  
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
      -o|--output-dir)
        if [[ -z "${2:-}" ]]; then
          err "Option --output-dir requires an argument"
          usage
          exit 1
        fi
        OUTPUT_DIR="$2"
        shift 2
        ;;
      -*)
        err "Unknown option: $1"
        usage
        exit 1
        ;;
      *)
        if [[ -n "${input_file}" ]]; then
          err "Multiple input files not supported"
          usage
          exit 1
        fi
        input_file="$1"
        shift
        ;;
    esac
  done
  
  # Check if input file was provided
  if [[ -z "${input_file}" ]]; then
    err "No input file specified"
    usage
    exit 1
  fi
  
  # Validate input file
  if ! validate_input_file "${input_file}"; then
    exit 1
  fi
  
  # Process the file
  if ! process_file "${input_file}"; then
    exit 1
  fi
  
  info "Processing complete"
  return 0
}

# Execute main function with all arguments
main "$@"
