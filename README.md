# The Perfect OpenCode

```
  _____ _            ____            __           _   
 |_   _| |__   ___  |  _ \ ___ _ __ / _| ___  ___| |_ 
   | | | '_ \ / _ \ | |_) / _ \ '__| |_ / _ \/ __| __|
   | | | | | |  __/ |  __/  __/ |  |  _|  __/ (__| |_ 
   |_| |_| |_|\___| |_|   \___|_|  |_|  \___|\___|\__|
                                                       
   ___                   ___          _      
  / _ \ _ __   ___ _ __ / __\___   __| | ___ 
 | | | | '_ \ / _ \ '_ / /  / _ \ / _` |/ _ \
 | |_| | |_) |  __/ | | /__| (_) | (_| |  __/
  \___/| .__/ \___|_| \____/\___/ \__,_|\___|
       |_|                                    

By Dilan D Chandrajith - The Perfect Developer
```

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenCode](https://img.shields.io/badge/OpenCode-Skills-blue.svg)](https://opencode.ai)
[![Maintenance](https://img.shields.io/badge/Maintained-yes-brightgreen.svg)](https://github.com/the-perfect-developer/opencode-base-collection/commits/main)

A curated collection of agents, skills, and commands for [OpenCode](https://opencode.ai) — with a streamlined process to install, update, and extend your AI-powered development environment.

**[Complete Tools Reference](docs/tools-reference.md)**

---

## Installation

Install the core collection with a single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh)
```

This installs specialized agents, domain-specific skills, and workflow commands into your project's `.opencode/` directory.

> For LLMs assisting with setup, see [Installation Guide](docs/installation-guide.md).

---

## Tool Management

After the initial install, use these commands to manage your tools from within OpenCode:

**`/install-perfect-tools`** — Guides you through discovering and installing agents, skills, and commands tailored to your project's stack and workflow.

**`/update-perfect-tools`** — Compares your installed tools against the latest catalog and updates any that have changed.

**`/recommend-perfect-tool`** — Silently analyzes your project (languages, frameworks, CI config) and recommends tools you haven't installed yet — no questions asked.

---

## Development Workflow

### Quick Tasks (Plan + Implement in One Shot)

For tasks where you want planning and implementation to happen without interruption, use `/quickee`:

```
/quickee add a dark mode toggle to the settings page
```

`/quickee` runs on the `build` agent and combines planning and implementation into a single flow:

1. **Clarify** — asks focused questions if the task is ambiguous, then stops asking
2. **Plan** — consults @code-analyst, @architect, @security-expert, and @performance-engineer in parallel to produce a concise plan
3. **Implement** — immediately executes the plan using @backend-engineer, @frontend-engineer, and @junior-engineer in parallel

No manual handoff between `/plan` and `/implement` — ideal for well-scoped tasks where you want fast, structured output.

### Lightweight Tasks

For everyday features where you want to review the plan before implementation:

```
/plan    build a user authentication flow
/implement
```

`/plan` gathers requirements and produces an implementation plan. `/implement` executes it using the appropriate specialized agents.

### Complex Features

For larger features that require architectural input, security review, or performance analysis, use the extended workflow:

```
/extended-plan    build a real-time notification system
/extended-implement
```

`/extended-plan` runs a six-phase planning process: requirement gathering, codebase analysis, research, multi-agent consultation (@architect, @security-expert, @performance-engineer), plan generation, and user review.

`/extended-implement` runs a seven-phase orchestrated implementation: requirements analysis, task breakdown, parallel agent execution, quality assurance, testing, and final documentation. Agents are selected by task type — @frontend-engineer for UI, @backend-engineer for APIs, @junior-engineer for simple fixes — and independent tasks run in parallel.

---

## Customization Commands

Extend OpenCode with your own resources:

**`/create-rule`** — Adds a `MUST FOLLOW` rule to your project's `AGENTS.md`, keeping coding standards and conventions enforced across all agents.

**`/create-agent`** — Interactive agent builder. Configures model, temperature, tool permissions, and system prompt, then writes the agent file to `.opencode/agents/`.

**`/create-skill`** — Scaffolds a new skill with proper frontmatter, progressive disclosure structure, and validation guidance.

**`/create-command`** — Walks through requirements and generates a slash command in `.opencode/commands/` with the correct frontmatter, argument handling, and agent routing.

---

## Author

**Dilan D Chandrajith** — [The Perfect Developer](https://github.com/the-perfect-developer)

## License

MIT License — See [LICENSE](LICENSE) for details.
