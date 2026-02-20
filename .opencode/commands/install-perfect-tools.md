---
description: Discover and install perfect agents/skills/commands for your project
agent: build
model: github-copilot/claude-sonnet-4.5
---

User is asking $1.

You are helping the user discover and install the perfect set of OpenCode agents, skills, and commands for their project.

Follow these steps carefully and in order:

## Step 1: Read the Installation Guide

First, fetch and read the installation guide at:
https://raw.githubusercontent.com/the-perfect-developer/the-perfect-opencode/refs/heads/main/docs/installation-guide.md

This will tell you how installation works and where the catalog is located.

## Step 2: Fetch the Available Catalog

Fetch the full catalog of available resources as mentioned in the installation guide. Parse and understand all available agents, skills, and commands.

## Step 3: Gather Project Context

Check if an AGENTS.md file exists at the project root and read it if present — it may contain existing configuration and project context.

Also check for existing installed resources in:
- `.opencode/agents/` — already installed agents
- `.opencode/skills/` — already installed skills
- `.opencode/commands/` — already installed commands

Note what's already installed to avoid recommending duplicates.

## Step 4: Ask the User for Their Scope and Needs

Ask the user the following questions (you may ask them all at once):

1. **Project Scope**: What kind of project is this? (e.g., web app, CLI tool, API service, data pipeline, mobile app, library, etc.)

2. **Tech Stack**: What languages, frameworks, or technologies are you using or planning to use? (e.g., TypeScript, Python, React, Go, Docker, etc.)

3. **Tool Categories**: Which categories of tools interest you? (Select all that apply)
   - Agents: specialized AI assistants (architect, frontend-engineer, backend-engineer, security-expert, etc.)
   - Skills: coding style guides and workflow instructions (TypeScript, Python, Git conventions, etc.)
   - Commands: slash commands for common workflows (git operations, code review, deployment, etc.)

4. **Work Style**: What kinds of tasks do you do most frequently? (e.g., code review, writing new features, fixing bugs, writing tests, deployment, documentation)

5. **Any specific tools or workflows** you already know you want?

## Step 5: Recommend a Curated Tool Set

Based on the user's answers and the catalog contents, recommend a curated set of tools. Present your recommendations clearly, grouped by type:

- **Agents** (list each with name and why it's useful for them)
- **Skills** (list each with name and why it's useful for them)
- **Commands** (list each with name and why it's useful for them)

Exclude anything already installed.

Ask the user to confirm the recommended set, or let them add/remove items before proceeding.

## Step 6: Construct and Run the Install Command

Once the user confirms, construct the installation one-liner using the pattern from the guide:

```
bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh) agent:name1 skill:name2 command:name3 ...
```

**MUST** please confirm above example command format with the installation guide you read in Step 1, and adjust if needed based on the actual instructions.

Show the user the exact command you will run, then execute it using the Bash tool.

## Step 7: Verify Installation

After the install script completes, verify the installed resources appear in their respective directories:
- `.opencode/agents/`
- `.opencode/skills/`
- `.opencode/commands/`

Report back to the user with a summary of what was successfully installed and how to use each tool.
