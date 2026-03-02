---
name: claude-agent-sdk
description: This skill should be used when the user asks to "build an AI agent with Claude", "use the Claude Agent SDK", "integrate claude-agent-sdk into a project", "set up an autonomous agent with tools", or needs guidance on the Anthropic Claude Agent SDK best practices for Python and TypeScript.
---

# Claude Agent SDK

Provides patterns and best practices for building production AI agents using the Claude Agent SDK (Python: `claude-agent-sdk`, TypeScript: `@anthropic-ai/claude-agent-sdk`).

## Installation

```bash
# TypeScript
npm install @anthropic-ai/claude-agent-sdk

# Python (uv — recommended)
uv add claude-agent-sdk

# Python (pip)
pip install claude-agent-sdk
```

Set the API key before running any agent:

```bash
export ANTHROPIC_API_KEY=your-api-key
```

Third-party providers are also supported: set `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, or `CLAUDE_CODE_USE_FOUNDRY=1` alongside the respective cloud credentials.

## Core Pattern: The `query()` Function

Every agent is built around `query()`, which returns an async iterator of streamed messages:

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="Find and fix the bug in auth.py",
        options=ClaudeAgentOptions(
            allowed_tools=["Read", "Edit", "Glob"],
            permission_mode="acceptEdits",
        ),
    ):
        if hasattr(message, "result"):
            print(message.result)

asyncio.run(main())
```

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.py",
  options: { allowedTools: ["Read", "Edit", "Glob"], permissionMode: "acceptEdits" }
})) {
  if ("result" in message) console.log(message.result);
}
```

The loop ends when Claude finishes or hits an error. The SDK handles tool execution, context management, and retries internally.

## Built-in Tools

Grant only the tools the agent actually needs — principle of least privilege:

| Tool | Purpose |
|------|---------|
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions |
| `Task` | Spawn subagents (required when using subagents) |

### Recommended tool sets by use case

| Use case | Tools |
|----------|-------|
| Read-only analysis | `Read`, `Glob`, `Grep` |
| Code modification | `Read`, `Edit`, `Write`, `Glob`, `Grep` |
| Full automation | `Read`, `Edit`, `Write`, `Bash`, `Glob`, `Grep` |
| Web-augmented | Add `WebSearch`, `WebFetch` to any set |
| Subagent orchestration | Add `Task` to the parent agent's set |

## Permission Modes

Set `permissionMode` / `permission_mode` in options:

| Mode | Behavior | Best for |
|------|----------|----------|
| `default` | Delegates unresolved requests to `canUseTool` callback | Custom approval flows |
| `acceptEdits` | Auto-approves file edits and filesystem ops | Trusted dev workflows |
| `bypassPermissions` | Runs all tools without prompts | CI/CD pipelines |
| `plan` | No tool execution — planning only | Pre-review before changes |

**Best practice**: use `acceptEdits` for interactive development; use `bypassPermissions` only in isolated, sandboxed environments. Never use `bypassPermissions` in multi-tenant or user-facing applications.

Permission mode changes mid-session are supported — start restrictive, loosen after reviewing Claude's plan:

```python
q = query(prompt="Refactor auth module", options=ClaudeAgentOptions(permission_mode="plan"))
await q.set_permission_mode("acceptEdits")  # Switch after plan is approved
async for message in q:
    ...
```

### Permission evaluation order

1. **Hooks** — run first; can allow, deny, or pass through
2. **Permission rules** — declarative allow/deny in `settings.json`
3. **Permission mode** — global fallback setting
4. **`canUseTool` callback** — runtime user approval (when mode is `default`)

## Session Management

### Capture session ID

```python
session_id = None
async for message in query(prompt="Analyze auth module", options=ClaudeAgentOptions(...)):
    if hasattr(message, "subtype") and message.subtype == "init":
        session_id = message.data.get("session_id")
```

```typescript
let sessionId: string | undefined;
for await (const message of query({ prompt: "Analyze auth module", options: { ... } })) {
  if (message.type === "system" && message.subtype === "init") {
    sessionId = message.session_id;
  }
}
```

### Resume a session

Pass `resume` / `resume` in options to continue with full prior context:

```python
async for message in query(
    prompt="Now find all callers of that function",
    options=ClaudeAgentOptions(resume=session_id),
):
    ...
```

### Fork a session

Set `fork_session=True` / `forkSession: true` to branch without modifying the original:

```python
# Explore a different approach without losing the original session
async for message in query(
    prompt="Redesign this as GraphQL instead",
    options=ClaudeAgentOptions(resume=session_id, fork_session=True),
):
    ...
```

Forking preserves the original session; both branches can be resumed independently.

## MCP Integration

Connect external services through the Model Context Protocol:

```python
options = ClaudeAgentOptions(
    mcp_servers={
        "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
    }
)
```

MCP tool names follow the pattern `mcp__{server_name}__{tool_name}`. List them explicitly in `allowed_tools` to restrict access:

```python
allowed_tools=["mcp__playwright__browser_click", "mcp__playwright__browser_screenshot"]
```

## Message Handling

Filter the stream for meaningful output. Raw messages include system init and internal state:

```python
from claude_agent_sdk import AssistantMessage, ResultMessage

async for message in query(...):
    if isinstance(message, AssistantMessage):
        for block in message.content:
            if hasattr(block, "text"):
                print(block.text)          # Claude's reasoning
            elif hasattr(block, "name"):
                print(f"Tool: {block.name}")   # Tool being called
    elif isinstance(message, ResultMessage):
        print(f"Result: {message.subtype}")   # "success" or "error"
```

```typescript
for await (const message of query({ ... })) {
  if (message.type === "assistant") {
    for (const block of message.message.content) {
      if ("text" in block) console.log(block.text);
      else if ("name" in block) console.log(`Tool: ${block.name}`);
    }
  } else if (message.type === "result") {
    console.log(`Result: ${message.subtype}`);
  }
}
```

## System Prompts

Provide a `system_prompt` / `systemPrompt` to give Claude a persona or project-specific context:

```python
options = ClaudeAgentOptions(
    system_prompt="You are a senior Python developer. Always follow PEP 8. Prefer explicit error handling over bare excepts.",
    allowed_tools=["Read", "Edit", "Glob"],
    permission_mode="acceptEdits",
)
```

Keep system prompts concise and focused on constraints the LLM doesn't already know.

## Best Practices

### Tool selection
- Grant only the tools the task requires — no `Bash` for read-only analysis
- Verify tool set is sufficient before launching; a missing tool causes the agent to stall
- Include `Task` in the parent's `allowed_tools` when defining subagents

### Prompts
- Write prompts as specific task instructions, not open-ended descriptions
- Name files explicitly when they are the target (`"Review auth.py"` vs `"Review some code"`)
- Use explicit subagent invocation when precision matters: `"Use the code-reviewer agent to..."`)

### Error handling
- Always handle `ResultMessage` with `subtype == "error"` — never assume success
- Catch exceptions around the `async for` loop, not inside it
- Avoid bare `except` in hook callbacks; a swallowed exception can silently halt the agent

### Security
- Never use `bypassPermissions` in production systems with user-supplied prompts
- Use `PreToolUse` hooks to block access to sensitive paths (`.env`, `/etc`, secrets)
- Restrict subagent tools — subagents do **not** inherit parent permissions automatically

### Sessions
- Store session IDs persistently if the workflow spans multiple process runs
- Fork sessions when exploring alternative approaches to avoid losing a good baseline
- Subagent transcripts persist separately; clean up via `cleanupPeriodDays` setting

### Performance
- Prefer streaming (`async for`) over collecting all messages; it shows progress and allows early exit
- Use subagents to parallelise independent tasks (security scan + style check simultaneously)
- Use `plan` mode first for expensive or irreversible operations — review before executing

## Additional Resources

- **`references/hooks.md`** — Lifecycle hooks: blocking tools, modifying inputs, audit logging
- **`references/subagents.md`** — Defining, invoking, and resuming subagents; parallelisation patterns
- **`references/custom-tools.md`** — Building in-process MCP tools with `createSdkMcpServer`
