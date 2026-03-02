---
name: google-adk
description: This skill should be used when the user asks to "build an agent with Google ADK", "use the Agent Development Kit", "create a Google ADK agent", "set up ADK tools", or needs guidance on Google's Agent Development Kit best practices, multi-agent systems, or agent evaluation.
---

# Google Agent Development Kit (ADK)

Google ADK is a Python framework for building, orchestrating, and evaluating LLM-powered agents. It provides structured patterns for single agents, multi-agent pipelines, custom tools, session state, safety controls, and evaluation.

## Core Concepts

### LLM Agent

The fundamental building block is `LlmAgent` (aliased as `Agent`):

```python
from google.adk.agents import LlmAgent

agent = LlmAgent(
    name="research_agent",          # unique, snake_case
    model="gemini-2.5-flash",
    description="Searches and summarizes research papers.",  # used for multi-agent routing
    instruction="You are a research assistant. ...",         # most critical field
    tools=[search_tool, summarize_tool],
)
```

Key fields:

| Field | Purpose |
|---|---|
| `name` | Unique identifier; used for agent transfer |
| `description` | Shown to parent agents for routing decisions |
| `model` | Gemini model string (e.g. `gemini-2.5-flash`) |
| `instruction` | System prompt — the most critical field |
| `tools` | List of callable tools or `FunctionTool` instances |
| `output_key` | Write agent response to `session.state[key]` |
| `output_schema` | Pydantic model for structured JSON output |
| `include_contents` | `'default'` or `'none'` (stateless agents) |

### Instructions

Instructions are the most important configuration. Write them clearly:

- Use markdown formatting (headers, bullets, code blocks)
- Provide few-shot examples for complex behaviors
- Guide tool selection explicitly: "Use `search_tool` when the user asks about..."
- Inject state values with `{state_key}` or artifact values with `{artifact.name}`
- Keep instructions specific and task-scoped; avoid generic prompts

```python
instruction="""
You are a customer support agent for Acme Corp.

## Behavior
- Greet the user by name using {user_name}
- For billing questions, always use `lookup_invoice` before responding
- Escalate to human if sentiment is negative three times in a row

## Examples
User: "What's my balance?"
Action: Call lookup_invoice(account_id="{account_id}")
""",
```

### Structured Output

Use `output_schema` when a downstream step requires machine-readable JSON:

```python
from pydantic import BaseModel

class Report(BaseModel):
    title: str
    summary: str
    confidence: float

agent = LlmAgent(
    ...,
    output_schema=Report,
    output_key="report",     # writes JSON to session.state["report"]
)
```

Avoid combining `output_schema` with `tools` unless using Gemini 3.0+.

## Function Tools

Python functions are automatically wrapped as tools. The docstring becomes the tool description — write it carefully.

```python
def get_weather(city: str, units: str = "celsius") -> dict:
    """Get current weather for a city.

    Args:
        city: The city name to look up.
        units: Temperature units, either 'celsius' or 'fahrenheit'.

    Returns:
        dict with keys: temperature, condition, humidity.
    """
    # implementation ...
    return {"temperature": 22, "condition": "sunny", "humidity": 60}
```

Rules:

- **Required params**: typed, no default → model must supply them
- **Optional params**: typed with default or `Optional[T] = None`
- **Return type**: always `dict`; include a `"status"` key (`"success"` / `"error"`)
- **`*args` / `**kwargs`**: ignored by ADK schema generation — avoid them
- Make return values descriptive; the LLM reads them to decide next steps

### Passing Data Between Tools

Use `session.state` with the `temp:` prefix for transient inter-tool data:

```python
from google.adk.tools import ToolContext

def store_result(data: str, tool_context: ToolContext) -> dict:
    """Store intermediate result for downstream tools."""
    tool_context.state["temp:last_result"] = data
    return {"status": "success"}

def read_result(tool_context: ToolContext) -> dict:
    """Read the stored intermediate result."""
    value = tool_context.state.get("temp:last_result", "")
    return {"status": "success", "result": value}
```

### Long-Running and Agent Tools

```python
from google.adk.tools import LongRunningFunctionTool, AgentTool

# Wrap async/long-running operations
slow_tool = LongRunningFunctionTool(func=run_batch_job)

# Invoke a sub-agent as an explicit tool call
sub_agent_tool = AgentTool(agent=specialist_agent)
```

## Multi-Agent Systems

### Hierarchy

Compose agents using `sub_agents`. Each agent can have only one parent.

```python
orchestrator = LlmAgent(
    name="orchestrator",
    model="gemini-2.5-flash",
    instruction="Route tasks to the appropriate specialist.",
    sub_agents=[research_agent, writer_agent, reviewer_agent],
)
```

### Sequential Pipeline

`SequentialAgent` runs sub-agents in order. Pass data via `output_key` → `{state_key}`:

```python
from google.adk.agents import SequentialAgent

pipeline = SequentialAgent(
    name="report_pipeline",
    sub_agents=[
        LlmAgent(name="researcher", ..., output_key="research_notes"),
        LlmAgent(name="writer",
                 instruction="Write a report based on: {research_notes}",
                 output_key="draft"),
        LlmAgent(name="reviewer",
                 instruction="Review this draft: {draft}"),
    ],
)
```

### Parallel Pipeline

`ParallelAgent` runs sub-agents concurrently. Use distinct `output_key` values to avoid race conditions:

```python
from google.adk.agents import ParallelAgent

parallel = ParallelAgent(
    name="multi_search",
    sub_agents=[
        LlmAgent(name="web_searcher",   ..., output_key="web_results"),
        LlmAgent(name="doc_searcher",   ..., output_key="doc_results"),
        LlmAgent(name="db_searcher",    ..., output_key="db_results"),
    ],
)
```

### Loop Pipeline

`LoopAgent` repeats until `max_iterations` is reached or a sub-agent raises `escalate=True`:

```python
from google.adk.agents import LoopAgent

refiner = LoopAgent(
    name="refinement_loop",
    max_iterations=5,
    sub_agents=[draft_agent, critic_agent],
)
```

### LLM-Driven Transfer

An LLM agent can transfer control by calling `transfer_to_agent(agent_name="...")`. For this to work reliably, every agent must have a clear `description` field.

## Session State

Session state is a `dict` persisted across turns. Keys follow naming conventions:

| Prefix | Scope | Example |
|---|---|---|
| *(none)* | Persistent across session | `"user_name"` |
| `temp:` | Current turn only | `"temp:search_results"` |
| `user:` | User-level across sessions | `"user:preferences"` |
| `app:` | Application-level global | `"app:config"` |

Access state from tools via `ToolContext`, from agents via `{state_key}` in instructions.

## Safety

### In-Tool Guardrails

Use `ToolContext` to enforce policies deterministically before the LLM sees results:

```python
def sensitive_lookup(query: str, tool_context: ToolContext) -> dict:
    """Look up sensitive records."""
    if not tool_context.state.get("user:verified"):
        return {"status": "error", "message": "User not verified."}
    # proceed with lookup ...
```

### Callbacks

Use `before_tool_callback` to validate tool arguments before execution:

```python
from google.adk.tools import ToolContext

def validate_args(tool_name: str, args: dict, tool_context: ToolContext):
    if tool_name == "delete_record" and not args.get("confirm"):
        raise ValueError("delete_record requires confirm=True")

agent = LlmAgent(..., before_tool_callback=validate_args)
```

### Built-in Safety

Configure Gemini's content filters via `generate_content_config`:

```python
from google.genai.types import GenerateContentConfig, SafetySetting, HarmCategory, HarmBlockThreshold

agent = LlmAgent(
    ...,
    generate_content_config=GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=2048,
        safety_settings=[
            SafetySetting(
                category=HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
                threshold=HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
            )
        ],
    ),
)
```

## Evaluation

ADK supports two evaluation file formats:

| Format | File | Use |
|---|---|---|
| Unit tests | `.test.json` | Single-turn, deterministic assertions |
| Integration tests | `.evalset.json` | Multi-turn conversation flows |

Run evaluations:

```bash
# Launch interactive web UI
adk web

# CLI evaluation
adk eval path/to/agent path/to/tests.evalset.json

# pytest integration
pytest tests/ -k "eval"
```

Key metrics:

| Metric | Description |
|---|---|
| `tool_trajectory_avg_score` | Exact match on tool call sequence |
| `response_match_score` | ROUGE-1 similarity to expected response |
| `final_response_match_v2` | LLM-based semantic match |
| `hallucinations_v1` | Detects fabricated facts |
| `safety_v1` | Flags safety violations |

## Quick Reference

**Install**:
```bash
pip install google-adk
```

**Minimal agent**:
```python
from google.adk.agents import LlmAgent

agent = LlmAgent(
    name="my_agent",
    model="gemini-2.5-flash",
    instruction="You are a helpful assistant.",
)
```

**Run locally**:
```bash
adk web          # web UI
adk run          # CLI interactive
adk api_server   # REST API server
```

**Planners** (for complex reasoning):
- `BuiltInPlanner` — uses Gemini's native thinking capability
- `PlanReActPlanner` — plan→act→reason loop for non-thinking models

## Additional Resources

- **`references/agent-design.md`** — Detailed LLM agent configuration, multi-agent patterns, and orchestration strategies
- **`references/tools-and-sessions.md`** — Function tool patterns, session state management, artifacts, and memory
- **`references/safety-and-evaluation.md`** — Safety architecture, guardrail patterns, and evaluation framework details
