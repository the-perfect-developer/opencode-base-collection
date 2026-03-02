# Tools and Sessions — Google ADK Reference

Detailed guidance on function tools, built-in tools, session state, artifacts, and memory services.

## Table of Contents

- [Function Tool Patterns](#function-tool-patterns)
- [Tool Return Values](#tool-return-values)
- [ToolContext](#toolcontext)
- [Built-in Tools](#built-in-tools)
- [Long-Running Tools](#long-running-tools)
- [Session State](#session-state)
- [Artifacts](#artifacts)
- [Memory Services](#memory-services)
- [Tool Schema Best Practices](#tool-schema-best-practices)

---

## Function Tool Patterns

### Basic Function Tool

ADK wraps Python functions automatically. The function signature and docstring define the tool's JSON schema:

```python
def search_products(
    query: str,
    category: str = "all",
    max_results: int = 10,
) -> dict:
    """Search the product catalog.

    Args:
        query: Search terms to match against product names and descriptions.
        category: Product category filter. Use "all" for no filter.
        max_results: Maximum number of results to return (1-100).

    Returns:
        dict with keys:
            status: "success" or "error"
            products: list of matching products
            total_count: total number of matching products
    """
    results = db.search(query, category, max_results)
    return {
        "status": "success",
        "products": [p.to_dict() for p in results],
        "total_count": len(results),
    }
```

### Explicit FunctionTool Wrapping

Wrap explicitly when custom metadata is needed:

```python
from google.adk.tools import FunctionTool

tool = FunctionTool(
    func=search_products,
    name="product_search",           # override function name
    description="Search products.",  # override docstring
)

agent = LlmAgent(name="shop_agent", tools=[tool])
```

### Class-Based Tools

For tools that share state or dependencies, implement a class with a `__call__` method or use `FunctionTool` with a bound method:

```python
class DatabaseTool:
    def __init__(self, connection_string: str):
        self.db = connect(connection_string)

    def query(self, sql: str, limit: int = 100) -> dict:
        """Execute a read-only SQL query.

        Args:
            sql: SELECT statement to execute.
            limit: Maximum rows to return.

        Returns:
            dict with keys: status, rows, row_count
        """
        rows = self.db.execute(sql, limit)
        return {"status": "success", "rows": rows, "row_count": len(rows)}

db_tool = DatabaseTool("postgresql://...")
agent = LlmAgent(
    name="data_agent",
    tools=[FunctionTool(func=db_tool.query, name="query_database")],
)
```

---

## Tool Return Values

### Return `dict` Always

ADK wraps non-dict returns as `{"result": value}`. Return `dict` explicitly for clarity:

```python
# Good — clear structure
return {"status": "success", "count": 42, "items": [...]}

# Acceptable but less informative
return 42   # becomes {"result": 42}

# Avoid — model may not understand failure
return None  # becomes {"result": null}
```

### Always Include `status`

Use `"success"` or `"error"` as the `status` value. This gives the LLM a clear signal:

```python
def risky_operation(id: str) -> dict:
    """Perform a risky operation."""
    try:
        result = do_thing(id)
        return {"status": "success", "result": result}
    except NotFoundError:
        return {"status": "error", "error_code": "NOT_FOUND",
                "message": f"Record {id!r} does not exist."}
    except PermissionError:
        return {"status": "error", "error_code": "FORBIDDEN",
                "message": "Insufficient permissions for this operation."}
```

### Make Results Human-Readable

The LLM reads tool results to decide what to do next. Descriptive results improve reasoning:

```python
# Poor — LLM can't reason about "200"
return {"status": 200}

# Good — LLM understands the outcome
return {
    "status": "success",
    "message": "Order #1234 has been cancelled. Refund of $49.99 will be processed in 3-5 business days.",
    "refund_amount": 49.99,
    "refund_eta_days": 5,
}
```

---

## ToolContext

`ToolContext` is injected automatically when a tool function declares it as a parameter. It provides access to session state, artifacts, and escalation.

```python
from google.adk.tools import ToolContext

def my_tool(query: str, tool_context: ToolContext) -> dict:
    """Example tool using ToolContext."""
    # Read state
    user_id = tool_context.state.get("user:id")

    # Write state
    tool_context.state["temp:last_query"] = query

    # Read artifact
    doc = tool_context.load_artifact("uploaded_document")

    # Save artifact
    tool_context.save_artifact("processed_output", processed_data)

    # Trigger loop exit (in LoopAgent context)
    if is_done(query):
        tool_context.escalate()

    return {"status": "success"}
```

### ToolContext API Summary

| Method / Property | Description |
|---|---|
| `tool_context.state` | Session state dict (read/write) |
| `tool_context.load_artifact(name)` | Load artifact by name |
| `tool_context.save_artifact(name, data)` | Save artifact |
| `tool_context.escalate()` | Signal LoopAgent to stop |
| `tool_context.agent_name` | Name of the current agent |
| `tool_context.session_id` | Current session ID |

---

## Built-in Tools

ADK provides several ready-made tools:

### Google Search

```python
from google.adk.tools import google_search

agent = LlmAgent(
    name="search_agent",
    model="gemini-2.5-flash",
    tools=[google_search],
)
```

### Code Execution

```python
from google.adk.tools import built_in_code_execution

agent = LlmAgent(
    name="coder",
    model="gemini-2.5-flash",
    tools=[built_in_code_execution],
)
```

### Vertex AI Search

```python
from google.adk.tools.retrieval import VertexAiSearchTool

search_tool = VertexAiSearchTool(
    data_store_id="projects/my-project/locations/global/collections/default_collection/dataStores/my-store"
)
```

### BigQuery Tool

```python
from google.adk.tools import BigQueryTool

bq_tool = BigQueryTool(project_id="my-project", dataset_id="my_dataset")
```

---

## Long-Running Tools

Wrap asynchronous or long-duration operations with `LongRunningFunctionTool`:

```python
from google.adk.tools import LongRunningFunctionTool
import asyncio

async def run_batch_analysis(dataset_id: str) -> dict:
    """Run batch analysis on a dataset. May take several minutes.

    Args:
        dataset_id: ID of the dataset to analyze.

    Returns:
        dict with keys: status, job_id, results_url
    """
    job = await submit_batch_job(dataset_id)
    result = await job.wait()   # waits until complete
    return {
        "status": "success",
        "job_id": job.id,
        "results_url": result.url,
    }

batch_tool = LongRunningFunctionTool(func=run_batch_analysis)

agent = LlmAgent(name="analyst", tools=[batch_tool])
```

The agent will poll for completion and resume when the tool finishes.

---

## Session State

### State Hierarchy

ADK supports four scopes, controlled by key prefix:

```
session.state = {
    # Persistent (no prefix) — lives for the session duration
    "conversation_topic": "Python debugging",

    # User-level (user: prefix) — persists across sessions for the same user
    "user:name": "Alice",
    "user:preferences": {"language": "English", "timezone": "UTC"},

    # App-level (app: prefix) — shared across all users and sessions
    "app:version": "2.1.0",
    "app:feature_flags": {"new_ui": True},

    # Temporary (temp: prefix) — cleared at the end of each turn
    "temp:search_results": [...],
    "temp:draft": "...",
}
```

### Accessing State from Tools

```python
def greet_user(tool_context: ToolContext) -> dict:
    """Generate a personalized greeting."""
    name = tool_context.state.get("user:name", "there")
    topic = tool_context.state.get("conversation_topic", "our discussion")
    return {
        "status": "success",
        "greeting": f"Hello {name}! Let's continue with {topic}.",
    }
```

### Accessing State from Instructions

State values are resolved at instruction render time:

```python
instruction = """
You are helping {user:name} with {conversation_topic}.
User preferences: language={user:preferences.language}, timezone={user:preferences.timezone}
Search results from this turn: {temp:search_results}
"""
```

### State Initialization

Set initial state when creating a runner:

```python
from google.adk.runners import Runner

runner = Runner(
    agent=root_agent,
    app_name="my_app",
    session_service=session_service,
)

session = await runner.session_service.create_session(
    app_name="my_app",
    user_id="user_123",
    state={
        "user:name": "Alice",
        "user:account_tier": "premium",
        "app:version": "2.1.0",
    },
)
```

---

## Artifacts

Artifacts store binary or large text data (files, images, documents) outside of state.

### Saving and Loading Artifacts

```python
def process_document(filename: str, tool_context: ToolContext) -> dict:
    """Process an uploaded document."""
    # Load a previously uploaded artifact
    raw_doc = tool_context.load_artifact(filename)
    if raw_doc is None:
        return {"status": "error", "message": f"Artifact {filename!r} not found."}

    processed = extract_text(raw_doc)

    # Save the result as a new artifact
    tool_context.save_artifact(
        name="processed_text",
        artifact=processed.encode("utf-8"),
        mime_type="text/plain",
    )
    return {"status": "success", "character_count": len(processed)}
```

### Referencing Artifacts in Instructions

```python
instruction = """
Process the document provided by the user.
The uploaded document is available as artifact: {artifact.uploaded_document}
"""
```

---

## Memory Services

ADK supports pluggable memory for long-term recall across sessions.

### In-Memory (Development)

```python
from google.adk.memory import InMemoryMemoryService

memory_service = InMemoryMemoryService()
```

### Vertex AI Memory (Production)

```python
from google.adk.memory import VertexAiMemoryService

memory_service = VertexAiMemoryService(
    project="my-project",
    location="us-central1",
)
```

### Using Memory in an Agent

```python
from google.adk.tools import load_memory, save_to_memory

agent = LlmAgent(
    name="personal_assistant",
    model="gemini-2.5-flash",
    tools=[load_memory, save_to_memory],
    instruction="""
    You are a personal assistant with memory.
    - Use `load_memory` to recall past conversations.
    - Use `save_to_memory` to store important facts about the user.
    """,
)
```

---

## Tool Schema Best Practices

### Avoid `*args` and `**kwargs`

ADK cannot generate a schema for variadic parameters. Only fixed, typed parameters appear in the tool schema:

```python
# Bad — variadic args ignored
def bad_tool(*args, **kwargs) -> dict: ...

# Good — explicit typed parameters
def good_tool(query: str, limit: int = 10, filter_type: str = "all") -> dict: ...
```

### Use Enums for Constrained Values

```python
from typing import Literal

def set_priority(
    task_id: str,
    priority: Literal["low", "medium", "high", "critical"],
) -> dict:
    """Set task priority.

    Args:
        task_id: The task identifier.
        priority: Priority level: low, medium, high, or critical.
    """
    ...
```

### Document Units and Formats

```python
def schedule_reminder(
    message: str,
    delay_seconds: int,
    recurrence_days: int = 0,
) -> dict:
    """Schedule a reminder message.

    Args:
        message: Reminder text to send.
        delay_seconds: Delay before first reminder, in seconds (e.g., 3600 = 1 hour).
        recurrence_days: Days between recurring reminders. 0 means no recurrence.
    """
    ...
```

### Keep Tool Count Reasonable

Each tool increases the context window. Guidelines:
- Fewer than 20 tools per agent is a good target
- Group related operations (read/write/delete on same resource) into one tool with an `action` parameter, or split into separate specialized agents
- Remove tools the agent never uses

### Tool Naming Conventions

- Use `verb_noun` style: `search_products`, `create_order`, `get_user_profile`
- Be consistent with the domain vocabulary
- Avoid generic names: `process`, `handle`, `do_thing`
