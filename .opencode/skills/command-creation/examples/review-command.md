---
description: Review recent changes
agent: plan
---

Review recent git commits and changes:

Recent commits:
!`git log --oneline -10`

Changed files:
!`git diff --name-only HEAD~5`

Detailed diff:
!`git diff HEAD~5 --stat`

Review these changes for:
1. **Code Quality**
   - Consistent style and patterns
   - Proper error handling
   - Code duplication

2. **Performance**
   - Potential bottlenecks
   - Inefficient algorithms
   - Resource usage

3. **Security**
   - Input validation
   - Security vulnerabilities
   - Sensitive data exposure

4. **Testing**
   - Test coverage for changes
   - Edge cases handled
   - Integration tests needed

5. **Documentation**
   - Code comments
   - README updates
   - API documentation

Provide specific suggestions for improvements.
