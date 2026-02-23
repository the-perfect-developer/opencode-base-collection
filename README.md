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

Essential collection of agents, skills, and commands for OpenCode - the AI-powered coding assistant.

**📚 [Complete Tools Reference](docs/tools-reference.md)** - Browse all available agents, skills, and commands

## Quick Start

Install core agents, skills, and commands with a single command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/the-perfect-developer/opencode-base-collection/main/scripts/install.sh)
```

This installs:
- **Core Agents**: Specialized AI assistants (architect, frontend-engineer, backend-engineer, junior-engineer, security-expert, performance-engineer)
- **Essential Skills**: Domain-specific workflows (skill-creation, command-creation, rules-creation, agent-configuration, git-hooks, github-actions, conventional-git-commit)
- **Useful Commands**: Custom slash commands for common tasks

### Manage Your Tools

After initial installation, use these commands anytime to manage your OpenCode tools:

**Install Perfect Tools:**
```
/install-perfect-tool specific for my project
```
Install specific agents, skills, or commands from "The Perfect OpenCode" repository. You can request any combination of resources.

**Update Perfect Tools:**
```
/update-perfect-tool
```
Update all installed agents, skills, and commands to their latest versions from the repository.

### On-The-Go Tool Installation

OpenCode intelligently suggests and installs tools as you work:

When you use `/extended-planning` or other workflow commands, the LLM automatically:
- **Analyzes your requirements** to identify needed agents, skills, and commands
- **Suggests relevant tools** from "The Perfect OpenCode" repository
- **Offers to install** missing resources on the fly
- **Auto-installs** recommended tools with your confirmation

**Example:**
```
> /extended-planning build a REST API with authentication

OpenCode detects you need:
- agent:backend-engineer (for API implementation)
- agent:security-expert (for auth review)
- skill:typescript-style (for code standards)
- command:git-stage-commit-push (for workflow)

Would you like to install these tools?
```

This ensures you always have the right tools for your task without manual catalog browsing.

For detailed installation options and advanced usage, see [Installation Guide](docs/installation-guide.md).

## Workflow

### Planning Features

Use the `/extended-planning` command for comprehensive feature planning:

```
/extended-planning build a real-time chat feature with typing indicators
```

This command:
- Uses the **@architect** agent to design system architecture
- Consults **@security-expert** for security considerations
- Involves **@performance-engineer** for scalability planning
- Leverages planning skills to create detailed implementation roadmaps
- Produces structured plans with requirements, architecture, and task breakdown

### Implementing Features

Use the `/implement` command to execute implementation plans:

```
/implement [plan-file-or-description]
```

This command:
- Coordinates specialized agents (@frontend-engineer, @backend-engineer, @junior-engineer)
- Automatically routes tasks based on complexity and domain
- Leverages domain-specific skills for best practices
- Executes implementation in logical sequence
- Validates work using testing and quality skills

### How Commands Use Agents and Skills

OpenCode's workflow commands orchestrate agents and skills intelligently:

**Planning Workflow** (`/extended-planning`):
1. **@architect** uses design pattern skills to create system architecture
2. **@security-expert** applies security audit skills to identify risks
3. **@performance-engineer** uses optimization skills for scalability planning
4. Skills like `conventional-git-commit` ensure standardized documentation

**Implementation Workflow** (`/implement`):
1. **@frontend-engineer** uses framework skills (alpinejs, htmx, tailwind-css) for UI
2. **@backend-engineer** applies language skills (python, go, typescript-style) for APIs
3. **@junior-engineer** handles simple tasks using code style skills
4. All agents use `git-hooks` and `github-actions` skills for quality control

### Creating Custom Resources

Extend OpenCode with custom agents, skills, and commands:

**Create Custom Agents** - Build specialized AI assistants:
```
/create-agent
```
- Configure model, temperature, and tool permissions
- Define agent focus and capabilities
- Set up agent prompts and descriptions
- Control when agents are automatically invoked

**Create Custom Skills** - Add domain-specific workflows:
```
/create-skill
```
- Build reusable instruction sets with progressive disclosure
- Bundle resources (scripts, references, examples)
- Define trigger phrases for automatic loading
- Create project-local or global skills

**Create Custom Commands** - Automate repetitive tasks:
```
/create-command
```
- Define slash commands with dynamic arguments
- Integrate shell command output into prompts
- Route commands to specific agents or models
- Configure markdown or JSON-based commands

## Features

- **Agent System** - Specialized AI assistants for different development domains
- **Skill Library** - Domain-specific instruction sets and workflows
- **Command Creation** - Custom slash commands for automation
- **Rules Configuration** - Project conventions and coding standards
- **Git Integration** - Hooks, conventional commits, and GitHub Actions

## Agents & Specialists

The Perfect OpenCode includes 6 specialized agents that work together during planning and implementation:

- **@architect** - System design and architectural decisions
- **@frontend-engineer** - UI/UX implementation and accessibility
- **@backend-engineer** - APIs, databases, and business logic
- **@junior-engineer** - Quick fixes and straightforward tasks
- **@security-expert** - Security audits and threat modeling
- **@performance-engineer** - Performance analysis and optimization

**For complete agent details, capabilities, and use cases, see [Tools Reference](docs/tools-reference.md#agents)**

### Using Agents

Agents are automatically invoked during workflows like `/extended-planning` and `/implement`, or you can invoke them manually:

```
@frontend-engineer build a dark mode toggle
@backend-engineer implement pagination for the products API
@security-expert review this authentication code
```

## The Perfect OpenCode Core Skills

Skills provide domain-specific guidance and workflows that agents can load automatically. The collection includes 27+ skills covering programming languages, frameworks, tools, and development workflows.

**For complete skills list and descriptions, see [Tools Reference](docs/tools-reference.md#skills)**

### Key Skills for Customization

**skill-creation** - Create reusable, discoverable skills with specialized workflows
- Build modular instruction sets
- Bundle resources (scripts, references, examples)
- Implement progressive disclosure
- Define automatic triggering

**command-creation** - Create custom slash commands for repetitive tasks
- Define reusable prompts with `/command-name`
- Pass dynamic arguments
- Integrate shell command output
- Route to specific agents or models

**rules-creation** - Configure custom instructions for project conventions
- Define project standards
- Document architecture patterns
- Set coding preferences
- Create global or project-specific rules

**agent-configuration** - Configure and customize OpenCode agents
- Create specialized agents
- Customize permissions and capabilities
- Define agent personalities
- Set up multi-agent coordination

### Framework & Language Skills

The collection includes skills for: TypeScript, JavaScript, Python, Go, CSS, HTML, Markdown, JSON, Next.js, React, Nuxt, Alpine.js, HTMX, Tailwind CSS, Flet, and more.

### Development Workflow Skills

**conventional-git-commit** - Standardized commit messages
**git-hooks** - Git hook implementation and validation
**github-actions** - CI/CD workflow automation
**planning** - Comprehensive implementation planning
**implementation** - Orchestrated feature implementation

## Commands

The Perfect OpenCode includes 10+ slash commands for common workflows.

**For complete commands list, see [Tools Reference](docs/tools-reference.md#commands)**

### Essential Commands for Development

**`/extended-planning`** - Comprehensive feature planning
```
/extended-planning build a real-time chat feature
```
- Gathers requirements through interactive questions
- Uses @architect for system design
- Consults @security-expert and @performance-engineer
- Creates detailed implementation roadmap
- Produces structured plan with architecture and task breakdown

**`/implement`** - Execute implementation plans
```
/implement [plan-file-or-description]
```
- Coordinates specialized agents (@frontend-engineer, @backend-engineer, @junior-engineer)
- Routes tasks based on complexity and domain
- Applies domain-specific skills and best practices
- Executes implementation in logical sequence
- Validates work with testing and quality checks

### Tool Management Commands

**`/install-perfect-tools`** - Install agents, skills, or commands for your project
**`/update-perfect-tools`** - Update installed tools to latest versions

### Customization Commands

**`/create-agent`** - Create custom agents with interactive configuration
**`/create-skill`** - Create custom skills with proper structure
**`/create-command`** - Create custom slash commands

### Git Workflow Commands

**`/git-stage-commit-push`** - Stage, commit, and push with conventional commits
**`/git-commit-push`** - Commit and push changes
**`/git-push`** - Push commits to remote

## Installation Locations

After installation, resources are organized in:
- **Agents**: `.opencode/agents/` - Specialized AI assistants
- **Skills**: `.opencode/skills/` - Domain-specific workflows
- **Commands**: `.opencode/commands/` - Custom slash commands

Directories are automatically created during installation.

## Contributing

Interested in contributing? Check out our [Contributing Guide](CONTRIBUTING.md) for:
- Development setup instructions
- Git hooks and code quality tools
- Pull request guidelines
- CI/CD information

## Author

**Dilan D Chandrajith** - [The Perfect Developer](https://github.com/the-perfect-developer)

## License

MIT License - See [LICENSE](LICENSE) file for details.
