# Custom Tools Reference — Claude Agent SDK

Build in-process MCP tools using `createSdkMcpServer` (TypeScript) or `create_sdk_mcp_server` (Python) to extend Claude with application-specific capabilities.

## Table of Contents

- [Overview](#overview)
- [Defining Tools](#defining-tools)
- [Schema Definitions](#schema-definitions)
- [Using Custom Tools in a Query](#using-custom-tools-in-a-query)
- [Tool Naming Convention](#tool-naming-convention)
- [Error Handling](#error-handling)
- [Common Patterns](#common-patterns)
- [Type Safety](#type-safety)

## Overview

Custom tools use the Model Context Protocol (MCP) running in-process. They differ from external MCP servers in that they run within the same process as the SDK, with direct access to application state and secrets.

**When to use custom tools**:
- Calling internal APIs that require authenticated clients already in memory
- Accessing a database connection pool managed by the application
- Performing domain-specific computation unavailable as a built-in tool
- Wrapping external services behind a controlled, validated interface

**When to use external MCP servers** instead:
- The tool is stateless and reusable across projects (e.g., Playwright, filesystem)
- The server is maintained by a third party
- The tool needs to outlive the agent process

## Defining Tools

### TypeScript

```typescript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const server = createSdkMcpServer({
  name: "my-tools",
  version: "1.0.0",
  tools: [
    tool(
      "lookup_user",           // tool name
      "Look up a user by ID",  // description shown to Claude
      {
        user_id: z.string().describe("The user's UUID"),
        include_history: z.boolean().optional().default(false),
      },
      async (args) => {
        const user = await db.users.findById(args.user_id);
        return {
          content: [{ type: "text", text: JSON.stringify(user, null, 2) }]
        };
      }
    )
  ]
});
```

### Python

```python
from claude_agent_sdk import tool, create_sdk_mcp_server
from typing import Any

@tool(
    "lookup_user",
    "Look up a user by ID",
    {"user_id": str, "include_history": bool},
)
async def lookup_user(args: dict[str, Any]) -> dict[str, Any]:
    user = await db.users.find_by_id(args["user_id"])
    include_history = args.get("include_history", False)
    if include_history:
        user["history"] = await db.users.get_history(args["user_id"])
    return {"content": [{"type": "text", "text": json.dumps(user, indent=2)}]}

server = create_sdk_mcp_server(
    name="my-tools",
    version="1.0.0",
    tools=[lookup_user],
)
```

## Schema Definitions

### TypeScript: Zod schemas (recommended)

Zod provides both runtime validation and TypeScript type inference:

```typescript
{
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150),
  email: z.string().email(),
  role: z.enum(["admin", "user", "viewer"]),
  tags: z.array(z.string()).optional(),
  metadata: z.record(z.string()).optional(),
}
```

### Python: Simple type mapping

For straightforward tools, pass a `dict` mapping field names to Python types:

```python
{"query": str, "limit": int, "include_archived": bool}
```

### Python: JSON Schema for complex validation

Use full JSON Schema when you need enums, constraints, or optional fields:

```python
{
    "type": "object",
    "properties": {
        "status": {"type": "string", "enum": ["active", "inactive", "pending"]},
        "limit": {"type": "integer", "minimum": 1, "maximum": 100, "default": 10},
        "email": {"type": "string", "format": "email"},
    },
    "required": ["status"],
}
```

## Using Custom Tools in a Query

Custom MCP tools require **streaming input mode** — pass an async generator as `prompt`:

```python
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

options = ClaudeAgentOptions(
    mcp_servers={"my-tools": server},
    allowed_tools=["mcp__my-tools__lookup_user"],
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("Look up user abc-123 and summarise their recent activity")
    async for message in client.receive_response():
        print(message)
```

```typescript
async function* generateMessages() {
  yield {
    type: "user" as const,
    message: { role: "user" as const, content: "Look up user abc-123 and summarise activity" }
  };
}

for await (const message of query({
  prompt: generateMessages(),
  options: {
    mcpServers: { "my-tools": server },
    allowedTools: ["mcp__my-tools__lookup_user"]
  }
})) {
  if ("result" in message) console.log(message.result);
}
```

## Tool Naming Convention

MCP tool names follow the pattern `mcp__{server_name}__{tool_name}`:

| Server name | Tool name | Full name for `allowedTools` |
|-------------|-----------|------------------------------|
| `my-tools` | `lookup_user` | `mcp__my-tools__lookup_user` |
| `database` | `query` | `mcp__database__query` |
| `api-gateway` | `api_request` | `mcp__api-gateway__api_request` |

List each tool explicitly in `allowed_tools` / `allowedTools` to avoid granting unintended access:

```python
allowed_tools=[
    "mcp__my-tools__lookup_user",   # allowed
    # "mcp__my-tools__delete_user"  # not listed → not accessible
]
```

## Error Handling

Return structured error responses instead of raising exceptions. An unhandled exception can interrupt the agent unexpectedly:

```python
@tool("fetch_record", "Fetch a record from the API", {"record_id": str})
async def fetch_record(args: dict[str, Any]) -> dict[str, Any]:
    try:
        async with aiohttp.ClientSession() as session:
            async with session.get(f"https://api.example.com/records/{args['record_id']}") as resp:
                if resp.status == 404:
                    return {"content": [{"type": "text", "text": f"Record {args['record_id']} not found"}]}
                if resp.status != 200:
                    return {"content": [{"type": "text", "text": f"API error {resp.status}: {resp.reason}"}]}
                data = await resp.json()
                return {"content": [{"type": "text", "text": json.dumps(data, indent=2)}]}
    except aiohttp.ClientError as e:
        return {"content": [{"type": "text", "text": f"Network error: {e}"}]}
```

```typescript
tool("fetch_record", "Fetch a record from the API", { record_id: z.string() }, async (args) => {
  try {
    const res = await fetch(`https://api.example.com/records/${args.record_id}`);
    if (res.status === 404) return { content: [{ type: "text", text: `Record ${args.record_id} not found` }] };
    if (!res.ok) return { content: [{ type: "text", text: `API error ${res.status}: ${res.statusText}` }] };
    const data = await res.json();
    return { content: [{ type: "text", text: JSON.stringify(data, null, 2) }] };
  } catch (err) {
    return { content: [{ type: "text", text: `Network error: ${err.message}` }] };
  }
})
```

## Common Patterns

### Database query tool

```python
@tool(
    "query_db",
    "Run a read-only SQL query against the application database",
    {
        "type": "object",
        "properties": {
            "sql": {"type": "string", "description": "SELECT statement only"},
            "limit": {"type": "integer", "minimum": 1, "maximum": 500, "default": 50},
        },
        "required": ["sql"],
    },
)
async def query_db(args: dict[str, Any]) -> dict[str, Any]:
    # Enforce read-only at the tool level
    if not args["sql"].strip().upper().startswith("SELECT"):
        return {"content": [{"type": "text", "text": "Error: Only SELECT statements are permitted"}]}
    rows = await db.execute(args["sql"], limit=args.get("limit", 50))
    return {"content": [{"type": "text", "text": json.dumps(rows, indent=2, default=str)}]}
```

### Multi-tool server

```python
server = create_sdk_mcp_server(
    name="app-tools",
    version: "1.0.0",
    tools=[
        lookup_user,
        query_db,
        send_notification,
        generate_report,
    ],
)

# Grant access to specific tools only
options = ClaudeAgentOptions(
    mcp_servers={"app-tools": server},
    allowed_tools=[
        "mcp__app-tools__lookup_user",
        "mcp__app-tools__query_db",
        # send_notification and generate_report are not listed → inaccessible
    ],
)
```

### Inject application context via closure

```python
def make_tools(db_pool, auth_token: str):
    @tool("get_account", "Get account details for the authenticated user", {"account_id": str})
    async def get_account(args: dict[str, Any]) -> dict[str, Any]:
        # Capture db_pool and auth_token from the enclosing scope
        async with db_pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT * FROM accounts WHERE id = $1 AND token = $2",
                args["account_id"], auth_token
            )
        return {"content": [{"type": "text", "text": json.dumps(dict(row), indent=2, default=str)}]}

    return [get_account]

server = create_sdk_mcp_server(
    name="account-tools",
    version="1.0.0",
    tools=make_tools(db_pool=pool, auth_token=token),
)
```

## Type Safety

### TypeScript: full Zod inference

```typescript
tool(
  "process",
  "Process structured input",
  {
    name: z.string(),
    count: z.number().int().positive(),
    mode: z.enum(["fast", "accurate"]).default("accurate"),
  },
  async (args) => {
    // args.name: string, args.count: number, args.mode: "fast" | "accurate"
    return { content: [{ type: "text", text: `Processing ${args.count} items for ${args.name}` }] };
  }
)
```

### Python: type hints in callback

Although Python tool schemas don't enforce types at runtime, document expected types via annotations:

```python
@tool("process", "Process structured input", {"name": str, "count": int, "mode": str})
async def process(args: dict[str, Any]) -> dict[str, Any]:
    name: str = args["name"]
    count: int = args["count"]
    mode: str = args.get("mode", "accurate")
    return {"content": [{"type": "text", "text": f"Processing {count} items for {name} in {mode} mode"}]}
```

Always validate inputs at the start of the callback when handling untrusted data. Do not use `eval()` on user-supplied expressions in production — use a safe math library instead.
