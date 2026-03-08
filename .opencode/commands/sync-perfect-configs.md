---
description: Sync local opencode.json with the canonical remote version
agent: build
---

Sync the local `opencode.json` with the canonical remote configuration.

## Step 1: Fetch the Remote Config

Fetch the remote canonical config from:
`https://raw.githubusercontent.com/the-perfect-developer/the-perfect-opencode/refs/heads/main/opencode.json`

## Step 2: Read the Local Config

Read the local `opencode.json` at the project root.

## Step 3: Compare

Compare the two files. For every difference, describe it in plain language:

- **Model change**: `<agent>` — local uses `<old-model>`, remote recommends `<new-model>`
- **Missing agent config**: `<agent>` — not present locally; remote recommends adding `{ model, temperature, color }`
- **Note (no action)**: agent present locally but not in remote — leave it as-is (do not remove)

## Step 4: Report and Confirm

If the files are identical, inform the user:

> Your `opencode.json` is already in sync with the remote — no changes needed.

If differences exist, present a clear summary and ask for confirmation:

> Your `opencode.json` has the following differences from the remote canonical version:
>
> - [list each required change]
>
> Would you like me to apply these changes?

## Step 5: Apply Changes

Once the user confirms, apply each change directly to `opencode.json` using file editing tools.

Do **not** run any install scripts. Only edit `opencode.json`.
