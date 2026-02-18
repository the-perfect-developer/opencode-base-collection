#!/usr/bin/env bash

set -e

INSTALL_URL="https://raw.githubusercontent.com/the-perfect-developer/opencode-base-skills/main/install.sh"

curl -fsSL "$INSTALL_URL" | bash
