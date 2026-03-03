---
description: Update already-installed perfect tools to their latest versions
agent: build
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

## Step 8: Verify Updates

After the install script completes, verify the updated resources appear correctly in their respective directories:
- `.opencode/agents/`
- `.opencode/skills/`
- `.opencode/commands/`

Report back to the user with a summary of what was successfully updated.
