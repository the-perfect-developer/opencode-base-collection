# Hooks Reference — Claude Agent SDK

Hooks are callback functions that intercept agent events to validate, log, block, or transform behavior.

## Table of Contents

- [How Hooks Work](#how-hooks-work)
- [Available Hook Events](#available-hook-events)
- [Configuration](#configuration)
- [Matchers](#matchers)
- [Callback Inputs and Outputs](#callback-inputs-and-outputs)
- [Common Patterns](#common-patterns)
- [Async Hooks](#async-hooks)
- [Troubleshooting](#troubleshooting)

## How Hooks Work

1. An event fires (e.g., a tool is about to run)
2. The SDK collects hooks registered for that event type
3. Matchers filter which hooks run based on a regex against the tool name
4. Each callback executes and receives event details
5. The callback returns a decision (allow / deny / modify)

**Priority rule**: `deny` beats `ask`, which beats `allow`. If any hook returns `deny`, the operation is blocked regardless of other hooks.

## Available Hook Events

| Hook | Python | TypeScript | Trigger |
|------|--------|------------|---------|
| `PreToolUse` | Yes | Yes | Before a tool call — can block or modify |
| `PostToolUse` | Yes | Yes | After a tool result |
| `PostToolUseFailure` | Yes | Yes | After a tool error |
| `UserPromptSubmit` | Yes | Yes | When the user sends a prompt |
| `Stop` | Yes | Yes | When execution stops |
| `SubagentStart` | Yes | Yes | When a subagent initialises |
| `SubagentStop` | Yes | Yes | When a subagent completes |
| `PreCompact` | Yes | Yes | Before conversation compaction |
| `PermissionRequest` | Yes | Yes | When a permission dialog would appear |
| `Notification` | Yes | Yes | Agent status messages |
| `SessionStart` | No | Yes | Session initialisation |
| `SessionEnd` | No | Yes | Session teardown |

## Configuration

```python
from claude_agent_sdk import ClaudeAgentOptions, HookMatcher

options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [HookMatcher(matcher="Write|Edit", hooks=[my_callback])],
        "PostToolUse": [HookMatcher(hooks=[audit_logger])],
    }
)
```

```typescript
const options = {
  hooks: {
    PreToolUse: [{ matcher: "Write|Edit", hooks: [myCallback] }],
    PostToolUse: [{ hooks: [auditLogger] }],
  }
};
```

The `hooks` key is a map of event name → array of matchers. Each matcher has:

| Field | Type | Description |
|-------|------|-------------|
| `matcher` | `string` (regex) | Matches against the tool name. Omit to match all. |
| `hooks` | `HookCallback[]` | One or more callback functions |
| `timeout` | `number` | Timeout in seconds (default: 60) |

## Matchers

Matchers are regex patterns applied to the **tool name**, not to arguments or file paths:

```
"Write|Edit"      → matches Write or Edit tools
"^mcp__"          → matches all MCP tools
"Bash"            → matches only Bash
                  → (omitted) matches every occurrence
```

To filter by file path, check `tool_input` inside the callback:

```python
async def only_python_files(input_data, tool_use_id, context):
    file_path = input_data["tool_input"].get("file_path", "")
    if not file_path.endswith(".py"):
        return {}  # allow non-.py files through
    # handle .py files
    return {}
```

## Callback Inputs and Outputs

### Inputs

Every callback receives three arguments:

1. **Input data** — event-specific dict with common fields: `session_id`, `cwd`, `hook_event_name`, `tool_name`, `tool_input`
2. **Tool use ID** — correlates `PreToolUse` and `PostToolUse` for the same call
3. **Context** — TypeScript: `{ signal: AbortSignal }`; Python: reserved

### Outputs

Return `{}` to allow the operation unchanged. To control the operation:

```python
# Block a tool
return {
    "hookSpecificOutput": {
        "hookEventName": input_data["hook_event_name"],
        "permissionDecision": "deny",
        "permissionDecisionReason": "Reason shown to the agent",
    }
}

# Modify input (must also include permissionDecision: "allow")
return {
    "hookSpecificOutput": {
        "hookEventName": input_data["hook_event_name"],
        "permissionDecision": "allow",
        "updatedInput": {**input_data["tool_input"], "file_path": "/sandbox" + path},
    }
}

# Inject context into the conversation (top-level field)
return {
    "systemMessage": "Remember: /etc is a protected system directory.",
    "hookSpecificOutput": {
        "hookEventName": input_data["hook_event_name"],
        "permissionDecision": "deny",
        "permissionDecisionReason": "Writing to /etc is not allowed",
    },
}
```

`PostToolUse` hooks support `additionalContext` to append information to the tool result:

```python
return {
    "hookSpecificOutput": {
        "hookEventName": "PostToolUse",
        "additionalContext": "File written to audit log.",
    }
}
```

## Common Patterns

### Block dangerous operations

```python
async def protect_sensitive_paths(input_data, tool_use_id, context):
    file_path = input_data["tool_input"].get("file_path", "")
    if file_path.endswith(".env") or file_path.startswith("/etc"):
        return {
            "hookSpecificOutput": {
                "hookEventName": input_data["hook_event_name"],
                "permissionDecision": "deny",
                "permissionDecisionReason": f"Access denied: {file_path} is protected",
            }
        }
    return {}
```

### Redirect writes to a sandbox

```python
async def redirect_to_sandbox(input_data, tool_use_id, context):
    if input_data["tool_name"] == "Write":
        original = input_data["tool_input"].get("file_path", "")
        return {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
                "updatedInput": {**input_data["tool_input"], "file_path": f"/sandbox{original}"},
            }
        }
    return {}
```

### Audit log every file change

```python
from datetime import datetime

async def audit_file_changes(input_data, tool_use_id, context):
    if input_data["hook_event_name"] != "PostToolUse":
        return {}
    file_path = input_data["tool_input"].get("file_path", "")
    with open("audit.log", "a") as f:
        f.write(f"{datetime.now().isoformat()}: {input_data['tool_name']} → {file_path}\n")
    return {}
```

### Auto-approve read-only tools

```python
READ_ONLY = {"Read", "Glob", "Grep"}

async def auto_approve_reads(input_data, tool_use_id, context):
    if input_data["tool_name"] in READ_ONLY:
        return {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
            }
        }
    return {}
```

### Chain hooks with single responsibilities

```python
options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [
            HookMatcher(hooks=[rate_limiter]),         # 1. rate limiting
            HookMatcher(hooks=[authorization_check]),  # 2. authz
            HookMatcher(hooks=[input_sanitizer]),      # 3. sanitization
            HookMatcher(hooks=[audit_logger]),         # 4. logging
        ]
    }
)
```

### Forward notifications to Slack

```python
import asyncio, json, urllib.request

async def slack_notifier(input_data, tool_use_id, context):
    msg = input_data.get("message", "")
    try:
        data = json.dumps({"text": f"Agent: {msg}"}).encode()
        req = urllib.request.Request(
            "https://hooks.slack.com/services/YOUR/WEBHOOK",
            data=data,
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        await asyncio.to_thread(urllib.request.urlopen, req)
    except Exception as e:
        print(f"Slack notification failed: {e}")
    return {}

options = ClaudeAgentOptions(hooks={"Notification": [HookMatcher(hooks=[slack_notifier])]})
```

## Async Hooks

For side effects that must not block the agent, return an async output:

```python
async def fire_and_forget_logger(input_data, tool_use_id, context):
    asyncio.create_task(send_to_metrics_service(input_data))
    return {"async_": True, "asyncTimeout": 30000}  # Python uses async_
```

```typescript
const fireAndForgetLogger: HookCallback = async (input, toolUseID, { signal }) => {
  sendToMetricsService(input).catch(console.error);
  return { async: true, asyncTimeout: 30000 };
};
```

Async outputs cannot block, modify, or inject context — they are for logging and metrics only.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Hook never fires | Wrong event name casing | Use `PreToolUse`, not `preToolUse` |
| Matcher not filtering | Matcher only checks tool name | Filter by `tool_input` fields inside callback |
| `updatedInput` ignored | Missing `permissionDecision: "allow"` | Always pair `updatedInput` with `allow` |
| Tool blocked unexpectedly | Overly broad matcher (empty = all tools) | Add explicit matcher pattern |
| Hook timeout | Long-running I/O | Increase `timeout` or use async output |
| `SessionStart`/`SessionEnd` unavailable in Python | Python SDK limitation | Use `setting_sources=["project"]` to load shell hooks from `.claude/settings.json` |
