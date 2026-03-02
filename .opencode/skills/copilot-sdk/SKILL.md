---
name: copilot-sdk
description: This skill should be used when the user asks to "integrate GitHub Copilot into an app", "use the Copilot SDK", "build a Copilot-powered agent", "embed Copilot in a service", or needs guidance on the GitHub Copilot SDK for Python, TypeScript, Go, or .NET.
---

# GitHub Copilot SDK

Multi-platform SDK for embedding GitHub Copilot's agentic runtime into applications and services. Available for Node.js/TypeScript, Python, Go, and .NET. Communicates with the Copilot CLI in server mode via JSON-RPC.

> **Status:** Technical Preview — breaking changes possible between releases.

## Architecture

```
Your Application
      |
  SDK Client   (manages CLI process lifecycle + JSON-RPC transport)
      |
  Copilot CLI  (server mode — planning, tool invocation, file edits)
```

The SDK spawns and manages the CLI automatically. Applications define agent behavior; the CLI handles orchestration.

## Prerequisites

1. Install the **GitHub Copilot CLI** and authenticate:
   ```bash
   # Follow: https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli
   copilot --version   # verify
   ```
2. A **GitHub Copilot subscription** (or BYOK — see `references/authentication.md`)

## Installation

| Language | Package | Install |
|---|---|---|
| Node.js / TypeScript | `@github/copilot-sdk` | `npm install @github/copilot-sdk` |
| Python | `github-copilot-sdk` | `pip install github-copilot-sdk` |
| Go | `github.com/github/copilot-sdk/go` | `go get github.com/github/copilot-sdk/go` |
| .NET | `GitHub.Copilot.SDK` | `dotnet add package GitHub.Copilot.SDK` |

## Core Workflow

Every SDK integration follows this pattern:

1. Create a `CopilotClient`
2. Call `client.start()` (auto-starts the CLI server)
3. Create a **session** with `client.createSession(config)`
4. Send messages; handle events
5. Call `client.stop()` on shutdown

### Minimal Example

**TypeScript:**
```typescript
import { CopilotClient } from "@github/copilot-sdk";

const client = new CopilotClient();
const session = await client.createSession({ model: "gpt-4.1" });

const response = await session.sendAndWait({ prompt: "What is 2 + 2?" });
console.log(response?.data.content);

await client.stop();
process.exit(0);
```

**Python:**
```python
import asyncio
from copilot import CopilotClient

async def main():
    client = CopilotClient()
    await client.start()
    session = await client.create_session({"model": "gpt-4.1"})
    response = await session.send_and_wait({"prompt": "What is 2 + 2?"})
    print(response.data.content)
    await client.stop()

asyncio.run(main())
```

## Sessions

Sessions represent a single conversation thread. `createSession` / `create_session` accepts a `SessionConfig`:

| Option | Type | Description |
|---|---|---|
| `model` | string | Model ID — **required with BYOK**. E.g. `"gpt-4.1"`, `"claude-sonnet-4.5"` |
| `streaming` | bool | Emit `assistant.message_delta` chunks in real time |
| `tools` | Tool[] | Custom tools the agent can invoke |
| `systemMessage` | object | Inject or replace the system prompt |
| `infiniteSessions` | object | Context compaction config (enabled by default) |
| `provider` | object | BYOK — custom LLM provider config |
| `hooks` | object | Lifecycle hook handlers |
| `onUserInputRequest` | callable | Enable `ask_user` tool; handler returns user's answer |
| `sessionId` | string | Deterministic / resumable session ID |

### Sending Messages

```typescript
// Fire-and-forget (returns message ID)
await session.send({ prompt: "Generate a README" });

// Send and await idle state (returns final AssistantMessageEvent)
const result = await session.sendAndWait({ prompt: "Explain this code" });
```

```python
# Python equivalent
await session.send({"prompt": "Generate a README"})
result = await session.send_and_wait({"prompt": "Explain this code"})
```

### Streaming Events

Enable `streaming: true` and subscribe to incremental chunks:

```typescript
const session = await client.createSession({ model: "gpt-4.1", streaming: true });

session.on("assistant.message_delta", (event) => {
    process.stdout.write(event.data.deltaContent);
});
session.on("session.idle", () => console.log("\nDone."));

await session.sendAndWait({ prompt: "Write a haiku about testing" });
```

Key session event types:

| Event | Fires when |
|---|---|
| `user.message` | User message enqueued |
| `assistant.message` | Final full response available |
| `assistant.message_delta` | Streaming chunk (requires `streaming: true`) |
| `assistant.reasoning_delta` | Chain-of-thought chunk (model-dependent) |
| `tool.execution_start` | Agent begins a tool call |
| `tool.execution_complete` | Tool call finished |
| `session.idle` | Processing complete, session ready |
| `session.compaction_start` | Infinite session compaction started |
| `session.compaction_complete` | Compaction finished |

All `session.on()` calls return an unsubscribe function.

## Custom Tools

Define functions the agent can call. The SDK handles invocation, serialization, and response automatically.

**TypeScript (with Zod):**
```typescript
import { defineTool, CopilotClient } from "@github/copilot-sdk";
import { z } from "zod";

const lookupIssue = defineTool("lookup_issue", {
    description: "Fetch issue details from the tracker",
    parameters: z.object({
        id: z.string().describe("Issue identifier"),
    }),
    handler: async ({ id }) => {
        return await fetchIssue(id);  // any JSON-serializable value
    },
});

const session = await client.createSession({
    model: "gpt-4.1",
    tools: [lookupIssue],
});
```

**Python (with Pydantic):**
```python
from pydantic import BaseModel, Field
from copilot import define_tool

class LookupIssueParams(BaseModel):
    id: str = Field(description="Issue identifier")

@define_tool(description="Fetch issue details from the tracker")
async def lookup_issue(params: LookupIssueParams) -> str:
    return await fetch_issue(params.id)

session = await client.create_session({
    "model": "gpt-4.1",
    "tools": [lookup_issue],
})
```

Raw JSON schemas are also accepted when Zod/Pydantic is not available.

## System Message Customization

Inject additional context into the system prompt without replacing the default persona:

```typescript
const session = await client.createSession({
    model: "gpt-4.1",
    systemMessage: {
        content: `
<workflow_rules>
- Always check for security vulnerabilities
- Suggest performance improvements when applicable
</workflow_rules>`,
    },
});
```

Use `mode: "replace"` to fully control the system prompt (removes all SDK-managed guardrails):

```typescript
systemMessage: { mode: "replace", content: "You are a terse code reviewer." }
```

## Infinite Sessions

Enabled by default. Manages the context window automatically through background compaction and persists state to `~/.copilot/session-state/{sessionId}/`.

```typescript
// Custom thresholds
const session = await client.createSession({
    model: "gpt-4.1",
    infiniteSessions: {
        enabled: true,
        backgroundCompactionThreshold: 0.80,  // compact at 80% usage
        bufferExhaustionThreshold: 0.95,       // block at 95% until done
    },
});

// Disable (fixed context window)
const session = await client.createSession({
    model: "gpt-4.1",
    infiniteSessions: { enabled: false },
});
```

Resume a persisted session by ID:
```typescript
const session = await client.resumeSession("my-session-id");
```

## File Attachments

Attach files or images to messages:

```typescript
await session.send({
    prompt: "Review this module",
    attachments: [{ type: "file", path: "/src/auth.ts", displayName: "auth.ts" }],
});
```

Supported image formats: JPG, PNG, GIF, and common image types. The agent's `view` tool also reads files directly from the filesystem.

## MCP Servers

Connect to Model Context Protocol servers to provide pre-built tools (e.g., GitHub repositories, issues, PRs):

```typescript
const session = await client.createSession({
    model: "gpt-4.1",
    mcpServers: {
        github: {
            type: "http",
            url: "https://api.githubcopilot.com/mcp/",
        },
    },
});
```

## External CLI Server

Run the CLI separately and connect the SDK to it — useful for debugging, resource sharing, or custom flags:

```bash
copilot --headless --port 4321
```

```typescript
const client = new CopilotClient({ cliUrl: "localhost:4321" });
```

When `cliUrl` is set, the SDK does not spawn a CLI process.

## Error Handling

Wrap client and session operations in try/catch. The `stop()` method returns a list of errors from cleanup:

```typescript
try {
    const session = await client.createSession({ model: "gpt-4.1" });
    await session.sendAndWait({ prompt: "Fix the bug" });
} catch (error) {
    console.error("SDK error:", error.message);
} finally {
    const errors = await client.stop();
    if (errors.length) console.error("Cleanup errors:", errors);
}
```

Use `client.forceStop()` if graceful shutdown hangs.

## Session Lifecycle Methods

```typescript
// List sessions (optionally filter by working directory)
const sessions = await client.listSessions();

// Delete a session
await client.deleteSession("session-id");

// Get all messages from a session
const messages = await session.getMessages();

// Abort current processing
await session.abort();

// Destroy session and free resources
await session.destroy();
```

## Multiple Sessions

Each session is independent. Multiple models can run simultaneously:

```typescript
const session1 = await client.createSession({ model: "gpt-4.1" });
const session2 = await client.createSession({ model: "claude-sonnet-4.5" });

await Promise.all([
    session1.sendAndWait({ prompt: "Draft a PR description" }),
    session2.sendAndWait({ prompt: "Review the security implications" }),
]);
```

## Quick Reference

```
CopilotClient options:  cliPath, cliUrl, port, useStdio, logLevel,
                        autoStart, autoRestart, githubToken, useLoggedInUser

SessionConfig:          model, streaming, tools, systemMessage,
                        infiniteSessions, provider, hooks,
                        onUserInputRequest, sessionId

session.send()          → Promise<string>  (message ID)
session.sendAndWait()   → Promise<AssistantMessageEvent | undefined>
session.on()            → () => void  (unsubscribe fn)
session.abort()         → Promise<void>
session.destroy()       → Promise<void>
session.getMessages()   → Promise<SessionEvent[]>
```

## Additional Resources

- **`references/authentication.md`** — GitHub OAuth, environment variables, BYOK (Azure, OpenAI, Anthropic), and auth priority order
- **`references/tools-and-hooks.md`** — Tool handler return types, raw JSON schema, session hooks (`onPreToolUse`, `onPostToolUse`, `onUserPromptSubmitted`, `onSessionStart`, `onSessionEnd`, `onErrorOccurred`), and user input requests
