---
description: Analyze current project and recommend uninstalled agents/skills/commands
agent: build
subtask: true
---

You are helping the user discover the perfect set of OpenCode agents, skills, and commands for their project — without asking unnecessary questions. Work autonomously by analyzing the project directly.

Follow these steps carefully and in order:

## Step 1: Read the Installation Guide

First, fetch and read the installation guide at:
https://raw.githubusercontent.com/the-perfect-developer/the-perfect-opencode/refs/heads/main/docs/installation-guide.md

This will tell you how installation works and where the full catalog is located.

## Step 2: Fetch the Available Catalog

Fetch the full catalog of available resources as mentioned in the installation guide. Parse and understand all available agents, skills, and commands.

## Step 3: Scan What Is Already Installed

Check the following directories and note every resource already present:
- `.opencode/agents/` — already installed agents
- `.opencode/skills/` — already installed skills
- `.opencode/commands/` — already installed commands

Also read `AGENTS.md` at the project root if it exists — it may contain additional context about the project setup.

## Step 4: Analyze the Project Automatically

Do NOT ask the user questions. Instead, infer the project context by examining:

- Root-level config files: `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `composer.json`, `Gemfile`, etc.
- Framework indicators: presence of `next.config.*`, `nuxt.config.*`, `vite.config.*`, `angular.json`, `svelte.config.*`, `fastapi`, `django`, `rails`, etc.
- Language files: `.ts`, `.py`, `.go`, `.rs`, `.java`, `.rb`, `.php` files in source directories
- CI/CD config: `.github/workflows/`, `Dockerfile`, `docker-compose.yml`, `.gitlab-ci.yml`
- Test infrastructure: `jest.config.*`, `pytest.ini`, `vitest.config.*`, `cypress/`, `playwright/`
- Code style config: `.eslintrc*`, `ruff.toml`, `.prettierrc*`, `biome.json`

Use shell commands to gather this context efficiently:
!`ls -1`
!`ls .opencode/agents/ 2>/dev/null && echo "---agents---" || echo "(none)"`
!`ls .opencode/skills/ 2>/dev/null && echo "---skills---" || echo "(none)"`
!`ls .opencode/commands/ 2>/dev/null && echo "---commands---" || echo "(none)"`
!`cat package.json 2>/dev/null | head -40 || cat pyproject.toml 2>/dev/null | head -40 || cat go.mod 2>/dev/null | head -20 || echo "(no standard project manifest found)"`
!`ls *.config.* 2>/dev/null; ls .github/workflows/ 2>/dev/null; ls Dockerfile docker-compose.yml 2>/dev/null; echo "done"`

## Step 5: Recommend a Curated Tool Set

Based on your analysis of the project and the catalog contents, recommend a curated set of tools that are NOT already installed. Present your recommendations clearly, grouped by type:

**Agents** — list each with:
- Name
- Why it matches this project's tech stack or workflow

**Skills** — list each with:
- Name
- Why it is relevant to the detected languages/frameworks/conventions

**Commands** — list each with:
- Name
- Why it fits the project's workflow

Exclude anything already installed. If a category has no new recommendations, say so.

Be specific: reference what you detected (e.g., "detected Next.js → recommending `nextjs-react` skill") so the user understands your reasoning.

## Step 6: Ask for Confirmation

After presenting recommendations, ask the user:

> Would you like me to install all of these, or would you like to add/remove any items first?

Wait for the user to confirm before proceeding.

## Step 7: Construct and Run the Install Command

Once the user confirms, construct the installation one-liner using the pattern from the guide:

```
bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh) agent:name1 skill:name2 command:name3 ...
```

**MUST** confirm the above command format with the installation guide you read in Step 1 and adjust if needed based on the actual instructions.

Show the user the exact command you will run, then execute it using the Bash tool.

> **Note**: If the install script prompts whether to override an existing `opencode.json`, automatically answer **no** by piping `n` to stdin:
>
> ```bash
> echo "n" | bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh) agent:name1 skill:name2 command:name3 ...
> ```
>
> Never override the user's existing `opencode.json`.

## Step 8: Sync opencode.json with Remote

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

## Step 9: Verify Installation

After the install script completes, verify the installed resources appear in their respective directories:
- `.opencode/agents/`
- `.opencode/skills/`
- `.opencode/commands/`

Report back to the user with a summary of what was successfully installed and how to use each tool.
