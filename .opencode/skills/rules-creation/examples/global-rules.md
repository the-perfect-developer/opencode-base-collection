# Global Personal Preferences

Personal coding preferences and communication style for all OpenCode sessions.

## Communication Style

- Be concise and direct
- Focus on code over explanations
- Show examples rather than describing
- Skip pleasantries (no "Great!", "Awesome!", etc.)

## Code Preferences

### General
- Prefer functional programming over OOP
- Use TypeScript for all JavaScript projects
- Single quotes for strings
- 2 spaces for indentation

### JavaScript/TypeScript
- Use arrow functions by default
- Prefer `const` over `let`, avoid `var`
- Use template literals over string concatenation
- Async/await over promises chains

### React
- Functional components only (no class components)
- Use custom hooks for shared logic
- Named exports over default exports
- Co-locate tests with components

### Testing
- Write tests before implementing (TDD when feasible)
- Descriptive test names using "should" convention
- One assertion per test when possible

## Project Setup

### New Projects
- Use TypeScript by default
- Set up ESLint and Prettier
- Include `.editorconfig`
- Initialize git with `.gitignore`

### Package Manager
- Prefer `pnpm` > `npm` > `yarn`
- Lock files should be committed

## Git Conventions

### Commit Messages
Follow conventional commits:
- `feat: add user authentication`
- `fix: resolve login redirect issue`
- `refactor: simplify validation logic`
- `docs: update API documentation`
- `test: add tests for user service`

### Branching
- `main` - Production-ready code
- `develop` - Integration branch
- `feature/feature-name` - New features
- `fix/bug-name` - Bug fixes

## Tools

### Editor
- VS Code is primary editor
- Use extensions: ESLint, Prettier, GitLens

### Terminal
- Use bash/zsh
- Prefer shell scripts over complex npm scripts

## Documentation

- Focus on WHY not WHAT
- Code should be self-documenting
- Add comments only for non-obvious logic
- Keep README concise with quick start guide
