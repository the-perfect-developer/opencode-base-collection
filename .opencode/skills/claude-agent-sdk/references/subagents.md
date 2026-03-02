# Subagents Reference — Claude Agent SDK

Subagents are separate agent instances spawned by a parent agent to handle focused subtasks in isolation.

## Table of Contents

- [Why Use Subagents](#why-use-subagents)
- [Defining Subagents](#defining-subagents)
- [AgentDefinition Fields](#agentdefinition-fields)
- [Invoking Subagents](#invoking-subagents)
- [Tool Restrictions](#tool-restrictions)
- [Detecting Subagent Messages](#detecting-subagent-messages)
- [Resuming Subagents](#resuming-subagents)
- [Parallelisation Pattern](#parallelisation-pattern)
- [Troubleshooting](#troubleshooting)

## Why Use Subagents

| Benefit | Description |
|---------|-------------|
| Context isolation | Subagent context is separate — search results don't pollute the main conversation |
| Parallelisation | Multiple subagents run concurrently, reducing wall-clock time |
| Specialisation | Each subagent carries focused instructions and tool restrictions |
| Safety | Subagents can be limited to read-only tools even when the parent has write access |

**Important**: subagents cannot spawn their own subagents. Do not include `Task` in a subagent's `tools` array.

## Defining Subagents

Define subagents in the `agents` parameter. `Task` must be in the parent's `allowed_tools`:

```python
from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition

async for message in query(
    prompt="Review the auth module for security issues",
    options=ClaudeAgentOptions(
        allowed_tools=["Read", "Glob", "Grep", "Task"],
        agents={
            "code-reviewer": AgentDefinition(
                description="Expert code review specialist. Use for quality, security, and maintainability reviews.",
                prompt="""You are a code review specialist with expertise in security and performance.

When reviewing code:
- Identify security vulnerabilities and injection risks
- Flag performance anti-patterns
- Check error handling completeness
- Suggest specific, actionable improvements""",
                tools=["Read", "Grep", "Glob"],
                model="sonnet",
            ),
        },
    ),
):
    if hasattr(message, "result"):
        print(message.result)
```

```typescript
for await (const message of query({
  prompt: "Review the auth module for security issues",
  options: {
    allowedTools: ["Read", "Glob", "Grep", "Task"],
    agents: {
      "code-reviewer": {
        description: "Expert code review specialist. Use for quality, security, and maintainability reviews.",
        prompt: `You are a code review specialist with expertise in security and performance.

When reviewing code:
- Identify security vulnerabilities and injection risks
- Flag performance anti-patterns
- Check error handling completeness
- Suggest specific, actionable improvements`,
        tools: ["Read", "Grep", "Glob"],
        model: "sonnet"
      }
    }
  }
})) {
  if ("result" in message) console.log(message.result);
}
```

## AgentDefinition Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `description` | `string` | Yes | When to use this agent. Write as Claude would read it. |
| `prompt` | `string` | Yes | System prompt defining the subagent's role and constraints |
| `tools` | `string[]` | No | Allowed tools. Omit to inherit all parent tools. |
| `model` | `'sonnet' \| 'opus' \| 'haiku' \| 'inherit'` | No | Model override. Defaults to parent model. |

**Description writing rules**:
- Write in third person: "Expert code reviewer..." not "You are a code reviewer..."
- Be specific about when to invoke: "Use for security and maintainability reviews"
- Claude matches tasks to subagents based on this field alone

**Prompt writing rules**:
- Use imperative form: "Identify vulnerabilities" not "You should identify"
- List concrete actions, not vague guidance
- Include constraints: "Do not modify files", "Report findings only"

## Invoking Subagents

### Automatic invocation

Claude reads each `description` and decides which subagent to invoke:

```
# Parent prompt that triggers automatic delegation
"Review this codebase for security issues and run all tests"
# → Claude invokes "code-reviewer" then "test-runner" based on descriptions
```

### Explicit invocation

Name the subagent in the prompt to guarantee its selection:

```
"Use the code-reviewer agent to check auth.py for SQL injection vulnerabilities"
```

Prefer explicit invocation in production workflows to avoid ambiguous routing.

### Dynamic subagent factory

Create subagents with runtime configuration:

```python
def create_security_agent(level: str) -> AgentDefinition:
    is_strict = level == "strict"
    return AgentDefinition(
        description="Security code reviewer",
        prompt=f"You are a {'strict' if is_strict else 'balanced'} security reviewer...",
        tools=["Read", "Grep", "Glob"],
        model="opus" if is_strict else "sonnet",
    )

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Grep", "Glob", "Task"],
    agents={"security-reviewer": create_security_agent("strict")},
)
```

## Tool Restrictions

Subagents can be limited to specific tools independent of the parent:

| Use case | Tools |
|----------|-------|
| Read-only analysis | `Read`, `Grep`, `Glob` |
| Test execution | `Bash`, `Read`, `Grep` |
| Code modification | `Read`, `Edit`, `Write`, `Grep`, `Glob` |
| Inherit all | Omit `tools` field |

**Best practice**: always restrict subagent tools to the minimum needed. A subagent running a test suite needs `Bash`, `Read`, and `Grep` — it does not need `Write` or `Edit`.

```python
"test-runner": AgentDefinition(
    description="Runs test suites and reports failures.",
    prompt="Run tests, capture output, identify failures, suggest fixes.",
    tools=["Bash", "Read", "Grep"],  # no Edit or Write
)
```

## Detecting Subagent Messages

Subagents are invoked via the `Task` tool. Messages from within a subagent include `parent_tool_use_id`:

```python
async for message in query(...):
    if hasattr(message, "content"):
        for block in message.content:
            if getattr(block, "type", None) == "tool_use" and block.name == "Task":
                print(f"Subagent invoked: {block.input.get('subagent_type')}")

    if hasattr(message, "parent_tool_use_id") and message.parent_tool_use_id:
        print("  (message is from inside a subagent)")
```

```typescript
for await (const message of query({ ... })) {
  const msg = message as any;
  for (const block of msg.message?.content ?? []) {
    if (block.type === "tool_use" && block.name === "Task") {
      console.log(`Subagent invoked: ${block.input.subagent_type}`);
    }
  }
  if (msg.parent_tool_use_id) {
    console.log("  (message is from inside a subagent)");
  }
}
```

## Resuming Subagents

Subagent transcripts persist within their session. Resume by:

1. Capture `session_id` from the result message
2. Extract `agentId` from the Task tool result content
3. Pass `resume=session_id` in the next query and reference the agent ID in the prompt

```python
import re, json

session_id = None
agent_id = None

async for message in query(prompt="Use the Explore agent to map all API endpoints", options=...):
    if hasattr(message, "session_id"):
        session_id = message.session_id
    if hasattr(message, "content"):
        content_str = json.dumps(message.content, default=str)
        match = re.search(r"agentId:\s*([a-f0-9-]+)", content_str)
        if match:
            agent_id = match.group(1)

# Resume in a follow-up query
if agent_id and session_id:
    async for message in query(
        prompt=f"Resume agent {agent_id} and list the 3 most complex endpoints",
        options=ClaudeAgentOptions(allowed_tools=["Task"], resume=session_id),
    ):
        if hasattr(message, "result"):
            print(message.result)
```

**Note**: the `resume` session ID must match the session where the subagent ran. Each `query()` call creates a new session unless `resume` is set.

## Parallelisation Pattern

Multiple subagents run concurrently when invoked by the parent in the same turn. Structure the parent prompt to request parallel work:

```
"Simultaneously:
1. Use the security-scanner agent to check auth.py for vulnerabilities
2. Use the style-checker agent to review auth.py for PEP 8 compliance
3. Use the test-runner agent to run the auth module tests
Report all findings together."
```

Use distinct, non-overlapping `description` fields so Claude selects the correct agent for each task without ambiguity.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Claude doesn't delegate to subagent | `Task` not in parent `allowed_tools` | Add `"Task"` to `allowed_tools` |
| Wrong subagent chosen | Ambiguous descriptions | Make descriptions specific; use explicit invocation |
| Filesystem agent not loading | Agent defined after session start | Restart session after adding `.claude/agents/*.md` files |
| Subagent requests permission repeatedly | Subagents don't inherit parent permissions | Use `PreToolUse` hooks to auto-approve specific tools |
| Recursive hook loops | `UserPromptSubmit` hook spawns subagents that trigger same hook | Guard with a subagent check before spawning |
| Windows: subagent launch fails | Command line length limit (8191 chars) | Keep prompts concise or use filesystem-based agents |
