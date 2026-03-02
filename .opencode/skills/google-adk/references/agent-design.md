# Agent Design — Google ADK Reference

Detailed guidance on LLM agent configuration, multi-agent orchestration, and advanced patterns.

## Table of Contents

- [LLM Agent Configuration](#llm-agent-configuration)
- [Instructions Deep Dive](#instructions-deep-dive)
- [Structured Output](#structured-output)
- [Planners](#planners)
- [Multi-Agent Orchestration](#multi-agent-orchestration)
- [Agent Transfer Patterns](#agent-transfer-patterns)
- [Pipeline Composition Patterns](#pipeline-composition-patterns)
- [Agent Lifecycle and Callbacks](#agent-lifecycle-and-callbacks)

---

## LLM Agent Configuration

### Full Field Reference

```python
from google.adk.agents import LlmAgent
from google.genai.types import GenerateContentConfig

agent = LlmAgent(
    # Identity
    name="my_agent",                    # required; unique, snake_case
    description="What this agent does", # shown to parent agents for routing
    model="gemini-2.5-flash",           # Gemini model string

    # Behavior
    instruction="...",                  # system prompt (most critical)
    tools=[tool_a, tool_b],             # list of tools

    # Output
    output_key="result",                # write response to session.state["result"]
    output_schema=MyPydanticModel,      # enforce structured JSON output

    # Context
    include_contents="default",         # "default" or "none" (stateless)

    # Model config
    generate_content_config=GenerateContentConfig(
        temperature=0.2,
        max_output_tokens=4096,
    ),

    # Hierarchy
    sub_agents=[child_agent_1, child_agent_2],

    # Callbacks
    before_agent_callback=my_before_fn,
    after_agent_callback=my_after_fn,
    before_tool_callback=my_tool_validator,
    after_tool_callback=my_tool_logger,
)
```

### Name and Description

**`name`** is used as the agent's identifier when other agents perform `transfer_to_agent`. Keep names:
- Unique within the agent hierarchy
- Descriptive but concise (`order_processor`, not `agent1`)
- Consistent with the domain vocabulary

**`description`** is injected into the parent agent's context for routing. Write it as a capability statement:
- ✓ `"Searches Google and returns structured citations for research queries."`
- ✗ `"This agent helps with search."` (too vague)

### Model Selection

| Model | Best For |
|---|---|
| `gemini-2.5-flash` | Fast, cost-efficient tasks; most use cases |
| `gemini-2.5-pro` | Complex reasoning, long context, coding |
| `gemini-2.0-flash` | Real-time / streaming use cases |

Use different models for different agents in the same pipeline based on task complexity.

### `include_contents`

- `"default"` — conversation history is passed to the model (stateful)
- `"none"` — no history is passed; agent only sees current instructions and inputs (stateless)

Use `"none"` for pure transformation agents (e.g., a formatter that only needs the current document, not conversation history).

---

## Instructions Deep Dive

The `instruction` field is the primary lever for agent behavior. A well-written instruction is more impactful than any other configuration.

### Structure

```
[Role definition]
[Behavioral rules]
[Tool guidance]
[State variable usage]
[Output format requirements]
[Few-shot examples (if needed)]
```

### State Variable Injection

ADK resolves `{key}` placeholders in instructions at runtime using `session.state`:

```python
instruction="""
You are a support agent for {company_name}.
The current user's account tier is: {user:account_tier}.
Their open tickets: {temp:open_tickets}.
"""
```

Artifact values are injected via `{artifact.artifact_name}`.

### Tool Guidance in Instructions

Be explicit about when to use each tool:

```
## Tool Usage
- Use `search_web(query)` when the user asks about current events or recent news.
- Use `lookup_database(id)` when the user provides an account ID or order number.
- Do NOT call both tools on the same question; choose the most appropriate one.
- After calling a tool, always summarize the result before responding.
```

### Few-Shot Examples in Instructions

Few-shot examples are the most effective way to shape output format:

```
## Examples

User: "Summarize this article: ..."
Response:
{
  "headline": "...",
  "key_points": ["...", "..."],
  "sentiment": "neutral"
}

User: "What is the capital of France?"
Response:
{
  "headline": "Paris",
  "key_points": ["Capital since 987 AD", "Population 2.1M"],
  "sentiment": "neutral"
}
```

### Dynamic Instructions

Use a callable for instructions that change per-session:

```python
def build_instruction(context) -> str:
    user_lang = context.state.get("user:language", "English")
    return f"Always respond in {user_lang}. You are a helpful assistant."

agent = LlmAgent(
    name="localized_agent",
    model="gemini-2.5-flash",
    instruction=build_instruction,
)
```

---

## Structured Output

### Using `output_schema`

```python
from pydantic import BaseModel, Field
from typing import List

class ResearchReport(BaseModel):
    title: str = Field(description="Report title")
    sections: List[str] = Field(description="Section headings")
    confidence: float = Field(ge=0.0, le=1.0, description="Confidence score 0-1")
    sources: List[str] = Field(default_factory=list)

agent = LlmAgent(
    name="reporter",
    model="gemini-2.5-flash",
    output_schema=ResearchReport,
    output_key="report",  # written to session.state["report"] as JSON
)
```

Downstream agents access it via:
```python
instruction="Expand on this report: {report}"
```

### Constraints

- Do **not** combine `output_schema` with `tools` unless using Gemini 3.0+ (the model cannot call tools while constrained to a schema).
- The output is serialized to JSON; nested Pydantic models work correctly.
- `output_key` without `output_schema` writes the raw text response to state.

---

## Planners

Planners give agents the ability to reason before acting — useful for complex, multi-step tasks.

### `BuiltInPlanner`

Uses Gemini's native thinking capability. Requires a thinking-capable model:

```python
from google.adk.planners import BuiltInPlanner

agent = LlmAgent(
    name="thinking_agent",
    model="gemini-2.5-flash",   # thinking-capable
    instruction="...",
    planner=BuiltInPlanner(thinking_budget=8192),  # token budget for thinking
)
```

### `PlanReActPlanner`

Implements plan → act → observe → reason cycle for non-thinking models:

```python
from google.adk.planners import PlanReActPlanner

agent = LlmAgent(
    name="react_agent",
    model="gemini-2.5-flash",
    planner=PlanReActPlanner(max_iterations=10),
)
```

Use `PlanReActPlanner` when:
- The task requires multiple tool calls with intermediate reasoning
- The model is not a native thinking model
- Deterministic step tracking is needed

---

## Multi-Agent Orchestration

### Parent-Child Hierarchy

The `sub_agents` field establishes the hierarchy. Each agent can have exactly one parent. ADK enforces this at initialization time.

```
orchestrator
├── research_agent
│   └── web_search_agent
├── analysis_agent
└── writer_agent
```

```python
web_search_agent = LlmAgent(name="web_search_agent", ...)
research_agent = LlmAgent(name="research_agent", sub_agents=[web_search_agent], ...)
writer_agent = LlmAgent(name="writer_agent", ...)
analysis_agent = LlmAgent(name="analysis_agent", ...)

orchestrator = LlmAgent(
    name="orchestrator",
    sub_agents=[research_agent, analysis_agent, writer_agent],
)
```

### Sharing State Across Agents

All agents in a session share the same `session.state`. Use naming conventions to avoid collisions:

```python
# research_agent writes:
output_key = "research:findings"

# analysis_agent reads:
instruction = "Analyze these findings: {research:findings}"

# writer_agent reads:
instruction = "Write a report on: {research:findings}\nAnalysis: {analysis:summary}"
```

---

## Agent Transfer Patterns

### LLM-Driven Transfer

The orchestrator calls `transfer_to_agent(agent_name="...")` automatically based on its routing logic. For reliable routing:

1. Write specific, differentiated `description` values for every sub-agent.
2. In the orchestrator's instruction, list each agent and when to use it.
3. Avoid overlapping descriptions.

```python
orchestrator = LlmAgent(
    name="orchestrator",
    instruction="""
    Route user requests:
    - Billing questions → billing_agent
    - Technical issues → tech_support_agent
    - General questions → faq_agent
    """,
    sub_agents=[billing_agent, tech_support_agent, faq_agent],
)
```

### AgentTool for Explicit Invocation

Use `AgentTool` when the orchestrator must invoke a sub-agent as a tool call (synchronous, explicit):

```python
from google.adk.tools import AgentTool

summarizer_tool = AgentTool(agent=summarizer_agent)

orchestrator = LlmAgent(
    name="orchestrator",
    tools=[summarizer_tool, other_tool],
    instruction="Use `summarizer_agent` tool to summarize long documents before storing them.",
)
```

`AgentTool` vs `sub_agents`:
- `sub_agents` → LLM decides when to transfer; control passes fully to sub-agent
- `AgentTool` → LLM calls it like a function; result returns to caller immediately

---

## Pipeline Composition Patterns

### Sequential with State Threading

Pass outputs through a pipeline by chaining `output_key` → `{state_key}`:

```python
pipeline = SequentialAgent(
    name="document_pipeline",
    sub_agents=[
        LlmAgent(
            name="extractor",
            instruction="Extract key facts from the document.",
            output_key="facts",
        ),
        LlmAgent(
            name="analyst",
            instruction="Analyze these facts and identify risks: {facts}",
            output_key="risk_analysis",
        ),
        LlmAgent(
            name="summarizer",
            instruction="Write an executive summary based on:\nFacts: {facts}\nRisks: {risk_analysis}",
            output_key="executive_summary",
        ),
    ],
)
```

### Parallel Fan-Out / Fan-In

Run parallel agents then aggregate results in a sequential step:

```python
from google.adk.agents import SequentialAgent, ParallelAgent

fan_out = ParallelAgent(
    name="parallel_search",
    sub_agents=[
        LlmAgent(name="web_searcher",   ..., output_key="web_results"),
        LlmAgent(name="news_searcher",  ..., output_key="news_results"),
        LlmAgent(name="arxiv_searcher", ..., output_key="arxiv_results"),
    ],
)

aggregator = LlmAgent(
    name="aggregator",
    instruction="""
    Combine and deduplicate results from:
    - Web: {web_results}
    - News: {news_results}
    - Academic: {arxiv_results}
    """,
    output_key="combined_results",
)

full_pipeline = SequentialAgent(
    name="full_search_pipeline",
    sub_agents=[fan_out, aggregator],
)
```

### Iterative Refinement Loop

```python
from google.adk.agents import LoopAgent

refiner = LoopAgent(
    name="draft_refiner",
    max_iterations=3,
    sub_agents=[
        LlmAgent(
            name="drafter",
            instruction="Improve this draft: {current_draft}",
            output_key="current_draft",
        ),
        LlmAgent(
            name="critic",
            instruction="""
            Rate this draft on a scale 1-10: {current_draft}
            If score >= 8, respond with exactly: DONE
            Otherwise, list specific improvements.
            """,
            output_key="critique",
        ),
    ],
)
```

To exit the loop early, a sub-agent raises an escalation event:

```python
from google.adk.events import Event

def check_quality(draft: str, tool_context: ToolContext) -> dict:
    """Exit loop if quality threshold met."""
    score = evaluate_quality(draft)
    if score >= 8:
        tool_context.escalate()   # terminates LoopAgent
    return {"status": "success", "score": score}
```

---

## Agent Lifecycle and Callbacks

Callbacks allow hooking into agent execution at specific points:

| Callback | Trigger | Common Use |
|---|---|---|
| `before_agent_callback` | Before agent runs | Auth checks, context setup |
| `after_agent_callback` | After agent completes | Logging, metrics |
| `before_tool_callback` | Before each tool call | Argument validation, rate limiting |
| `after_tool_callback` | After each tool call | Result logging, transformation |

```python
def before_tool_callback(tool_name: str, args: dict, tool_context: ToolContext):
    """Validate and log tool invocations."""
    print(f"[TOOL] {tool_name}({args})")
    if tool_name == "delete_record":
        if not args.get("confirmed"):
            raise ValueError("delete_record requires confirmed=True")

def after_tool_callback(tool_name: str, result: dict, tool_context: ToolContext):
    """Log tool results."""
    tool_context.state[f"temp:last_{tool_name}_result"] = result

agent = LlmAgent(
    name="safe_agent",
    ...,
    before_tool_callback=before_tool_callback,
    after_tool_callback=after_tool_callback,
)
```
