---
description: Plan then immediately implement — efficient agent-driven workflow for any task
agent: build
agents:
  - general
  - explore
  - code-analyst
  - security-expert
  - performance-engineer
  - architect
  - backend-engineer
  - frontend-engineer
  - junior-engineer
---

$1

## Phase 1 — Clarify & Plan

If the task is ambiguous or missing critical details, ask the user focused clarifying questions before proceeding — keep them minimal and only ask what is truly necessary to avoid wrong assumptions.

Once requirements are clear, create a concise implementation plan. Invoke specialist subagents in parallel where useful — @code-analyst for understanding unfamiliar code, @architect for design decisions, @security-expert for security implications, @performance-engineer for performance considerations.

Keep the plan brief and actionable — no lengthy prose, just what is needed to implement confidently.

## Phase 2 — Implement

Immediately execute the plan without waiting for user confirmation. Use @backend-engineer, @frontend-engineer, and @junior-engineer for coding tasks — invoke them in parallel where possible. During implementation, consult @architect, @security-expert, or @performance-engineer in parallel if questions arise.

Deliver working, complete output.
