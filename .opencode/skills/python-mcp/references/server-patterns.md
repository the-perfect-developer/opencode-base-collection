# Advanced MCP Server Patterns

Detailed patterns for building production-quality MCP servers with the Python SDK.

## Table of Contents

- [Structured Output](#structured-output)
- [Elicitation](#elicitation)
- [Sampling — LLM Interaction from Tools](#sampling--llm-interaction-from-tools)
- [Notifications and Resource Updates](#notifications-and-resource-updates)
- [Completions](#completions)
- [Authentication with OAuth 2.1](#authentication-with-oauth-21)
- [Low-Level Server API](#low-level-server-api)
- [Mounting Multiple Servers](#mounting-multiple-servers)
- [Pagination](#pagination)
- [Writing MCP Clients](#writing-mcp-clients)

---

## Structured Output

FastMCP automatically generates a JSON Schema from return type annotations and validates returned values against it.

### Supported Return Types

| Type | Behavior |
|------|----------|
| `BaseModel` subclass | Full schema + validation |
| `TypedDict` | Schema from typed keys |
| `dataclass` with type hints | Schema from annotated fields |
| `dict[str, T]` | Schema for homogeneous maps |
| `str`, `int`, `float`, `bool` | Wrapped: `{"result": value}` |
| `list[T]`, `tuple`, `Optional` | Wrapped: `{"result": value}` |
| Class **without** type hints | Unstructured (no schema) |

Pydantic `BaseModel` is the strongest choice — it provides schema generation, runtime validation, and `Field` metadata for documentation.

### Disabling Structured Output

When a typed return annotation should not trigger structured output (e.g., returning a pre-built `dict` that matches no schema), disable explicitly:

```python
@mcp.tool(structured_output=False)
def raw_stats(dataset: str) -> dict:
    """Return raw statistics without schema enforcement."""
    return compute_stats(dataset)
```

### Direct CallToolResult for Full Control

Return `CallToolResult` directly when access to `_meta` or manual content control is needed:

```python
from mcp.types import CallToolResult, TextContent

@mcp.tool()
def audited_action(action: str) -> CallToolResult:
    """Perform an action and embed audit data in _meta."""
    result = perform(action)
    return CallToolResult(
        content=[TextContent(type="text", text=result)],
        _meta={"audit_id": generate_audit_id(), "timestamp": now_iso()},
    )
```

`_meta` is passed to clients but **not** shown to the LLM — use it for client-side tracking, analytics, or correlation IDs.

For empty results (no content to return):

```python
return CallToolResult(content=[])
```

Never return `None` or omit the return — always return a `CallToolResult` with at least an empty content list.

---

## Elicitation

Elicitation allows a tool to pause and request additional information from the user during a tool call.

### Form Elicitation (Non-Sensitive Data)

```python
from pydantic import BaseModel, Field
from mcp.server.fastmcp import Context, FastMCP
from mcp.server.session import ServerSession

class ConfirmationRequest(BaseModel):
    confirmed: bool = Field(description="Confirm the destructive operation?")
    reason: str = Field(default="", description="Optional reason for confirmation")

@mcp.tool()
async def delete_records(table: str, ctx: Context[ServerSession, None]) -> str:
    """Delete all records from a table after user confirmation."""
    result = await ctx.elicit(
        message=f"This will permanently delete ALL records from '{table}'. Proceed?",
        schema=ConfirmationRequest,
    )

    if result.action != "accept" or not result.data or not result.data.confirmed:
        return "Operation cancelled"

    perform_delete(table)
    return f"Deleted all records from {table}"
```

`ElicitationResult` fields:
- `action`: `"accept"` | `"decline"` | `"cancel"`
- `data`: validated Pydantic model instance (only when `action == "accept"`)
- `validation_error`: error string if schema validation failed

### URL Elicitation (Sensitive / OAuth Flows)

For sensitive operations (OAuth, payments, credentials), redirect the user to an external URL instead of collecting data inline:

```python
import uuid
from mcp.server.fastmcp import Context, FastMCP

@mcp.tool()
async def connect_github(ctx: Context) -> str:
    """Initiate GitHub OAuth flow."""
    elicitation_id = str(uuid.uuid4())
    result = await ctx.elicit_url(
        message="Authorize access to your GitHub account",
        url=f"https://github.com/login/oauth/authorize?state={elicitation_id}",
        elicitation_id=elicitation_id,
    )
    if result.action == "accept":
        return "Authorization initiated — check your browser to complete"
    return "Authorization cancelled"
```

Use the "raise error" pattern when the tool **cannot proceed at all** without the out-of-band action:

```python
from mcp.shared.exceptions import UrlElicitationRequiredError
from mcp.types import ElicitRequestURLParams

raise UrlElicitationRequiredError([
    ElicitRequestURLParams(
        mode="url",
        message="OAuth authorization required",
        url=f"https://provider.example.com/oauth?state={elicitation_id}",
        elicitationId=elicitation_id,
    )
])
```

---

## Sampling — LLM Interaction from Tools

Tools can request LLM completions through the session. This enables agentic loops where the server reasons or generates content as part of tool execution.

```python
from mcp.types import SamplingMessage, TextContent

@mcp.tool()
async def summarize(text: str, ctx: Context) -> str:
    """Summarize text using the LLM connected to this session."""
    result = await ctx.session.create_message(
        messages=[
            SamplingMessage(
                role="user",
                content=TextContent(type="text", text=f"Summarize this:\n\n{text}"),
            )
        ],
        max_tokens=200,
    )
    if result.content.type == "text":
        return result.content.text
    return str(result.content)
```

Sampling is only available when the MCP client declares `sampling` capability. Check `ctx.session.client_params` before calling if client support is uncertain.

---

## Notifications and Resource Updates

Notify clients when server-side state changes, so they can refresh their context without polling.

```python
@mcp.tool()
async def ingest_file(path: str, ctx: Context) -> str:
    """Ingest a file and notify clients the resource list changed."""
    resource_uri = store_file(path)

    # Notify that a specific resource was updated
    await ctx.session.send_resource_updated(resource_uri)

    # Notify that the resource catalog changed (new item added)
    await ctx.session.send_resource_list_changed()

    return f"Ingested {path} as {resource_uri}"
```

Available notification methods on `ctx.session`:

| Method | When to use |
|--------|-------------|
| `send_resource_updated(uri)` | A specific resource's content changed |
| `send_resource_list_changed()` | Resources were added or removed |
| `send_tool_list_changed()` | Tools were added or removed dynamically |
| `send_prompt_list_changed()` | Prompts were added or removed dynamically |

---

## Completions

Provide autocomplete suggestions for prompt arguments and resource template parameters. Implement `get_completion` handlers on the low-level server or use `FastMCP`'s built-in completion support via annotated parameter types.

Client-side completion request example (for reference when building MCP clients):

```python
from mcp import ClientSession
from mcp.types import PromptReference

async with ClientSession(read, write) as session:
    await session.initialize()
    result = await session.complete(
        ref=PromptReference(type="ref/prompt", name="review_code"),
        argument={"name": "language", "value": "py"},
    )
    # result.completion.values = ["python", "pypy", "pyrex", ...]
```

---

## Authentication with OAuth 2.1

MCP servers act as **Resource Servers** that validate tokens issued by a separate Authorization Server. Implement `TokenVerifier` to plug in any token validation strategy.

```python
from pydantic import AnyHttpUrl
from mcp.server.auth.provider import AccessToken, TokenVerifier
from mcp.server.auth.settings import AuthSettings
from mcp.server.fastmcp import FastMCP

class JWTVerifier(TokenVerifier):
    """Validate JWTs issued by the configured Authorization Server."""

    async def verify_token(self, token: str) -> AccessToken | None:
        try:
            payload = decode_jwt(token, public_key=PUBLIC_KEY, algorithms=["RS256"])
            return AccessToken(
                token=token,
                client_id=payload["client_id"],
                scopes=payload.get("scope", "").split(),
                expires_at=payload.get("exp"),
            )
        except JWTError:
            return None  # Return None to reject the token

mcp = FastMCP(
    "Protected API",
    json_response=True,
    token_verifier=JWTVerifier(),
    auth=AuthSettings(
        issuer_url=AnyHttpUrl("https://auth.example.com"),
        resource_server_url=AnyHttpUrl("https://api.example.com"),
        required_scopes=["read", "write"],
    ),
)
```

Key points:
- Return `None` from `verify_token` to reject; return `AccessToken` to allow.
- `required_scopes` are checked by the framework — no manual scope checking needed in tools.
- The server exposes RFC 9728 Protected Resource Metadata at `/.well-known/oauth-protected-resource` automatically.

---

## Low-Level Server API

Use the low-level API when `FastMCP` does not provide the control needed — for example, custom protocol extensions, manual capability negotiation, or advanced session management.

```python
from mcp.server import Server
from mcp.server.models import InitializationOptions
import mcp.types as types

app = Server("low-level-server")

@app.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="echo",
            description="Echo the input back",
            inputSchema={
                "type": "object",
                "properties": {"message": {"type": "string"}},
                "required": ["message"],
            },
        )
    ]

@app.call_tool()
async def handle_call_tool(
    name: str, arguments: dict | None
) -> list[types.TextContent | types.ImageContent | types.EmbeddedResource]:
    if name == "echo":
        return [types.TextContent(type="text", text=arguments["message"])]
    raise ValueError(f"Unknown tool: {name}")
```

The low-level API maps directly to MCP protocol handlers. Prefer `FastMCP` for all standard use cases.

---

## Mounting Multiple Servers

Compose multiple `FastMCP` servers into a single ASGI application using Starlette:

```python
import contextlib
from starlette.applications import Starlette
from starlette.routing import Mount
from mcp.server.fastmcp import FastMCP

search_mcp = FastMCP(name="SearchServer", stateless_http=True, json_response=True)
analytics_mcp = FastMCP(name="AnalyticsServer", stateless_http=True, json_response=True)

# Register tools on each server independently
@search_mcp.tool()
def search(query: str) -> list[str]:
    """Full-text search across documents."""
    return run_search(query)

@analytics_mcp.tool()
def get_metrics(metric: str) -> float:
    """Retrieve a named metric."""
    return fetch_metric(metric)

@contextlib.asynccontextmanager
async def lifespan(app: Starlette):
    async with contextlib.AsyncExitStack() as stack:
        await stack.enter_async_context(search_mcp.session_manager.run())
        await stack.enter_async_context(analytics_mcp.session_manager.run())
        yield

app = Starlette(
    routes=[
        Mount("/search", search_mcp.streamable_http_app()),
        Mount("/analytics", analytics_mcp.streamable_http_app()),
    ],
    lifespan=lifespan,
)
# Clients connect to /search/mcp and /analytics/mcp
```

To serve each server at the mount root (e.g., `/search` instead of `/search/mcp`):

```python
search_mcp.settings.streamable_http_path = "/"
```

---

## Pagination

For tools or resources that return large datasets, implement pagination to avoid oversized responses:

```python
from mcp.types import CallToolResult, TextContent
import json

@mcp.tool()
def list_records(
    offset: int = 0,
    limit: int = 20,
) -> CallToolResult:
    """List records with cursor-based pagination."""
    records = fetch_records(offset=offset, limit=limit + 1)
    has_more = len(records) > limit
    page = records[:limit]

    return CallToolResult(
        content=[TextContent(type="text", text=json.dumps({
            "records": [r.to_dict() for r in page],
            "next_offset": offset + limit if has_more else None,
            "has_more": has_more,
        }))],
    )
```

For the low-level API, MCP has native cursor-based pagination support via `list_resources` and related handlers.

---

## Writing MCP Clients

Use `ClientSession` to connect to any MCP server programmatically.

### stdio Client

```python
import asyncio
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

server_params = StdioServerParameters(
    command="uv",
    args=["run", "server.py"],
)

async def main():
    async with stdio_client(server_params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()

            # List available tools
            tools = await session.list_tools()
            print([t.name for t in tools.tools])

            # Call a tool
            result = await session.call_tool("get_weather", {"city": "London"})
            print(result.content)

asyncio.run(main())
```

### HTTP Client

```python
import asyncio
import httpx
from mcp.client.streamable_http import streamablehttp_client
from mcp import ClientSession

async def main():
    async with streamablehttp_client("http://localhost:8000/mcp") as (read, write, _):
        async with ClientSession(read, write) as session:
            await session.initialize()
            result = await session.call_tool("add", {"a": 2, "b": 3})
            print(result)

asyncio.run(main())
```
