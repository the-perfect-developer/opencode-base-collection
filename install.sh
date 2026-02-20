#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/the-perfect-developer/opencode-base-collection"
TEMP_DIR="/tmp/opencode-base-collection-$$"

print_header() {
    echo -e "${BLUE}"
    cat << "EOF"
   ___                   ___          _
  / _ \ _ __   ___ _ __ / __\___   __| | ___
 | | | | '_ \ / _ \ '_ / /  / _ \ / _` |/ _ \
 | |_| | |_) |  __/ | | /__| (_) | (_| |  __/
  \___/| .__/ \___|_| \____/\___/ \__,_|\___|
       |_|

Base Skills Installer
EOF
    echo -e "${NC}"
}

cleanup() {
    [ -d "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
}

print_header

# Check requirements
if ! command -v curl &> /dev/null || ! command -v tar &> /dev/null; then
    echo -e "${RED}✗${NC} curl and tar are required"
    exit 1
fi

# Download and extract
echo -e "${BLUE}ℹ${NC} Downloading skills..."
mkdir -p "$TEMP_DIR"
trap cleanup EXIT

if ! curl -fsSL "${REPO_URL}/archive/refs/heads/main.tar.gz" | tar -xz -C "$TEMP_DIR"; then
    echo -e "${RED}✗${NC} Download failed"
    exit 1
fi

# Install to .opencode/skills
SKILLS_DIR=".opencode/skills"
mkdir -p "$SKILLS_DIR"

echo -e "${BLUE}ℹ${NC} Installing to ${SKILLS_DIR}..."

SOURCE_DIR="${TEMP_DIR}/opencode-base-collection-main/.opencode/skills"
if [ -d "$SOURCE_DIR" ]; then
    for skill in "${SOURCE_DIR}"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            rm -rf "${SKILLS_DIR}/${skill_name}"
            cp -r "$skill" "${SKILLS_DIR}/"
            echo -e "  ${GREEN}✓${NC} Installed: ${skill_name}"
        fi
    done
fi

# Install to .opencode/commands
COMMANDS_DIR=".opencode/commands"
mkdir -p "$COMMANDS_DIR"

COMMANDS_SOURCE_DIR="${TEMP_DIR}/opencode-base-collection-main/.opencode/commands"
if [ -d "$COMMANDS_SOURCE_DIR" ]; then
    echo -e "${BLUE}ℹ${NC} Installing commands to ${COMMANDS_DIR}..."
    for cmd in "${COMMANDS_SOURCE_DIR}"/*; do
        if [ -f "$cmd" ]; then
            cmd_name=$(basename "$cmd")
            cp "$cmd" "${COMMANDS_DIR}/"
            echo -e "  ${GREEN}✓${NC} Installed command: ${cmd_name}"
        fi
    done
fi

echo ""
echo -e "${BLUE}ℹ${NC} Installation complete!"
echo -e "  ${GREEN}✓${NC} Skills installed to: ${SKILLS_DIR}"
echo -e "  ${GREEN}✓${NC} Commands installed to: ${COMMANDS_DIR}"