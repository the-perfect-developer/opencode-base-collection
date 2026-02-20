#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Get the repository root directory (parent of scripts directory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

REPO_URL="https://github.com/the-perfect-developer/opencode-base-collection"
TEMP_DIR="/tmp/opencode-base-collection-$$"

# Arrays to store selected items
declare -a SELECTED_AGENTS
declare -a SELECTED_SKILLS
declare -a SELECTED_COMMANDS

# Parse command line arguments
INSTALL_ALL=true
for arg in "$@"; do
    case "$arg" in
        agent:*)
            INSTALL_ALL=false
            SELECTED_AGENTS+=("${arg#agent:}")
            ;;
        skill:*)
            INSTALL_ALL=false
            SELECTED_SKILLS+=("${arg#skill:}")
            ;;
        command:*)
            INSTALL_ALL=false
            SELECTED_COMMANDS+=("${arg#command:}")
            ;;
        *)
            echo -e "${YELLOW}Warning:${NC} Unknown argument format: $arg"
            echo "Use: agent:<name>, skill:<name>, or command:<name>"
            ;;
    esac
done

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
echo ""

# Show what will be installed
if [ "$INSTALL_ALL" = true ]; then
    echo -e "${BLUE}ℹ${NC} Installing all agents, skills, and commands"
else
    echo -e "${BLUE}ℹ${NC} Selective installation:"
    if [ ${#SELECTED_AGENTS[@]} -gt 0 ]; then
        echo -e "  Agents: ${SELECTED_AGENTS[*]}"
    fi
    if [ ${#SELECTED_SKILLS[@]} -gt 0 ]; then
        echo -e "  Skills: ${SELECTED_SKILLS[*]}"
    fi
    if [ ${#SELECTED_COMMANDS[@]} -gt 0 ]; then
        echo -e "  Commands: ${SELECTED_COMMANDS[*]}"
    fi
fi
echo ""

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

# Install to .opencode/agents
AGENTS_DIR="${REPO_ROOT}/.opencode/agents"
mkdir -p "$AGENTS_DIR"

AGENTS_SOURCE_DIR="${TEMP_DIR}/opencode-developer-collection-main/.opencode/agents"
if [ -d "$AGENTS_SOURCE_DIR" ]; then
    if [ "$INSTALL_ALL" = true ] || [ ${#SELECTED_AGENTS[@]} -gt 0 ]; then
        echo -e "${BLUE}ℹ${NC} Installing agents to ${AGENTS_DIR}..."
        for agent in "${AGENTS_SOURCE_DIR}"/*; do
            if [ -f "$agent" ]; then
                agent_name=$(basename "$agent" .md)
                
                # Check if we should install this agent
                if [ "$INSTALL_ALL" = true ]; then
                    cp "$agent" "${AGENTS_DIR}/"
                    echo -e "  ${GREEN}✓${NC} Installed agent: ${agent_name}"
                else
                    # Check if this agent is in the selected list
                    for selected in "${SELECTED_AGENTS[@]}"; do
                        if [ "$agent_name" = "$selected" ]; then
                            cp "$agent" "${AGENTS_DIR}/"
                            echo -e "  ${GREEN}✓${NC} Installed agent: ${agent_name}"
                            break
                        fi
                    done
                fi
            fi
        done
    fi
fi

# Install to .opencode/skills
SKILLS_DIR="${REPO_ROOT}/.opencode/skills"
mkdir -p "$SKILLS_DIR"

SOURCE_DIR="${TEMP_DIR}/opencode-base-collection-main/.opencode/skills"
if [ -d "$SOURCE_DIR" ]; then
    if [ "$INSTALL_ALL" = true ] || [ ${#SELECTED_SKILLS[@]} -gt 0 ]; then
        echo -e "${BLUE}ℹ${NC} Installing skills to ${SKILLS_DIR}..."
        for skill in "${SOURCE_DIR}"/*; do
            if [ -d "$skill" ]; then
                skill_name=$(basename "$skill")
                
                # Check if we should install this skill
                if [ "$INSTALL_ALL" = true ]; then
                    rm -rf "${SKILLS_DIR}/${skill_name}"
                    cp -r "$skill" "${SKILLS_DIR}/"
                    echo -e "  ${GREEN}✓${NC} Installed skill: ${skill_name}"
                else
                    # Check if this skill is in the selected list
                    for selected in "${SELECTED_SKILLS[@]}"; do
                        if [ "$skill_name" = "$selected" ]; then
                            rm -rf "${SKILLS_DIR}/${skill_name}"
                            cp -r "$skill" "${SKILLS_DIR}/"
                            echo -e "  ${GREEN}✓${NC} Installed skill: ${skill_name}"
                            break
                        fi
                    done
                fi
            fi
        done
    fi
fi

# Install to .opencode/commands
COMMANDS_DIR="${REPO_ROOT}/.opencode/commands"
mkdir -p "$COMMANDS_DIR"

COMMANDS_SOURCE_DIR="${TEMP_DIR}/opencode-base-collection-main/.opencode/commands"
if [ -d "$COMMANDS_SOURCE_DIR" ]; then
    if [ "$INSTALL_ALL" = true ] || [ ${#SELECTED_COMMANDS[@]} -gt 0 ]; then
        echo -e "${BLUE}ℹ${NC} Installing commands to ${COMMANDS_DIR}..."
        for cmd in "${COMMANDS_SOURCE_DIR}"/*; do
            if [ -f "$cmd" ]; then
                cmd_name=$(basename "$cmd" .md)
                
                # Check if we should install this command
                if [ "$INSTALL_ALL" = true ]; then
                    cp "$cmd" "${COMMANDS_DIR}/"
                    echo -e "  ${GREEN}✓${NC} Installed command: ${cmd_name}"
                else
                    # Check if this command is in the selected list
                    for selected in "${SELECTED_COMMANDS[@]}"; do
                        if [ "$cmd_name" = "$selected" ]; then
                            cp "$cmd" "${COMMANDS_DIR}/"
                            echo -e "  ${GREEN}✓${NC} Installed command: ${cmd_name}"
                            break
                        fi
                    done
                fi
            fi
        done
    fi
fi

echo ""
echo -e "${BLUE}ℹ${NC} Installation complete!"
if [ "$INSTALL_ALL" = true ] || [ ${#SELECTED_AGENTS[@]} -gt 0 ]; then
    echo -e "  ${GREEN}✓${NC} Agents installed to: ${AGENTS_DIR}"
fi
if [ "$INSTALL_ALL" = true ] || [ ${#SELECTED_SKILLS[@]} -gt 0 ]; then
    echo -e "  ${GREEN}✓${NC} Skills installed to: ${SKILLS_DIR}"
fi
if [ "$INSTALL_ALL" = true ] || [ ${#SELECTED_COMMANDS[@]} -gt 0 ]; then
    echo -e "  ${GREEN}✓${NC} Commands installed to: ${COMMANDS_DIR}"
fi