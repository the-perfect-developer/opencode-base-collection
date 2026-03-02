# Safety and Evaluation — Google ADK Reference

Detailed guidance on safety architecture, guardrail patterns, and the ADK evaluation framework.

## Table of Contents

- [Safety Architecture Overview](#safety-architecture-overview)
- [Authentication Patterns](#authentication-patterns)
- [In-Tool Guardrails](#in-tool-guardrails)
- [Callback-Based Validation](#callback-based-validation)
- [Built-in Gemini Safety](#built-in-gemini-safety)
- [Plugins and Cross-Agent Policies](#plugins-and-cross-agent-policies)
- [Sandboxed Code Execution](#sandboxed-code-execution)
- [Evaluation Framework](#evaluation-framework)
- [Evaluation File Formats](#evaluation-file-formats)
- [Evaluation Metrics](#evaluation-metrics)
- [Running Evaluations](#running-evaluations)
- [User Simulation Testing](#user-simulation-testing)

---

## Safety Architecture Overview

ADK safety operates at multiple layers:

```
Request
  │
  ├─ [1] Authentication & Authorization
  │       (identity verification, permission checks)
  │
  ├─ [2] Before-Tool Callbacks
  │       (argument validation before tool execution)
  │
  ├─ [3] In-Tool Guardrails
  │       (policy enforcement inside tool logic)
  │
  ├─ [4] Gemini Safety Filters
  │       (content moderation on model output)
  │
  └─ [5] Output Sanitization
          (escape HTML/JS before rendering in UI)
```

Defense-in-depth: apply controls at multiple layers rather than relying on any single mechanism.

---

## Authentication Patterns

### Agent-Auth (Service Account)

The agent authenticates as itself using a service account. Use for server-to-server calls where the agent's identity is what matters:

```python
from google.oauth2 import service_account
from google.adk.tools import FunctionTool

credentials = service_account.Credentials.from_service_account_file(
    "service-account.json",
    scopes=["https://www.googleapis.com/auth/cloud-platform"],
)

def call_internal_api(endpoint: str, payload: dict) -> dict:
    """Call an internal API using service account credentials."""
    response = authenticated_request(endpoint, payload, credentials)
    return {"status": "success", "data": response}
```

### User-Auth (OAuth Token Delegation)

The agent acts on behalf of the user using their OAuth token. Use when actions should be scoped to the user's permissions:

```python
from google.adk.tools import ToolContext

def access_user_drive(filename: str, tool_context: ToolContext) -> dict:
    """Access a file in the user's Google Drive."""
    user_token = tool_context.state.get("user:oauth_token")
    if not user_token:
        return {
            "status": "error",
            "error_code": "UNAUTHENTICATED",
            "message": "User must authorize Google Drive access first.",
        }
    content = drive_client.get_file(filename, token=user_token)
    return {"status": "success", "content": content}
```

### Permission Checks in State

Store permission flags in session state and check them in tools:

```python
REQUIRED_PERMISSIONS = {
    "delete_record": "admin",
    "export_data": "data_manager",
    "view_reports": "viewer",
}

def check_permission(tool_name: str, tool_context: ToolContext) -> bool:
    """Return True if the current user has permission for the tool."""
    required_role = REQUIRED_PERMISSIONS.get(tool_name, "viewer")
    user_role = tool_context.state.get("user:role", "guest")
    role_hierarchy = ["guest", "viewer", "data_manager", "admin"]
    return role_hierarchy.index(user_role) >= role_hierarchy.index(required_role)
```

---

## In-Tool Guardrails

Implement policy enforcement deterministically inside tool functions rather than relying on the LLM to self-restrict.

### Pattern: Permission Gate

```python
from google.adk.tools import ToolContext

def delete_record(record_id: str, tool_context: ToolContext) -> dict:
    """Delete a record permanently.

    Args:
        record_id: ID of the record to delete.

    Returns:
        dict with keys: status, deleted_id
    """
    # Permission gate — checked before any destructive action
    if not tool_context.state.get("user:can_delete"):
        return {
            "status": "error",
            "error_code": "FORBIDDEN",
            "message": "User does not have delete permission.",
        }

    # Rate limiting gate
    delete_count = tool_context.state.get("temp:delete_count", 0)
    if delete_count >= 10:
        return {
            "status": "error",
            "error_code": "RATE_LIMITED",
            "message": "Maximum 10 deletions per session.",
        }

    db.delete(record_id)
    tool_context.state["temp:delete_count"] = delete_count + 1
    return {"status": "success", "deleted_id": record_id}
```

### Pattern: Input Sanitization

```python
import re

def run_sql_query(sql: str, tool_context: ToolContext) -> dict:
    """Execute a read-only SQL query.

    Args:
        sql: SELECT statement to execute.
    """
    # Only allow SELECT statements
    normalized = sql.strip().upper()
    if not normalized.startswith("SELECT"):
        return {
            "status": "error",
            "error_code": "INVALID_QUERY",
            "message": "Only SELECT queries are permitted.",
        }

    # Block dangerous keywords
    blocked = ["DROP", "DELETE", "UPDATE", "INSERT", "ALTER", "EXEC", "EXECUTE"]
    for keyword in blocked:
        if re.search(rf"\b{keyword}\b", normalized):
            return {
                "status": "error",
                "error_code": "BLOCKED_KEYWORD",
                "message": f"Keyword '{keyword}' is not allowed.",
            }

    results = db.execute(sql)
    return {"status": "success", "rows": results, "row_count": len(results)}
```

### Pattern: PII Redaction

```python
import re

PII_PATTERNS = {
    "email": r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b",
    "ssn": r"\b\d{3}-\d{2}-\d{4}\b",
    "credit_card": r"\b(?:\d{4}[-\s]?){3}\d{4}\b",
}

def redact_pii(text: str) -> str:
    """Remove PII from text before logging or storing."""
    for label, pattern in PII_PATTERNS.items():
        text = re.sub(pattern, f"[REDACTED_{label.upper()}]", text)
    return text

def log_interaction(user_message: str, tool_context: ToolContext) -> dict:
    """Log user interaction with PII redacted."""
    safe_message = redact_pii(user_message)
    logger.info(f"Interaction: {safe_message}")
    return {"status": "success"}
```

---

## Callback-Based Validation

Use `before_tool_callback` to validate tool arguments before the tool runs:

```python
from google.adk.tools import ToolContext

SENSITIVE_TOOLS = {"delete_record", "export_all_data", "send_email_blast"}

def before_tool_callback(tool_name: str, args: dict, tool_context: ToolContext):
    """Global validation for all tool calls."""

    # Block sensitive tools for unverified users
    if tool_name in SENSITIVE_TOOLS:
        if not tool_context.state.get("user:identity_verified"):
            raise PermissionError(
                f"Tool '{tool_name}' requires identity verification. "
                "Please complete verification first."
            )

    # Log all tool invocations for auditing
    tool_context.state.setdefault("temp:tool_log", []).append({
        "tool": tool_name,
        "args": {k: "***" if "password" in k.lower() else v for k, v in args.items()},
    })

def after_tool_callback(tool_name: str, result: dict, tool_context: ToolContext):
    """Log tool results."""
    log = tool_context.state.get("temp:tool_log", [])
    if log:
        log[-1]["result_status"] = result.get("status")

agent = LlmAgent(
    name="audited_agent",
    before_tool_callback=before_tool_callback,
    after_tool_callback=after_tool_callback,
    ...
)
```

---

## Built-in Gemini Safety

Configure content filters via `generate_content_config`:

```python
from google.genai.types import (
    GenerateContentConfig,
    SafetySetting,
    HarmCategory,
    HarmBlockThreshold,
)

STRICT_SAFETY = GenerateContentConfig(
    safety_settings=[
        SafetySetting(
            category=HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            threshold=HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
        ),
        SafetySetting(
            category=HarmCategory.HARM_CATEGORY_HARASSMENT,
            threshold=HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
        ),
        SafetySetting(
            category=HarmCategory.HARM_CATEGORY_HATE_SPEECH,
            threshold=HarmBlockThreshold.BLOCK_LOW_AND_ABOVE,
        ),
        SafetySetting(
            category=HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
            threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        ),
    ]
)

agent = LlmAgent(
    name="safe_agent",
    generate_content_config=STRICT_SAFETY,
    ...
)
```

### Threshold Reference

| Threshold | Description |
|---|---|
| `BLOCK_NONE` | No blocking (use only with explicit review) |
| `BLOCK_LOW_AND_ABOVE` | Block low, medium, and high probability harm |
| `BLOCK_MEDIUM_AND_ABOVE` | Block medium and high probability harm |
| `BLOCK_HIGH_AND_ABOVE` | Block only high probability harm |
| `BLOCK_ONLY_HIGH` | Alias for `BLOCK_HIGH_AND_ABOVE` |

---

## Plugins and Cross-Agent Policies

For policies that must apply across all agents in a system, use plugins rather than repeating logic in each agent.

### Gemini-as-Judge Plugin

Uses a Gemini model to evaluate outputs before returning them to the user:

```python
from google.adk.plugins import GeminiJudgePlugin

judge = GeminiJudgePlugin(
    model="gemini-2.5-flash",
    policy="""
    Reject any response that:
    - Contains personally identifiable information
    - Makes medical, legal, or financial recommendations
    - Disparages competitors by name
    """,
)
```

### Model Armor

Vertex AI Model Armor scans prompts and responses for policy violations:

```python
from google.adk.plugins import ModelArmorPlugin

armor = ModelArmorPlugin(
    project="my-project",
    location="us-central1",
    template_name="my-safety-template",
)
```

### Applying Plugins

```python
from google.adk.runners import Runner

runner = Runner(
    agent=root_agent,
    plugins=[judge, armor],
    ...
)
```

---

## Sandboxed Code Execution

Never execute model-generated code in the host process. Use sandboxed execution:

### Vertex AI Code Interpreter

```python
from google.adk.tools import VertexCodeInterpreterTool

code_tool = VertexCodeInterpreterTool(
    project="my-project",
    location="us-central1",
)

agent = LlmAgent(
    name="data_analyst",
    tools=[code_tool],
    instruction="Write and execute Python code to analyze data. Use the code interpreter for all computations.",
)
```

### Output Sanitization

Always escape model-generated content before rendering in HTML/JS contexts:

```python
import html

def render_response(agent_response: str) -> str:
    """Safely render agent response in HTML context."""
    return html.escape(agent_response)
```

---

## Evaluation Framework

ADK provides a structured evaluation framework for testing agent behavior at unit (single-turn) and integration (multi-turn) levels.

### Evaluation Philosophy

- **Trajectory evaluation**: Did the agent call the right tools in the right order?
- **Response evaluation**: Was the final response correct and appropriate?
- **Rubric evaluation**: Does the response meet qualitative criteria?

---

## Evaluation File Formats

### Unit Test File (`.test.json`)

```json
{
  "test_cases": [
    {
      "name": "simple_weather_query",
      "input": "What's the weather in Paris?",
      "expected_tool_calls": [
        {
          "tool_name": "get_weather",
          "args": {"city": "Paris"}
        }
      ],
      "expected_response_contains": ["Paris", "temperature"]
    }
  ]
}
```

### Evalset File (`.evalset.json`)

```json
{
  "eval_set_id": "customer_support_eval",
  "eval_cases": [
    {
      "eval_id": "billing_inquiry_flow",
      "conversation": [
        {
          "invocation": {
            "user_content": {
              "parts": [{"text": "I need to check my invoice."}],
              "role": "user"
            }
          },
          "reference": {
            "expected_tool_use": [
              {
                "tool_name": "lookup_invoice",
                "tool_input": {}
              }
            ],
            "expected_final_agent_response": "I found your invoice. Your current balance is..."
          }
        },
        {
          "invocation": {
            "user_content": {
              "parts": [{"text": "Can I pay it now?"}],
              "role": "user"
            }
          },
          "reference": {
            "expected_tool_use": [
              {"tool_name": "process_payment", "tool_input": {}}
            ],
            "expected_final_agent_response": "Payment processed successfully."
          }
        }
      ]
    }
  ]
}
```

---

## Evaluation Metrics

| Metric | Type | Description |
|---|---|---|
| `tool_trajectory_avg_score` | Trajectory | Average exact match score on tool call sequence |
| `response_match_score` | Response | ROUGE-1 similarity between actual and expected response |
| `final_response_match_v2` | Response | LLM-based semantic similarity (more flexible) |
| `rubric_based_response_match` | Rubric | Response meets qualitative rubric criteria |
| `rubric_based_tool_trajectory` | Rubric | Tool sequence meets qualitative rubric |
| `hallucinations_v1` | Safety | Detects fabricated facts in response |
| `safety_v1` | Safety | Flags safety policy violations |

### Trajectory Scoring

Tool trajectory score is calculated as:
```
score = number_of_matching_tool_calls / max(expected_calls, actual_calls)
```

A score of 1.0 means the agent made exactly the right tool calls in the right order.

### Configuring Metrics

```python
from google.adk.evaluation import AgentEvaluator, EvalConfig

config = EvalConfig(
    metrics=[
        "tool_trajectory_avg_score",
        "final_response_match_v2",
        "hallucinations_v1",
    ],
    threshold={
        "tool_trajectory_avg_score": 0.8,
        "final_response_match_v2": 0.7,
    },
)
```

---

## Running Evaluations

### CLI

```bash
# Run evalset against an agent
adk eval path/to/agent path/to/tests.evalset.json

# With specific metrics
adk eval path/to/agent path/to/tests.evalset.json \
  --metrics tool_trajectory_avg_score,final_response_match_v2

# With output report
adk eval path/to/agent path/to/tests.evalset.json \
  --output report.json
```

### pytest Integration

```python
import pytest
from google.adk.evaluation import AgentEvaluator

@pytest.fixture
def evaluator():
    return AgentEvaluator(
        agent_module="my_agent.agent",
        eval_config=EvalConfig(
            metrics=["tool_trajectory_avg_score", "final_response_match_v2"],
        ),
    )

def test_weather_agent(evaluator):
    result = evaluator.evaluate("tests/weather.evalset.json")
    assert result.tool_trajectory_avg_score >= 0.9
    assert result.final_response_match_v2 >= 0.8

def test_billing_flow(evaluator):
    result = evaluator.evaluate("tests/billing.evalset.json")
    assert result.all_metrics_pass
```

### Web UI

```bash
adk web
```

The web UI provides:
- Interactive chat for manual testing
- Visual display of tool call trajectory
- Side-by-side comparison of expected vs actual behavior
- Evalset management and execution

---

## User Simulation Testing

For dynamic, multi-turn testing where expected responses vary, use User Simulation:

```python
from google.adk.evaluation import UserSimulator, SimulationConfig

simulator = UserSimulator(
    model="gemini-2.5-flash",
    persona="""
    You are a frustrated customer who recently received a damaged product.
    You want a refund but are initially skeptical. Become more cooperative
    if the agent shows empathy and provides clear next steps.
    """,
)

config = SimulationConfig(
    max_turns=10,
    success_criteria="""
    The simulation succeeds if the customer agrees to the refund process
    and expresses satisfaction before the conversation ends.
    """,
)

result = simulator.run(agent=support_agent, config=config)
assert result.success, f"Simulation failed: {result.reason}"
```

### When to Use User Simulation

- Testing agents in open-ended conversational domains
- Validating empathy and tone in support scenarios
- Stress-testing edge cases with adversarial user personas
- Replacing rigid evalsets where exact responses cannot be predetermined
