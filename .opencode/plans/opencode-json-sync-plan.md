# Plan: opencode-json-sync

## Overview

**Goal**: Update the three `install-perfect-tools`, `update-perfect-tools`, and `recommend-perfect-tool` command files to:

1. Safely handle the case where `opencode.json` already exists during install (pipe `n` automatically to avoid overriding).
2. After every install run, fetch the remote canonical `opencode.json`, compare it to the local copy, present the diff in human-readable form, get user confirmation, and apply the changes manually.

**Success Criteria**:
- All 3 command files have the new `opencode.json` protection + sync check steps.
- The step numbering is consistent and sequential within each file.
- No existing step logic is removed or broken.

---

## Files to Modify

| File | Current Steps | Changes |
|---|---|---|
| `.opencode/commands/install-perfect-tools.md` | Steps 1–7 | Pipe `n` in Step 6; add new Step 7 (sync); rename old Step 7 → Step 8 |
| `.opencode/commands/update-perfect-tools.md` | Steps 1–7 | Pipe `n` in Step 6; add new Step 7 (sync); rename old Step 7 → Step 8 |
| `.opencode/commands/recommend-perfect-tool.md` | Steps 1–8 | Pipe `n` in Step 7; add new Step 8 (sync); rename old Step 8 → Step 9 |

---

## Implementation Steps

### 1 — `install-perfect-tools.md`

**In Step 6**, change the execution instruction to pipe `n` automatically — add this note after the code block:

```
> **Note**: If the install script prompts whether to override an existing `opencode.json`, automatically answer **no** by piping `n` to stdin:
>
> ```bash
> echo "n" | bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh) agent:name1 skill:name2 ...
> ```
>
> Never override the user's existing `opencode.json`.
```

**Add new Step 7** (opencode.json Sync Check) — see canonical text below.

**Rename old Step 7 → Step 8** (Verify Installation).

---

### 2 — `update-perfect-tools.md`

Same changes applied to:

- **Step 6** (Reinstall Selected Tools) — add `echo "n" |` pipe note
- **New Step 7** — opencode.json sync check block
- **Old Step 7 → Step 8** (Verify Updates)

---

### 3 — `recommend-perfect-tool.md`

Same pattern, shifted by one:

- **Step 7** (Construct and Run the Install Command) — add `echo "n" |` pipe note
- **New Step 8** — opencode.json sync check block
- **Old Step 8 → Step 9** (Verify Installation)

---

## Canonical Text: opencode.json Sync Step

Insert this as the new step in all 3 files (adjust step number per file):

```markdown
## Step N: Sync opencode.json with Remote

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
```

---

## Canonical Text: echo "n" | Pipe Note

Add this block immediately after the install command code block in each file's "Construct and Run" step:

```markdown
> **Note**: If the install script prompts whether to override an existing `opencode.json`, automatically answer **no** by piping `n` to stdin:
>
> ```bash
> echo "n" | bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh) agent:name1 ...
> ```
>
> Never override the user's existing `opencode.json`.
```

---

## Dependencies

No new files or packages needed. Changes are purely to existing markdown command files.

---

## Verification After Implementation

- Read each file and confirm step numbers are sequential (no gaps).
- Confirm `echo "n" |` note appears in the install command section of all 3 files.
- Confirm the sync step appears before the final verify step in all 3 files.
- Confirm frontmatter (`---` delimiters, `agent`, `description`) is intact in all 3 files.
