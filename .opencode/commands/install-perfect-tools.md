---
description: Discover and install perfect agents/skills/commands for your project
agent: build
---

User is asking to install $1.

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

### Core Commands (Always Install)

The following commands are considered core and should always be included in the installation unless already present:

- **`command:recommend-perfect-tool`** — Analyzes the current project automatically and recommends uninstalled agents/skills/commands without requiring user input. This is a companion to `install-perfect-tools` for ongoing maintenance.

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

Always include `command:recommend-perfect-tool` in the install command unless it is already installed.

Show the user the exact command you will run, then execute it using the Bash tool.

> **Note**: If the install script prompts whether to override an existing `opencode.json`, automatically answer **no** by piping `n` to stdin:
>
> ```bash
> echo "n" | bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh) agent:name1 skill:name2 command:name3 ...
> ```
>
> Never override the user's existing `opencode.json`.

## Step 7: Sync opencode.json with Remote

After the install script completes, verify whether the local `opencode.json` is in sync with the canonical remote version.

1. Fetch the remote config from:
   `https://raw.githubusercontent.com/the-perfect-developer/the-perfect-opencode/refs/heads/main/opencode.json`

2. Read the local `opencode.json` at the project root.

3. Compare the two files. For every difference, describe it in plain language:
   - **Model change**: `<agent>` — local uses `<old-model>`, remote recommends `<new-model>`
   - **Missing agent config**: `<agent>` — not present locally; remote recommends adding `{ model, temperature, color }`
   - **Note (no action)**: agent present locally but not in remote — leave it as-is

4. If the files are identical, inform the user: "Your `opencode.json` is already in sync with the remote — no changes needed."

5. If differences exist, present a clear summary and ask for confirmation:

   > Your `opencode.json` has the following differences from the remote canonical version:
   >
   > - [list each required change]
   >
   > Would you like me to apply these changes?

6. Once the user confirms, apply each change directly to `opencode.json` using file editing tools. Do not re-run the install script.

## Step 8: Verify Installation

After the install script completes, verify the installed resources appear in their respective directories:
- `.opencode/agents/`
- `.opencode/skills/`
- `.opencode/commands/`

Report back to the user with a summary of what was successfully installed and how to use each tool.
