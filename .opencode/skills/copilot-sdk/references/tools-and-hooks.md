# Tools and Hooks

## Table of Contents

- [Custom Tools](#custom-tools)
  - [Defining Tools — TypeScript (Zod)](#defining-tools--typescript-zod)
  - [Defining Tools — Python (Pydantic)](#defining-tools--python-pydantic)
  - [Raw JSON Schema](#raw-json-schema)
  - [Tool Handler Return Types](#tool-handler-return-types)
  - [How Tool Invocation Works](#how-tool-invocation-works)
- [User Input Requests](#user-input-requests)
- [Session Hooks](#session-hooks)
  - [onPreToolUse](#onpretooluse)
  - [onPostToolUse](#onposttooluse)
  - [onUserPromptSubmitted](#onuserpromptsubmitted)
  - [onSessionStart](#onsessionstart)
  - [onSessionEnd](#onsessionend)
  - [onErrorOccurred](#onerroroccurred)
- [Hook Registration — Full Example](#hook-registration--full-example)

---

## Custom Tools

Custom tools let the agent call back into application code at runtime. Define a name, description, parameter schema, and handler. The SDK manages invocation, JSON serialization, and the response cycle automatically.

### Defining Tools — TypeScript (Zod)

```typescript
import { defineTool, CopilotClient } from "@github/copilot-sdk";
import { z } from "zod";

const lookupIssue = defineTool("lookup_issue", {
    description: "Fetch issue details from the internal tracker",
    parameters: z.object({
        id: z.string().describe("Issue identifier, e.g. PROJ-123"),
        includeComments: z.boolean().optional().describe("Include issue comments"),
    }),
    handler: async ({ id, includeComments }) => {
        const issue = await db.issues.findById(id);
        if (includeComments) issue.comments = await db.comments.findByIssue(id);
        return issue;  // any JSON-serializable value
    },
});

const session = await client.createSession({
    model: "gpt-4.1",
    tools: [lookupIssue],
});
```

### Defining Tools — Python (Pydantic)

```python
from pydantic import BaseModel, Field
from copilot import define_tool, CopilotClient

class LookupIssueParams(BaseModel):
    id: str = Field(description="Issue identifier, e.g. PROJ-123")
    include_comments: bool = Field(default=False, description="Include issue comments")

@define_tool(description="Fetch issue details from the internal tracker")
async def lookup_issue(params: LookupIssueParams) -> dict:
    issue = await db.issues.find_by_id(params.id)
    if params.include_comments:
        issue["comments"] = await db.comments.find_by_issue(params.id)
    return issue

session = await client.create_session({
    "model": "gpt-4.1",
    "tools": [lookup_issue],
})
```

> **Python note:** When using `from __future__ import annotations`, define Pydantic models at module level (not inside functions) to avoid forward-reference resolution issues.

### Raw JSON Schema

Use raw schemas when Zod or Pydantic is unavailable:

```typescript
// TypeScript — raw schema
const lookupIssue = defineTool("lookup_issue", {
    description: "Fetch issue details",
    parameters: {
        type: "object",
        properties: {
            id: { type: "string", description: "Issue identifier" },
        },
        required: ["id"],
    },
    handler: async (args: { id: string }) => {
        return await db.issues.findById(args.id);
    },
});
```

```python
# Python — low-level API
from copilot import Tool

async def lookup_issue_handler(invocation):
    issue_id = invocation["arguments"]["id"]
    return await db.issues.find_by_id(issue_id)

tool = Tool(
    name="lookup_issue",
    description="Fetch issue details",
    parameters={
        "type": "object",
        "properties": {
            "id": {"type": "string", "description": "Issue identifier"},
        },
        "required": ["id"],
    },
    handler=lookup_issue_handler,
)
```

### Tool Handler Return Types

Handlers can return:

| Return type | Behavior |
|---|---|
| Any JSON-serializable value | SDK wraps it automatically |
| Plain string | Sent as text result |
| `ToolResultObject` | Full control — set `textResultForLlm`, `resultType`, `sessionLog` |

```typescript
// Full ToolResultObject (TypeScript)
handler: async ({ id }) => ({
    textResultForLlm: `Issue ${id}: critical auth bug`,
    resultType: "success",
    sessionLog: `Fetched issue ${id} at ${new Date().toISOString()}`,
}),
```

```python
# Python ToolResultObject
async def handler(invocation):
    return {
        "textResultForLlm": f"Issue {invocation['arguments']['id']}: critical auth bug",
        "resultType": "success",
        "sessionLog": "Fetched issue",
    }
```

### How Tool Invocation Works

1. Agent determines a tool call is needed based on the prompt
2. CLI sends a `tool.call` event to the SDK with tool name and arguments
3. SDK executes the registered handler function
4. Result is serialized and returned to the CLI
5. Agent incorporates the result and continues generating the response

The SDK handles the full request-response cycle; no manual JSON-RPC interaction is needed.

---

## User Input Requests

Enable the agent to ask clarifying questions to the user by providing an `onUserInputRequest` / `on_user_input_request` handler. This activates the `ask_user` built-in tool.

```typescript
// TypeScript
const session = await client.createSession({
    model: "gpt-4.1",
    onUserInputRequest: async (request, invocation) => {
        console.log(`Agent: ${request.question}`);
        if (request.choices?.length) {
            console.log(`Choices: ${request.choices.join(" | ")}`);
        }
        const answer = await readlinePrompt("Your answer: ");
        return { answer, wasFreeform: true };
    },
});
```

```python
# Python
async def handle_user_input(request, invocation):
    print(f"Agent: {request['question']}")
    if request.get("choices"):
        print(f"Choices: {' | '.join(request['choices'])}")
    answer = input("Your answer: ")
    return {"answer": answer, "wasFreeform": True}

session = await client.create_session({
    "model": "gpt-4.1",
    "on_user_input_request": handle_user_input,
})
```

**Request fields:**

| Field | Type | Description |
|---|---|---|
| `question` | string | The question the agent wants to ask |
| `choices` | string[] \| None | Optional list of valid choices |
| `allowFreeform` | bool | Whether free-text answers are accepted (default: `true`) |

**Response fields:**

| Field | Type | Description |
|---|---|---|
| `answer` | string | The user's answer |
| `wasFreeform` | bool | `true` if the answer was free-text (not from `choices`) |

---

## Session Hooks

Hooks intercept the session lifecycle at well-defined points. All hooks are optional and registered in the `hooks` / `hooks` config object.

### onPreToolUse

Called **before** each tool execution. Allows approving, denying, or modifying arguments.

```typescript
// TypeScript
onPreToolUse: async (input, invocation) => {
    // input.toolName, input.toolArgs available
    if (input.toolName === "delete_file") {
        return { permissionDecision: "deny" };
    }
    return {
        permissionDecision: "allow",
        modifiedArgs: { ...input.toolArgs, dryRun: true },
        additionalContext: "Running in dry-run mode",
    };
},
```

```python
# Python
async def on_pre_tool_use(input, invocation):
    if input["toolName"] == "delete_file":
        return {"permissionDecision": "deny"}
    return {
        "permissionDecision": "allow",
        "modifiedArgs": {**input.get("toolArgs", {}), "dry_run": True},
        "additionalContext": "Running in dry-run mode",
    }
```

**Return fields:**

| Field | Description |
|---|---|
| `permissionDecision` | `"allow"` \| `"deny"` \| `"ask"` |
| `modifiedArgs` | Replacement arguments (optional) |
| `additionalContext` | Extra context injected into the model (optional) |

### onPostToolUse

Called **after** each tool execution. Allows adding context or modifying results.

```typescript
onPostToolUse: async (input, invocation) => {
    logger.info(`Tool "${input.toolName}" completed`);
    return { additionalContext: "Tool completed successfully" };
},
```

```python
async def on_post_tool_use(input, invocation):
    logger.info(f"Tool '{input['toolName']}' completed")
    return {"additionalContext": "Tool completed successfully"}
```

### onUserPromptSubmitted

Called when the user submits a prompt. Allows modifying the prompt before it reaches the model.

```typescript
onUserPromptSubmitted: async (input, invocation) => {
    const sanitized = sanitize(input.prompt);
    return { modifiedPrompt: sanitized };
},
```

```python
async def on_user_prompt_submitted(input, invocation):
    sanitized = sanitize(input["prompt"])
    return {"modifiedPrompt": sanitized}
```

### onSessionStart

Called when a session starts, resumes, or is created fresh. Useful for injecting context.

```typescript
onSessionStart: async (input, invocation) => {
    // input.source: "startup" | "resume" | "new"
    const userCtx = await loadUserContext(userId);
    return { additionalContext: `User preferences: ${JSON.stringify(userCtx)}` };
},
```

```python
async def on_session_start(input, invocation):
    # input["source"]: "startup", "resume", or "new"
    user_ctx = await load_user_context(user_id)
    return {"additionalContext": f"User preferences: {user_ctx}"}
```

**`input.source` values:**

| Value | Meaning |
|---|---|
| `"startup"` | CLI process startup |
| `"resume"` | Resuming a persisted session |
| `"new"` | Brand-new session |

### onSessionEnd

Called when a session ends. Use for cleanup and logging. Return value is ignored.

```typescript
onSessionEnd: async (input, invocation) => {
    // input.reason available
    await analytics.track("session_ended", { reason: input.reason });
},
```

### onErrorOccurred

Called when an error occurs. Returns an error handling strategy.

```typescript
onErrorOccurred: async (input, invocation) => {
    // input.error, input.errorContext available
    logger.error(`Error in ${input.errorContext}: ${input.error}`);
    return { errorHandling: "retry" };  // "retry" | "skip" | "abort"
},
```

```python
async def on_error_occurred(input, invocation):
    logger.error(f"Error in {input['errorContext']}: {input['error']}")
    return {"errorHandling": "retry"}  # "retry", "skip", or "abort"
```

**`errorHandling` values:**

| Value | Behavior |
|---|---|
| `"retry"` | Retry the failed operation |
| `"skip"` | Skip the failed step and continue |
| `"abort"` | Abort the current request entirely |

---

## Hook Registration — Full Example

**TypeScript:**
```typescript
const session = await client.createSession({
    model: "gpt-4.1",
    hooks: {
        onPreToolUse: async (input, invocation) => ({
            permissionDecision: "allow",
        }),
        onPostToolUse: async (input, invocation) => ({
            additionalContext: `${input.toolName} done`,
        }),
        onUserPromptSubmitted: async (input, invocation) => ({
            modifiedPrompt: input.prompt.trim(),
        }),
        onSessionStart: async (input, invocation) => ({
            additionalContext: `Started via ${input.source}`,
        }),
        onSessionEnd: async (input, invocation) => {
            await cleanup();
        },
        onErrorOccurred: async (input, invocation) => ({
            errorHandling: "skip",
        }),
    },
});
```

**Python:**
```python
session = await client.create_session({
    "model": "gpt-4.1",
    "hooks": {
        "on_pre_tool_use": lambda i, inv: {"permissionDecision": "allow"},
        "on_post_tool_use": lambda i, inv: {"additionalContext": f"{i['toolName']} done"},
        "on_user_prompt_submitted": lambda i, inv: {"modifiedPrompt": i["prompt"].strip()},
        "on_session_start": lambda i, inv: {"additionalContext": f"Started via {i['source']}"},
        "on_session_end": on_session_end,
        "on_error_occurred": lambda i, inv: {"errorHandling": "skip"},
    },
})
```
