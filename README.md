# The Perfect Developer's OpenCode Base Collection

```
The Perfect Developer's
   ___                   ___          _
  / _ \ _ __   ___ _ __ / __\___   __| | ___
 | | | | '_ \ / _ \ '_ / /  / _ \ / _` |/ _ \
 | |_| | |_) |  __/ | | /__| (_) | (_| |  __/
  \___/| .__/ \___|_| \____/\___/ \__,_|\___|
       |_|

Base Collection
By Dilan D Chandrajith - The Perfect Developer
```

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OpenCode](https://img.shields.io/badge/OpenCode-Skills-blue.svg)](https://opencode.ai)
[![Maintenance](https://img.shields.io/badge/Maintained-yes-brightgreen.svg)](https://github.com/the-perfect-developer/opencode-base-collection/commits/main)

Essential collection of agents, skills, and commands for OpenCode - the AI-powered coding assistant.

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

Would you like to install these tools? [Y/n]
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

OpenCode includes both built-in and custom specialized agents for different development scenarios.

### Primary Agents (Switchable with Tab key)

**Build Agent**
- Full tool access and file operations
- Default agent for general development work
- Supports bash commands, file editing, and all operations
- Use when: You need full capabilities for development

**Plan Agent**
- Read-only with restricted modifications
- File edits and bash commands require confirmation
- Optimized for planning and analysis
- Use when: You want suggestions before making changes

### Built-in Subagents (General Purpose)

**General Subagent**
- General-purpose for complex, multi-step tasks
- Full tool access except todo management
- Automatically invoked for complex workflows
- Manually invoke with: `@general your request`

**Explore Subagent**
- Read-only codebase exploration
- Fast keyword and pattern searching
- Cannot modify files
- Manually invoke with: `@explore find authentication logic`

### The Perfect OpenCode Core Specialist Agents

#### 1. Frontend Engineer
**Focus:** UI/UX, responsive design, accessibility, component architecture
**Model:** Gemini 3 Pro Preview (Temperature: 0.5)

**Capabilities:**
- Frontend framework expertise (React, Vue, Angular, Svelte, Alpine.js, HTMX)
- Accessibility (WCAG, semantic HTML, ARIA)
- Responsive design and CSS/Tailwind CSS
- Design systems and component libraries
- Core Web Vitals optimization

**Use Cases:**
- Build accessible, responsive React components with proper ARIA labels
- Create design systems and component libraries with documentation
- Implement dark mode/theming solutions across applications
- Optimize frontend performance (bundle size, lazy loading, code splitting)
- Design and implement complex form interactions with validation
- Refactor components for better reusability and maintainability
- Ensure WCAG AA compliance across the application
- Implement animations and transitions for better UX

**When to use:** `@frontend-engineer build a responsive component`

**Example Prompts:**
- "Create an accessible modal component that works on mobile"
- "Refactor this React component to use hooks and improve performance"
- "Design a responsive navigation bar with dropdown menus"
- "Implement a form with validation and error handling"
- "Create a design system with reusable button variants"

**Key behaviors:**
- Consults @architect, @security-expert, @performance-engineer before major changes
- Prioritizes accessibility and user experience
- Writes actual component code (does NOT just suggest)

#### 2. Backend Engineer
**Focus:** APIs, databases, business logic, services
**Model:** Claude Sonnet 4.5 (Temperature: 0.4)

**Capabilities:**
- RESTful & GraphQL API development
- Database design and optimization
- Authentication & authorization implementation
- Background jobs and async processing
- Integration with third-party services

**Use Cases:**
- Design and implement RESTful API endpoints with proper versioning
- Build GraphQL APIs with resolvers and subscription management
- Create database schemas with migrations and optimization
- Implement OAuth 2.0 and JWT authentication
- Build role-based access control (RBAC) systems
- Create background job queues (Bull, Celery, RQ)
- Integrate payment processing (Stripe, PayPal)
- Implement file upload with virus scanning and storage
- Create webhook systems for real-time events
- Build rate limiting and API throttling
- Optimize complex database queries with proper indexing
- Implement caching layers (Redis, Memcached)

**When to use:** `@backend-engineer implement the user API endpoints`

**Example Prompts:**
- "Create a RESTful API for product management with pagination"
- "Implement JWT authentication with refresh tokens"
- "Design a background job system for sending emails"
- "Build a GraphQL API for our e-commerce platform"
- "Optimize this N+1 query problem in the orders endpoint"
- "Implement Stripe integration for payment processing"

**Key behaviors:**
- Follows @architect and @security-expert guidance
- Implements from architectural recommendations
- Handles comprehensive error handling
- Writes actual backend code and tests

#### 3. Junior Engineer
**Focus:** Quick bug fixes, small features, straightforward tasks
**Model:** Claude Haiku 4.6 (Temperature: 0.3)

**Capabilities:**
- Fast implementation of small features (under 30 minutes)
- Bug fixes and code refactoring
- Configuration updates and utility functions
- Documentation fixes and minor UI tweaks

**Use Cases:**
- Fix typos and bugs in UI text or labels
- Refactor functions for better readability
- Create utility functions (date formatting, string manipulation)
- Update configuration files and environment variables
- Fix styling bugs (padding, margins, colors)
- Implement simple form validation
- Add error handling to existing functions
- Update README documentation and comments
- Create simple API endpoints for basic CRUD operations
- Fix CSS responsive design issues
- Update package dependencies and versions

**When to use:** `@junior-engineer fix the login form typo`

**Example Prompts:**
- "Fix the typo in the header component"
- "Create a utility function to format dates"
- "Update the button color to match the design"
- "Add error handling to the API call"
- "Refactor this function to be more readable"
- "Fix the mobile responsive issue on this page"

**Key behaviors:**
- Escalates to specialists for complex tasks
- Follows coding principles and best practices
- Always asks before implementing beyond simple tasks
- Fast, productive implementation agent

#### 4. Security Expert
**Focus:** Security audits, threat modeling, cryptography, secure coding
**Model:** Claude Opus 4.6 (Temperature: 0.1)

**Capabilities:**
- OWASP Top 10 vulnerability detection
- Threat modeling and risk assessment
- Cryptography and authentication review
- Security header and protocol evaluation
- Compliance guidance (GDPR, HIPAA, PCI DSS, SOC2)

**Use Cases:**
- Audit code for OWASP Top 10 vulnerabilities
- Review authentication and authorization logic
- Assess API security (rate limiting, input validation)
- Evaluate cryptographic implementations
- Check for SQL injection, XSS, and CSRF vulnerabilities
- Review security headers (CSP, HSTS, X-Frame-Options)
- Perform threat modeling using STRIDE methodology
- Validate GDPR/HIPAA/PCI compliance
- Review dependency vulnerabilities and supply chain security
- Assess secrets management and credential handling
- Evaluate authentication flows (OAuth, JWT, SAML)
- Review database security and access controls

**When to use:** `@security-expert audit this authentication flow`

**Example Prompts:**
- "Audit this authentication code for vulnerabilities"
- "Review these API endpoints for security issues"
- "Check if we're handling passwords securely"
- "Perform threat modeling for the payment flow"
- "Validate our GDPR compliance in data handling"
- "Review these security headers and suggest improvements"

**Key behaviors:**
- Consultant role ONLY (audits, recommends, but doesn't code)
- Verifies latest CVEs and security advisories
- Provides severity ratings for findings
- Uses web search for current threats

#### 5. Performance Engineer
**Focus:** Profiling, benchmarking, algorithm optimization, efficiency
**Model:** Claude Sonnet 4.5 (Temperature: 0.2)

**Capabilities:**
- CPU and memory profiling
- Algorithm analysis and complexity
- Database query optimization
- Caching strategies
- Benchmark design and analysis

**Use Cases:**
- Profile and identify performance bottlenecks
- Analyze algorithm complexity (Big-O analysis)
- Optimize N+1 query problems in databases
- Recommend caching strategies (Redis, memcached)
- Analyze memory leaks and profiling results
- Optimize API response times
- Improve bundle size and code splitting
- Reduce database query times with proper indexing
- Optimize image loading and asset delivery
- Recommend parallelization opportunities
- Identify and fix inefficient loops and algorithms
- Benchmark and compare optimization approaches

**When to use:** `@performance-engineer profile and optimize this query`

**Example Prompts:**
- "Profile this endpoint and find the bottleneck"
- "Analyze the complexity of this algorithm"
- "Why is this query taking 5 seconds?"
- "Optimize this N+1 query problem"
- "Recommend a caching strategy for product data"
- "Identify memory leaks in this profiling data"

**Key behaviors:**
- Consultant role ONLY (analyzes, recommends, but doesn't code)
- Measures before optimizing (never assumes)
- Focuses on hot paths (80/20 rule)
- Provides severity ratings for performance issues

#### 6. Software Architect
**Focus:** System design, architectural patterns, design decisions
**Model:** Claude Opus 4.6 (Temperature: 0.2)

**Capabilities:**
- Microservices vs monolithic architecture
- Event-driven and domain-driven design
- API design (REST, GraphQL, gRPC)
- Database architecture and scalability
- Testing architecture and CI/CD design
- SOLID principles and design patterns

**Use Cases:**
- Design system architecture for new applications
- Decide between microservices and monolithic architecture
- Design database schema and scalability strategies
- Recommend API design patterns (REST vs GraphQL)
- Plan domain-driven design for complex systems
- Design event-driven architectures
- Create testing strategies (unit, integration, E2E)
- Design CI/CD pipeline architecture
- Recommend design patterns for common problems
- Evaluate technology stack choices
- Design for scalability and high availability
- Plan system migration strategies

**When to use:** `@architect design the database schema for this feature`

**Example Prompts:**
- "Design the architecture for a real-time chat application"
- "Should we use microservices or monolithic architecture?"
- "Design the database schema for an e-commerce platform"
- "Recommend an API design for our service"
- "Design the testing architecture for this project"
- "Help plan our migration from monolith to microservices"

**Key behaviors:**
- Consultant role ONLY (designs, advises, but doesn't code)
- Verifies current best practices
- Explains trade-offs clearly
- Works with implementation agents

### Invoking Specialists

**Automatic invocation:** Specialists are automatically called by implementation agents when needed.

**Manual invocation:** Invoke specialists directly with:
```
@specialist-name your request

Examples:
@frontend-engineer build a dark mode toggle
@backend-engineer implement pagination for the products API
@junior-engineer fix the typo in the header
@security-expert review this authentication code
@performance-engineer analyze this slow database query
@architect design the service architecture
```

## Installation Locations

After installation, resources are organized in:
- **Agents**: `.opencode/agents/` - Specialized AI assistants
- **Skills**: `.opencode/skills/` - Domain-specific workflows
- **Commands**: `.opencode/commands/` - Custom slash commands

Directories are automatically created during installation.

## The Perfect OpenCode Core  Skills

### 1. skill-creation
Create reusable, discoverable skills that extend OpenCode's capabilities through on-demand loading.

**What you can do:**
- Build modular instruction sets with specialized workflows
- Bundle resources like scripts, references, examples, and scripts
- Implement progressive disclosure for efficient context usage
- Create both project-local and global skills with automatic discovery
- Define skill frontmatter for smart triggering

**Perfect for:** Complex multi-step procedures, domain-specific expertise, tool integrations, and custom automation workflows.

**Example trigger phrases:**
- "How do I create a new skill?"
- "Build a custom skill for my workflow"
- "Show skill structure and format"

### 2. command-creation
Create custom slash commands for repetitive tasks that execute specific prompts with dynamic arguments.

**What you can do:**
- Define reusable prompts triggered with `/command-name`
- Pass dynamic arguments to customize behavior
- Integrate shell command output into prompts
- Auto-include file contents and references
- Route commands to specific agents or models
- Configure both markdown and JSON-based commands

**Perfect for:** Testing workflows, code reviews, deployment scripts, and any repetitive development tasks.

**Example trigger phrases:**
- "Create a slash command for testing"
- "Set up a /deploy command"
- "Add a custom command workflow"

### 3. rules-creation
Configure custom instructions to guide OpenCode's behavior for your projects and personal workflows.

**What you can do:**
- Define project conventions and code standards
- Document architecture patterns and project structure
- Specify build processes and deployment procedures
- Set personal coding preferences and communication style
- Create both project-wide and global rules
- Reference external documentation as instructions

**Perfect for:** Team conventions, coding standards, project documentation, and personalizing OpenCode's behavior.

**Example trigger phrases:**
- "Set up project rules"
- "Configure custom instructions for my team"
- "Create global OpenCode preferences"

### 4. agent-configuration
Configure and customize OpenCode agents for specialized tasks and workflows.

**What you can do:**
- Create primary agents for direct interaction
- Define subagents for specialized tasks
- Customize agent models, temperature, and tool permissions
- Configure agent prompts and descriptions
- Set up permissions using `allow`, `deny`, and `ask` modes
- Route work to specific agents based on task type

**Perfect for:** Tailored workflows, role-specific agents, restricted permissions, and multi-agent coordination.

**Example trigger phrases:**
- "Configure agents for my project"
- "Create a code review agent"
- "Set up agent permissions"

## Usage

Skills load automatically when you ask OpenCode:

```
> How do I create a new skill?
> Create a slash command for running tests
> Set up project rules
```

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
