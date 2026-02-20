---
description: Update already-installed perfect tools to their latest versions
agent: build
model: github-copilot/claude-sonnet-4.5
---

You are helping the user update their already-installed OpenCode agents, skills, and commands to the latest versions from the catalog.

Follow these steps carefully and in order:

## Step 1: Read the Installation Guide

First, fetch and read the installation guide at:
https://raw.githubusercontent.com/the-perfect-developer/the-perfect-opencode/refs/heads/main/docs/installation-guide.md

This will tell you how installation works and where the catalog is located.

## Step 2: Fetch the Latest Catalog

Fetch the full catalog of available resources as mentioned in the installation guide. Parse and understand all available agents, skills, and commands along with their latest versions or content.

## Step 3: Discover Installed Tools

Check for existing installed resources in:
- `.opencode/agents/` — installed agents
- `.opencode/skills/` — installed skills
- `.opencode/commands/` — installed commands

List every file found. These are the tools eligible for updating.

## Step 4: Compare Installed Tools Against Catalog

For each installed tool, find its counterpart in the catalog and determine whether an update is available.

Present the user with a clear summary table:

| Tool | Type | Status |
|------|------|--------|
| example-agent | agent | Update available |
| example-skill | skill | Up to date |
| example-command | command | Update available |

If a tool is not found in the catalog, note it as "Unknown / not in catalog" and skip it.

## Step 5: Confirm With the User

Ask the user to confirm which tools they want to update. They may:
- Update all tools with available updates
- Select a subset to update
- Cancel the operation

## Step 6: Reinstall Selected Tools

For each confirmed tool, reinstall it using the install script from the guide. Use the same installation one-liner pattern:

```
bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh) agent:name1 skill:name2 command:name3 ...
```

**MUST** confirm above example command format with the installation guide you read in Step 1, and adjust if needed based on the actual instructions.

Show the user the exact command you will run, then execute it using the Bash tool.

## Step 7: Verify Updates

After the install script completes, verify the updated resources appear correctly in their respective directories:
- `.opencode/agents/`
- `.opencode/skills/`
- `.opencode/commands/`

Report back to the user with a summary of what was successfully updated.
