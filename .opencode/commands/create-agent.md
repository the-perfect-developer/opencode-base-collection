---
description: Create a new OpenCode agent with interactive configuration
agent: build
model: github-copilot/claude-sonnet-4.5
---

I'll help you create a new custom OpenCode agent. Let me guide you through the configuration process by asking some questions.

First, let me load the agent configuration skill to ensure I have all the latest information:

Use the agent-configuration skill from @.opencode/skills/agent-configuration/

Now, let me gather the information I need to create your agent:

## Questions

Please provide the following information:

1. **Agent name**: What should the agent be called? (lowercase, hyphenated, e.g., "code-reviewer")

2. **Agent description**: What does this agent do? When should it be used? (Be specific and include trigger phrases)

3. **Agent type**: 
   - `primary` - Main agent you can switch to with Tab key
   - `subagent` - Specialized agent invoked by @ mention or other agents
   - `all` - Can be both (default)

4. **Model preference** (optional): Which model should this agent use?
   - GitHub Copilot models (recommended):
     - `github-copilot/gpt-4o` - GPT-4o (balanced performance)
     - `github-copilot/gpt-4o-mini` - GPT-4o Mini (faster, cost-effective)
     - `github-copilot/o1-preview` - O1 Preview (advanced reasoning)
     - `github-copilot/o1-mini` - O1 Mini (reasoning, faster)
     - `github-copilot/claude-sonnet-4.5` - Claude Sonnet 4.5
   - Other providers:
     - `anthropic/claude-sonnet-4-20250514` - Claude Sonnet 4
     - `anthropic/claude-haiku-4-20250514` - Claude Haiku 4 (fast, cost-effective)
   - Leave empty to use default

5. **Temperature** (optional): Response creativity level (0.0-1.0)?
   - 0.0-0.2: Focused, deterministic (code analysis, security)
   - 0.3-0.5: Balanced (general development)
   - 0.6-1.0: Creative (brainstorming, design)

6. **Tool permissions**: What tools should this agent have access to?
   - `write`: Can create new files?
   - `edit`: Can modify existing files?
   - `bash`: Can execute bash commands?
   - `webfetch`: Can fetch web content?

7. **Permission levels**: For each enabled tool, what permission level?
   - `allow` - Execute without approval
   - `ask` - Prompt for approval (default)
   - `deny` - Disabled

8. **Bash command permissions** (if bash enabled): Any specific bash commands to allow/deny?
   - Example: `"git status": "allow"`, `"git push": "ask"`, `"rm -rf*": "deny"`

9. **Custom system prompt** (optional): Any special instructions for this agent's behavior?

10. **Max steps** (optional): Maximum number of agentic iterations? (Leave empty for unlimited)

11. **Hidden from @ menu?**: For subagents, hide from autocomplete? (yes/no)

12. **UI color** (optional): Custom color for this agent? (hex code like `#ff6b6b` or theme color like `primary`, `accent`)

## Instructions

After gathering the above information, I will:

1. Validate the configuration
2. Create the agent file in `.opencode/agents/` directory
3. Include proper frontmatter and system prompt
4. Test the configuration syntax
5. Provide usage examples

Please answer the questions above, and I'll create your custom agent configuration.

## Reference

For detailed information about agent configuration, refer to:
- `.opencode/skills/agent-configuration/SKILL.md` - Complete agent configuration guide
- `.opencode/skills/agent-configuration/examples/custom-agents.md` - Real-world examples
- https://opencode.ai/docs/agents/ - Official documentation
