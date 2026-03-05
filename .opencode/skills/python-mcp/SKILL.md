---
name: python-mcp
description: This skill should be used when the user asks to "build an MCP server", "create an MCP tool", "expose resources with MCP", "write an MCP client", or needs guidance on the Model Context Protocol Python SDK best practices, transports, server primitives, or LLM context integration.
---

# Python MCP SDK Best Practices

The Model Context Protocol (MCP) Python SDK (`mcp` on PyPI) provides the canonical Python implementation for building servers and clients that connect LLMs to external data and tools in a standardized way.

## Installation

Use uv (recommended) or pip:

```bash
uv add "mcp[cli]"
# or
pip install "mcp[cli]"
```

Requires Python ≥ 3.10. The `[cli]` extra adds the `mcp` CLI for development tooling.

## Three Primitives

MCP servers expose three primitives to LLM clients:

| Primitive | Analogy | Purpose |
|-----------|---------|---------|
| **Resources** | GET endpoint | Load data into LLM context (read-only) |
| **Tools** | POST endpoint | Execute actions, produce side effects |
| **Prompts** | Template | Reusable interaction patterns for LLMs |

Choose the right primitive for each capability:
- Use **Resources** for data retrieval that has no side effects.
- Use **Tools** for operations that compute, write, or call external APIs.
- Use **Prompts** for structured instruction templates clients can invoke by name.

## FastMCP — The High-Level API

`FastMCP` is the primary interface. It wraps the low-level protocol and handles connection management, message routing, and serialization automatically.

### Server Initialization

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP(
    "MyServer",
    stateless_http=True,   # recommended for production HTTP
    json_response=True,    # recommended for scalability
)
```

Always name servers descriptively — the name appears in client UIs and logs.

### Defining Tools

Annotate function parameters and return types. FastMCP generates JSON Schema from type hints automatically.

```python
from pydantic import BaseModel, Field

class WeatherData(BaseModel):
    temperature: float = Field(description="Temperature in Celsius")
    condition: str
    humidity: float

@mcp.tool()
def get_weather(city: str, unit: str = "celsius") -> WeatherData:
    """Get current weather for a city.

    Returns structured weather data validated against WeatherData schema.
    """
    # Implementation calls a real weather API
    return WeatherData(temperature=22.5, condition="sunny", humidity=45.0)
```

Key rules for tools:
- Write clear, descriptive docstrings — LLMs use them to decide when to call the tool.
- Use Pydantic `BaseModel` return types for structured output; the schema is exposed to clients.
- Use `TypedDict` or `dataclass` as lighter alternatives when full Pydantic validation is not needed.
- Prefer `async def` for I/O-bound tools to avoid blocking the event loop.
- Add `ctx: Context` parameter last when progress reporting or logging is needed.

### Defining Resources

```python
@mcp.resource("file://documents/{name}")
def read_document(name: str) -> str:
    """Read a document by name from the document store."""
    # Read from disk, DB, or cache
    return f"Content of {name}"

@mcp.resource("config://settings")
def get_settings() -> str:
    """Return current application settings as JSON."""
    return '{"theme": "dark", "debug": false}'
```

Resources must be idempotent and free of significant side effects. Use URI templates (`{param}`) for dynamic resources.

### Defining Prompts

```python
from mcp.server.fastmcp.prompts import base

@mcp.prompt(title="Code Review")
def review_code(code: str, language: str = "python") -> list[base.Message]:
    """Generate a structured code review prompt."""
    return [
        base.UserMessage(f"Please review this {language} code:"),
        base.UserMessage(f"```{language}\n{code}\n```"),
        base.AssistantMessage("I'll analyze the code for correctness, style, and potential issues."),
    ]
```

## Context Object

Inject `ctx: Context` into any tool or resource function to access MCP capabilities. FastMCP injects it automatically — it does not appear in the tool's JSON Schema.

```python
from mcp.server.fastmcp import Context, FastMCP
from mcp.server.session import ServerSession

@mcp.tool()
async def long_running_task(
    task_name: str,
    steps: int,
    ctx: Context[ServerSession, None],
) -> str:
    """Run a multi-step task with progress reporting."""
    await ctx.info(f"Starting task: {task_name}")

    for i in range(steps):
        await ctx.report_progress(
            progress=(i + 1) / steps,
            total=1.0,
            message=f"Step {i + 1} of {steps}",
        )

    await ctx.info("Task complete")
    return f"Completed {task_name}"
```

Context capabilities:

| Method | Purpose |
|--------|---------|
| `await ctx.info(msg)` | Send info log to client |
| `await ctx.debug(msg)` | Send debug log |
| `await ctx.warning(msg)` | Send warning log |
| `await ctx.error(msg)` | Send error log |
| `await ctx.report_progress(progress, total, message)` | Report numeric progress |
| `await ctx.read_resource(uri)` | Read another resource from within a tool |
| `await ctx.elicit(message, schema)` | Request structured input from the user |
| `ctx.request_id` | Unique ID for current request |
| `ctx.fastmcp` | Access server instance metadata |

## Lifespan — Managing Shared Resources

Use the lifespan pattern for database connections, HTTP clients, or any resource that must be initialized once and shared across requests.

```python
from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from dataclasses import dataclass

import httpx
from mcp.server.fastmcp import Context, FastMCP

@dataclass
class AppState:
    http_client: httpx.AsyncClient

@asynccontextmanager
async def lifespan(server: FastMCP) -> AsyncIterator[AppState]:
    async with httpx.AsyncClient() as client:
        yield AppState(http_client=client)

mcp = FastMCP("MyServer", lifespan=lifespan)

@mcp.tool()
async def fetch_url(url: str, ctx: Context) -> str:
    """Fetch content from a URL using the shared HTTP client."""
    state: AppState = ctx.request_context.lifespan_context
    response = await state.http_client.get(url)
    return response.text
```

Always type the lifespan context with a `@dataclass` or `TypedDict` — this provides IDE support and avoids attribute lookup errors at runtime.

## Error Handling

Raise standard Python exceptions in tools — MCP transmits them as structured error responses.

```python
@mcp.tool()
def divide(a: float, b: float) -> float:
    """Divide a by b."""
    if b == 0:
        raise ValueError("Division by zero is not allowed")
    return a / b
```

For tools that can return partial results, use `CallToolResult` directly:

```python
from mcp.types import CallToolResult, TextContent

@mcp.tool()
def safe_parse(data: str) -> CallToolResult:
    """Parse data, returning errors inline rather than raising."""
    try:
        result = parse(data)
        return CallToolResult(
            content=[TextContent(type="text", text=str(result))]
        )
    except ParseError as exc:
        return CallToolResult(
            content=[TextContent(type="text", text=f"Parse failed: {exc}")],
            isError=True,
        )
```

Use `isError=True` to signal tool-level failures that should not halt the LLM's reasoning.

## Quick Reference

```bash
# Start dev server with MCP Inspector
uv run mcp dev server.py

# Install to Claude Desktop
uv run mcp install server.py --name "My Server"

# Run with extra dependencies
uv run mcp dev server.py --with pandas --with numpy

# Run production HTTP server (uvicorn)
uvicorn server:mcp.streamable_http_app --host 0.0.0.0 --port 8000
```

| Pattern | Recommendation |
|---------|---------------|
| Transport (production) | Streamable HTTP with `stateless_http=True, json_response=True` |
| Transport (local/stdio) | stdio via `mcp.run()` or `uv run mcp run server.py` |
| I/O tools | Use `async def` |
| Shared state | Use lifespan context |
| Structured output | Return Pydantic `BaseModel` subclass |
| Progress reporting | Use `ctx.report_progress()` |
| Secrets/config | Pass via environment variables, not hardcoded |

## Additional Resources

- **`references/server-patterns.md`** — Advanced patterns: structured output, elicitation, sampling, notifications, authentication, and mounting multiple servers.
- **`references/transports-and-deployment.md`** — Transport comparison (stdio vs SSE vs Streamable HTTP), CORS, ASGI mounting, and production deployment checklist.
