# MCP Transports and Deployment

Complete reference for MCP transport options, CORS configuration, ASGI integration, and production deployment.

## Table of Contents

- [Transport Overview](#transport-overview)
- [stdio Transport](#stdio-transport)
- [Streamable HTTP Transport](#streamable-http-transport)
- [SSE Transport (Legacy)](#sse-transport-legacy)
- [CORS for Browser Clients](#cors-for-browser-clients)
- [ASGI Mounting Patterns](#asgi-mounting-patterns)
- [Production Deployment Checklist](#production-deployment-checklist)
- [Development Workflow](#development-workflow)

---

## Transport Overview

| Transport | Use Case | Stateful | Scalable |
|-----------|----------|----------|----------|
| **stdio** | Local tools, Claude Desktop, CLI | Yes | No (single process) |
| **Streamable HTTP** | Production web services | Optional | Yes (stateless mode) |
| **SSE** | Legacy clients only | Yes | Limited |

**Decision guide**:
- Local development or Claude Desktop integration → **stdio**
- Production HTTP service with multiple clients → **Streamable HTTP** (`stateless_http=True`)
- Legacy client compatibility only → **SSE** (avoid for new work)

---

## stdio Transport

stdio is the simplest transport: server reads from stdin, writes to stdout. Used by Claude Desktop and the `mcp` CLI.

### Starting a stdio Server

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("MyServer")

@mcp.tool()
def greet(name: str) -> str:
    """Greet someone."""
    return f"Hello, {name}!"

if __name__ == "__main__":
    mcp.run()  # defaults to stdio
```

```bash
# Run directly
python server.py

# Run via mcp CLI (recommended for development)
uv run mcp run server.py

# Install to Claude Desktop
uv run mcp install server.py --name "My Server"
uv run mcp install server.py -v API_KEY=secret -f .env
```

### stdio Client Connection

```python
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

server_params = StdioServerParameters(
    command="python",
    args=["server.py"],
    env={"API_KEY": "value"},  # env vars passed to server process
)

async with stdio_client(server_params) as (read, write):
    async with ClientSession(read, write) as session:
        await session.initialize()
        result = await session.call_tool("greet", {"name": "World"})
```

---

## Streamable HTTP Transport

Streamable HTTP is the recommended transport for production. It supports both stateful sessions and a stateless request-per-call mode.

### Stateless Mode (Recommended for Production)

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP(
    "ProductionServer",
    stateless_http=True,   # each request is independent
    json_response=True,    # return JSON, not SSE streams
)

@mcp.tool()
def compute(x: int, y: int) -> int:
    """Compute x + y."""
    return x + y

if __name__ == "__main__":
    mcp.run(transport="streamable-http")
```

Stateless mode advantages:
- Horizontally scalable — no shared session state between instances
- Works with load balancers and serverless platforms
- No sticky sessions required
- Lower memory footprint

### Stateful Mode (Session Persistence)

```python
mcp = FastMCP("StatefulServer")  # stateless_http=False by default
```

Use stateful mode when:
- Tools maintain in-memory state across calls within a session
- Session-scoped resources (e.g., open file handles, cursors) are needed
- The client expects `Mcp-Session-Id` header persistence

### Configuration Options

```python
mcp = FastMCP(
    "MyServer",
    stateless_http=True,
    json_response=True,
    host="0.0.0.0",          # bind address
    port=8000,                # port number
    streamable_http_path="/mcp",  # path suffix (default: /mcp)
    debug=False,              # enable debug mode
    log_level="INFO",         # log verbosity
)
```

### Running with Uvicorn

For production, run with `uvicorn` instead of the built-in dev server:

```bash
# Single worker (development)
uvicorn server:mcp.streamable_http_app --host 0.0.0.0 --port 8000

# Multiple workers (production)
uvicorn server:mcp.streamable_http_app --host 0.0.0.0 --port 8000 --workers 4

# With Gunicorn + uvicorn workers
gunicorn server:mcp.streamable_http_app \
  --bind 0.0.0.0:8000 \
  --workers 4 \
  --worker-class uvicorn.workers.UvicornWorker
```

### Streamable HTTP Client Connection

```python
from mcp.client.streamable_http import streamablehttp_client
from mcp import ClientSession

async with streamablehttp_client("http://localhost:8000/mcp") as (read, write, _):
    async with ClientSession(read, write) as session:
        await session.initialize()
        tools = await session.list_tools()
```

---

## SSE Transport (Legacy)

SSE (Server-Sent Events) transport is provided for compatibility with older MCP clients. Do not use it for new servers.

```python
# SSE server (legacy — prefer Streamable HTTP)
mcp.run(transport="sse")

# SSE client
from mcp.client.sse import sse_client

async with sse_client("http://localhost:8000/sse") as (read, write):
    async with ClientSession(read, write) as session:
        await session.initialize()
```

---

## CORS for Browser Clients

Browser-based MCP clients require explicit CORS headers, including exposure of the `Mcp-Session-Id` response header.

```python
from starlette.applications import Starlette
from starlette.middleware.cors import CORSMiddleware
from starlette.routing import Mount
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("BrowserServer", stateless_http=True, json_response=True)

# Build the base ASGI app
base_app = Starlette(routes=[Mount("/mcp", mcp.streamable_http_app())])

# Wrap with CORS middleware
app = CORSMiddleware(
    base_app,
    allow_origins=["https://my-client.example.com"],  # restrict in production
    allow_methods=["GET", "POST", "DELETE"],
    allow_headers=["Content-Type", "Authorization", "Mcp-Session-Id"],
    expose_headers=["Mcp-Session-Id"],  # required for browser clients
)
```

Without `expose_headers=["Mcp-Session-Id"]`, browsers cannot read the session ID from initialization responses, and stateful connections will fail.

---

## ASGI Mounting Patterns

### Single Server on Existing App

Mount an MCP server alongside existing routes in a Starlette, FastAPI, or Django application:

```python
from fastapi import FastAPI
from starlette.routing import Mount
from mcp.server.fastmcp import FastMCP
import contextlib

api = FastAPI()
mcp_server = FastMCP("APICompanion", stateless_http=True, json_response=True)

@mcp_server.tool()
def describe_api() -> str:
    """Describe the available REST API endpoints."""
    return "GET /items, POST /items, DELETE /items/{id}"

# Mount MCP under /mcp path
@contextlib.asynccontextmanager
async def lifespan(app):
    async with mcp_server.session_manager.run():
        yield

api.router.lifespan_context = lifespan
api.mount("/mcp", mcp_server.streamable_http_app())
```

### Multiple Servers with Shared Lifespan

```python
import contextlib
from starlette.applications import Starlette
from starlette.routing import Mount
from mcp.server.fastmcp import FastMCP

search = FastMCP("SearchServer", stateless_http=True, json_response=True)
catalog = FastMCP("CatalogServer", stateless_http=True, json_response=True)

@contextlib.asynccontextmanager
async def lifespan(app: Starlette):
    async with contextlib.AsyncExitStack() as stack:
        await stack.enter_async_context(search.session_manager.run())
        await stack.enter_async_context(catalog.session_manager.run())
        yield

app = Starlette(
    routes=[
        Mount("/search", search.streamable_http_app()),
        Mount("/catalog", catalog.streamable_http_app()),
    ],
    lifespan=lifespan,
)
```

### Path Configuration

By default each server appends `/mcp` to its mount path. Configure with:

```python
# Server serves at /search (not /search/mcp)
search.settings.streamable_http_path = "/"

# Server serves at /search/v2
search.settings.streamable_http_path = "/v2"
```

---

## Production Deployment Checklist

### Server Configuration

- [ ] Use `stateless_http=True` and `json_response=True` for horizontal scalability
- [ ] Bind to `0.0.0.0` or a specific interface, not `127.0.0.1`
- [ ] Set `debug=False` in production
- [ ] Configure `log_level` appropriately (`"WARNING"` or `"ERROR"` in production)
- [ ] Use `uvicorn` or `gunicorn` with uvicorn workers — not the built-in dev server
- [ ] Pass secrets via environment variables, never hardcode in server code

### Security

- [ ] Enable authentication (`token_verifier` + `AuthSettings`) for any publicly accessible server
- [ ] Restrict CORS origins to known clients — never use `allow_origins=["*"]` in production
- [ ] Validate and sanitize all tool inputs, even with type annotations
- [ ] Use rate limiting at the reverse proxy layer (nginx, Caddy, or cloud load balancer)
- [ ] Log all tool invocations for audit trail

### Reliability

- [ ] Wrap shared I/O resources (DB connections, HTTP clients) in the lifespan pattern
- [ ] Use connection pooling for database connections
- [ ] Add health check endpoint (e.g., mount a simple Starlette route at `/healthz`)
- [ ] Implement graceful shutdown — uvicorn handles SIGTERM correctly with the session manager lifespan
- [ ] Set `max_tokens` appropriately when using sampling to avoid runaway LLM calls

### Observability

- [ ] Structured logging with request IDs (`ctx.request_id` available in tools)
- [ ] Export metrics (invocation count, latency, error rate) via Prometheus or OTEL
- [ ] Trace tool calls end-to-end with distributed tracing if using multiple services

---

## Development Workflow

### MCP Inspector (Recommended)

The MCP Inspector is a browser-based UI for testing servers interactively:

```bash
# Start server in dev mode (auto-restarts on file changes)
uv run mcp dev server.py

# Start server with extra deps
uv run mcp dev server.py --with pandas --with requests

# Open inspector in a new terminal
npx -y @modelcontextprotocol/inspector
# Connect to http://localhost:8000/mcp in the inspector UI
```

### Testing with pytest

```python
import pytest
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("TestServer")

@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two integers."""
    return a + b

def test_add_tool():
    # Call the underlying function directly for unit tests
    result = add(2, 3)
    assert result == 5

@pytest.mark.anyio
async def test_add_via_client():
    """Integration test using in-process client."""
    from mcp import ClientSession
    from mcp.client.stdio import stdio_client, StdioServerParameters
    import sys

    # For full integration tests, spawn the server as a subprocess
    # or use the in-memory transport available in mcp.testing
    pass
```

For integration testing, the SDK provides an in-memory transport:

```python
from mcp.server.fastmcp import FastMCP
from mcp.shared.memory import create_connected_server_and_client_session

async def test_server_integration():
    mcp = FastMCP("Test")

    @mcp.tool()
    def echo(msg: str) -> str:
        return msg

    async with create_connected_server_and_client_session(mcp._mcp_server) as client:
        result = await client.call_tool("echo", {"msg": "hello"})
        assert result.content[0].text == "hello"
```

### Environment Variables

```bash
# Common configuration via env vars
FASTMCP_HOST=0.0.0.0
FASTMCP_PORT=8000
FASTMCP_LOG_LEVEL=INFO
FASTMCP_DEBUG=false
```

The `FastMCP` class reads `FASTMCP_*` prefixed env vars automatically via Pydantic Settings.
