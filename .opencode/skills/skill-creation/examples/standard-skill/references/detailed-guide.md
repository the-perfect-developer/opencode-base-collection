# Detailed Guide Example

This reference file demonstrates how to organize detailed documentation separate from SKILL.md.

## Purpose

Reference files provide comprehensive information that would bloat SKILL.md if included there. They're loaded only when agents need specific details, keeping context efficient.

## Structure

A good reference file includes:

### 1. Clear Introduction

Start with 2-3 sentences explaining what this reference covers and when to use it.

Example:
```markdown
# Authentication Strategies

This guide provides comprehensive coverage of API authentication approaches.
Use this when implementing authentication for REST APIs or choosing between
auth strategies for your use case.
```

### 2. Organized Sections

Break content into clear sections with descriptive headings:

```markdown
## Overview
[High-level explanation]

## Strategy 1: API Keys
[Detailed coverage of approach 1]

## Strategy 2: OAuth 2.0
[Detailed coverage of approach 2]

## Comparison
[When to use each approach]

## Best Practices
[Security and implementation guidance]
```

### 3. Detailed Explanations

Unlike SKILL.md which is concise, reference files should be comprehensive:

**SKILL.md style (concise)**:
```markdown
## Authentication

Common approaches:
- API Keys - Simple, suitable for server-to-server
- OAuth 2.0 - Complex, suitable for user authorization
- JWT - Stateless, suitable for distributed systems

See `references/authentication.md` for detailed comparison.
```

**Reference file style (comprehensive)**:
```markdown
## API Keys

### What Are API Keys

API keys are simple credentials used to authenticate requests. They're
typically long strings of random characters that identify the calling
application.

### How They Work

1. Service generates unique key for each client
2. Client includes key in each request (header or query param)
3. Service validates key before processing request
4. Key grants access to all permitted operations

### When to Use

**Good for**:
- Server-to-server communication
- Internal APIs
- Simple authentication needs
- Non-user-facing services

**Not good for**:
- User authentication
- Fine-grained permissions
- Temporary access
- Delegation scenarios

### Security Considerations

**Strengths**:
- Simple to implement
- Low overhead
- Easy to rotate
- Stateless validation

**Weaknesses**:
- No expiration (unless implemented)
- All-or-nothing access
- Key compromise grants full access
- No user context

### Implementation Example

[Detailed code examples]

### Best Practices

1. **Never expose in client-side code**
   Keys in JavaScript, mobile apps, etc. can be extracted

2. **Use HTTPS only**
   Keys transmitted in plain text over HTTP are vulnerable

3. **Rotate regularly**
   Implement key rotation schedule (e.g., quarterly)

4. **Monitor usage**
   Track key usage to detect compromise

5. **Implement rate limiting**
   Prevent abuse even with valid keys

[Continue with more detailed guidance...]
```

### 4. Examples and Code

Include detailed examples that would be too long for SKILL.md:

```python
# Example: API key validation middleware

from functools import wraps
from flask import request, jsonify

VALID_KEYS = {
    'key_abc123': {'client': 'mobile_app', 'rate_limit': 1000},
    'key_xyz789': {'client': 'web_app', 'rate_limit': 5000},
}

def require_api_key(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Extract key from header
        api_key = request.headers.get('X-API-Key')
        
        # Validate key exists
        if not api_key:
            return jsonify({'error': 'API key required'}), 401
        
        # Validate key is valid
        if api_key not in VALID_KEYS:
            return jsonify({'error': 'Invalid API key'}), 401
        
        # Attach client info to request
        request.client_info = VALID_KEYS[api_key]
        
        # Continue to route handler
        return f(*args, **kwargs)
    
    return decorated_function

# Usage
@app.route('/api/data')
@require_api_key
def get_data():
    client = request.client_info['client']
    # Process request...
    return jsonify({'data': [...], 'client': client})
```

### 5. Tables and Comparisons

Use tables for detailed comparisons:

| Feature | API Keys | OAuth 2.0 | JWT |
|---------|----------|-----------|-----|
| Complexity | Low | High | Medium |
| User auth | No | Yes | Yes |
| Expiration | Manual | Built-in | Built-in |
| Revocation | Easy | Medium | Hard |
| Stateless | Yes | No | Yes |
| Delegation | No | Yes | Limited |
| Use case | Server-to-server | User authorization | Distributed systems |

### 6. Edge Cases and Troubleshooting

Cover scenarios too specific for SKILL.md:

**Problem**: API key works in development but fails in production

**Possible causes**:
1. Key rotation in production environment
2. Different key required for prod vs dev
3. Firewall blocking requests
4. Rate limiting on production keys

**Debugging steps**:
1. Verify key is correct for environment
2. Check server logs for validation errors
3. Test with curl to isolate client issues
4. Verify network connectivity

**Problem**: Key compromise detected

**Response procedure**:
1. Immediately revoke compromised key
2. Generate new key
3. Update client configuration
4. Audit recent usage for suspicious activity
5. Implement additional security measures

## Content Guidelines

### Length

Reference files can be substantial:
- **Minimum**: 1,000 words (or use SKILL.md instead)
- **Typical**: 2,000-5,000 words
- **Maximum**: No hard limit, but consider splitting if >8,000 words

### Depth

Go deeper than SKILL.md:
- Explain the "why" not just "what"
- Cover edge cases
- Provide context and background
- Include detailed examples
- Discuss tradeoffs and alternatives

### Organization

Break into logical sections:
- Use clear headings (##, ###, ####)
- One concept per section
- Progressive complexity (basic → advanced)
- Cross-reference related sections

## Multiple Reference Files

When to split into multiple reference files:

**Split when**:
- Single file exceeds 5,000 words
- Covering multiple distinct topics
- Different skill levels (basic vs advanced)
- Different aspects (concepts vs implementation)

**Example split**:

Instead of one `references/complete-guide.md` (8,000 words):

```
references/
├── concepts.md (2,500 words - theory and principles)
├── implementation.md (2,800 words - practical guide)
├── advanced.md (1,700 words - complex scenarios)
└── troubleshooting.md (1,000 words - common issues)
```

## Linking Between References

Reference files can link to each other:

```markdown
## Advanced Techniques

For advanced patterns like refresh token rotation and PKCE,
see `references/advanced.md`.

For troubleshooting OAuth flows, see `references/troubleshooting.md`.
```

## Summary

**Reference files should be**:
- Comprehensive and detailed
- Well-organized with clear sections
- Rich with examples and code
- Focused on specific topics
- 2,000-5,000 words typically

**They provide**:
- Detailed explanations SKILL.md doesn't have room for
- Comprehensive examples and code samples
- Edge case coverage and troubleshooting
- In-depth comparisons and analysis

**They enable**:
- Progressive disclosure
- Efficient context usage
- Better organization
- Scalable skill content

This is where the real depth of your skill lives, loaded only when agents need it.
