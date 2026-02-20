# Plan Structure Templates

This reference provides detailed templates for all 10 sections of an implementation plan.

**Plan File Location**: All plan files are stored in `.opencode/plans/plan-<feature-name>.md`

## 1. Overview

**Template**:
```markdown
## Overview

### Summary
[2-3 sentences describing what this feature does and why it's needed]

### Goals
- [Primary goal 1]
- [Primary goal 2]
- [Primary goal 3]

### Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]
- [ ] [Measurable outcome 3]

### High-Level Approach
[1-2 paragraphs explaining the general strategy and methodology]
```

**Example**:
```markdown
## Overview

### Summary
Implement OAuth 2.0 authentication to allow users to sign in using third-party providers (Google, GitHub). This replaces the current email/password system and improves security and user experience.

### Goals
- Support multiple OAuth providers (Google, GitHub initially)
- Migrate existing users seamlessly
- Maintain security best practices

### Success Criteria
- [ ] Users can sign in with Google or GitHub
- [ ] Existing users can link OAuth accounts
- [ ] Session management works correctly
- [ ] All security tests pass

### High-Level Approach
Implement OAuth 2.0 flow using industry-standard libraries. Create a provider abstraction layer to support multiple OAuth providers. Migrate existing users by offering account linking on first OAuth login.
```

## 2. Technical Architecture

**Template**:
```markdown
## Technical Architecture

### Component Breakdown
**Component Name**: [Name]
- **Responsibility**: [What it does]
- **Location**: `path/to/component`
- **Dependencies**: [What it depends on]

### Data Flow
1. [Step 1: Entry point]
2. [Step 2: Processing]
3. [Step 3: Storage/Output]

[Optional: ASCII diagram]

### Integration Points
- **System A**: [How it integrates]
- **System B**: [How it integrates]

### Technology Choices
**[Technology/Library]**: [Why chosen]
**[Technology/Library]**: [Why chosen]
```

**Example**:
```markdown
## Technical Architecture

### Component Breakdown

**OAuthController**: Handles OAuth callback and token exchange
- **Responsibility**: Manage OAuth flow, validate tokens
- **Location**: `src/controllers/auth/oauth.controller.ts`
- **Dependencies**: OAuthService, UserService, SessionService

**OAuthService**: Provider abstraction layer
- **Responsibility**: Abstract different OAuth providers
- **Location**: `src/services/auth/oauth.service.ts`
- **Dependencies**: Provider adapters (GoogleProvider, GitHubProvider)

**UserLinkingService**: Manages account linking
- **Responsibility**: Link OAuth accounts to existing users
- **Location**: `src/services/auth/user-linking.service.ts`
- **Dependencies**: UserRepository, OAuthRepository

### Data Flow
1. User clicks "Sign in with Google" → Frontend redirects to Google OAuth
2. Google redirects to callback URL → OAuthController receives auth code
3. OAuthController exchanges code for token → Validates with Google
4. OAuthService creates or links user account → Returns session token
5. Frontend receives session token → User is authenticated

### Integration Points
- **Google OAuth API**: Authorization and token endpoints
- **GitHub OAuth API**: Authorization and token endpoints
- **User Database**: Store OAuth provider data and linked accounts
- **Session Store**: Manage authenticated sessions

### Technology Choices
**Passport.js**: Industry-standard OAuth library with extensive provider support
**JWT**: Stateless session tokens for scalability
```

## 3. Implementation Steps

**Template**:
```markdown
## Implementation Steps

### Step 1: [Step Name]
**Files to modify**: 
- `path/to/file1.ts` - [What to change]
- `path/to/file2.ts` - [What to change]

**Files to create**:
- `path/to/new-file.ts` - [Purpose]

**Changes**:
```[language]
// Code snippet or pseudocode
```

**Configuration**:
- [Config change 1]
- [Config change 2]

---

### Step 2: [Step Name]
[Repeat template]
```

**Example**:
```markdown
## Implementation Steps

### Step 1: Install Dependencies
**Files to modify**: 
- `package.json` - Add OAuth dependencies

**Changes**:
```bash
npm install passport passport-google-oauth20 passport-github2 @types/passport
```

**Configuration**:
- Add OAuth client IDs and secrets to `.env`

---

### Step 2: Create OAuth Provider Adapters
**Files to create**:
- `src/services/auth/providers/base-provider.ts` - Base OAuth provider interface
- `src/services/auth/providers/google-provider.ts` - Google OAuth implementation
- `src/services/auth/providers/github-provider.ts` - GitHub OAuth implementation

**Changes**:
```typescript
// src/services/auth/providers/base-provider.ts
export interface OAuthProvider {
  name: string;
  authorize(req: Request): Promise<string>; // Returns auth URL
  callback(code: string): Promise<OAuthProfile>;
  getUserProfile(token: string): Promise<UserProfile>;
}

// src/services/auth/providers/google-provider.ts
export class GoogleProvider implements OAuthProvider {
  name = 'google';
  
  async authorize(req: Request): Promise<string> {
    // Return Google OAuth authorization URL
  }
  
  async callback(code: string): Promise<OAuthProfile> {
    // Exchange code for token, fetch profile
  }
}
```

---

### Step 3: Create OAuth Service
**Files to create**:
- `src/services/auth/oauth.service.ts` - Main OAuth service

**Changes**:
```typescript
export class OAuthService {
  private providers: Map<string, OAuthProvider>;
  
  constructor(
    private userService: UserService,
    private userLinkingService: UserLinkingService
  ) {
    this.providers = new Map([
      ['google', new GoogleProvider()],
      ['github', new GitHubProvider()]
    ]);
  }
  
  async startOAuth(provider: string, req: Request): Promise<string> {
    const oauthProvider = this.providers.get(provider);
    if (!oauthProvider) throw new Error('Invalid provider');
    return oauthProvider.authorize(req);
  }
  
  async handleCallback(provider: string, code: string): Promise<User> {
    // Exchange code, get profile, create/link user
  }
}
```
```

## 4. Dependencies

**Template**:
```markdown
## Dependencies

### External Libraries
**Package Name** (`version`)
- **Purpose**: [Why needed]
- **Install**: `npm install package-name`
- **License**: [License type]

### Internal Module Dependencies
**Module Name** (`path/to/module`)
- **Used by**: [What uses it]
- **Provides**: [What it provides]

### API Integrations
**API Name**
- **Endpoint**: [Base URL]
- **Authentication**: [How to authenticate]
- **Rate Limits**: [Any limits]
- **Documentation**: [URL]

### Database Schema Changes
**Table**: [table_name]
- **Migration**: [What changes]
- **Affected queries**: [What needs updating]
```

**Example**:
```markdown
## Dependencies

### External Libraries
**passport** (`^0.7.0`)
- **Purpose**: OAuth authentication middleware
- **Install**: `npm install passport`
- **License**: MIT

**passport-google-oauth20** (`^2.0.0`)
- **Purpose**: Google OAuth 2.0 strategy for Passport
- **Install**: `npm install passport-google-oauth20`
- **License**: MIT

**passport-github2** (`^0.1.12`)
- **Purpose**: GitHub OAuth 2.0 strategy for Passport
- **Install**: `npm install passport-github2`
- **License**: MIT

### Internal Module Dependencies
**UserService** (`src/services/user.service.ts`)
- **Used by**: OAuthService
- **Provides**: User creation, lookup, updates

**SessionService** (`src/services/session.service.ts`)
- **Used by**: OAuthController
- **Provides**: Session token generation and validation

### API Integrations
**Google OAuth API**
- **Endpoint**: `https://accounts.google.com/o/oauth2/v2/auth`
- **Authentication**: Client ID and Secret
- **Rate Limits**: 10 requests per second
- **Documentation**: https://developers.google.com/identity/protocols/oauth2

**GitHub OAuth API**
- **Endpoint**: `https://github.com/login/oauth/authorize`
- **Authentication**: Client ID and Secret
- **Rate Limits**: 5000 requests per hour
- **Documentation**: https://docs.github.com/en/developers/apps/building-oauth-apps

### Database Schema Changes
**Table**: `users`
- **Migration**: Add columns: `google_id VARCHAR(255)`, `github_id VARCHAR(255)`, `oauth_provider VARCHAR(50)`
- **Affected queries**: User lookup by OAuth ID

**Table**: `oauth_accounts` (new)
- **Migration**: Create table with columns: `id`, `user_id`, `provider`, `provider_user_id`, `access_token`, `refresh_token`, `created_at`, `updated_at`
- **Affected queries**: New queries for OAuth account linking
```

## 5. Testing Strategy

**Template**:
```markdown
## Testing Strategy

### Unit Tests
**File**: `path/to/test.spec.ts`
- **Tests**: [What to test]
- **Mocks**: [What to mock]

### Integration Tests
**File**: `path/to/integration.test.ts`
- **Tests**: [What to test]
- **Setup**: [Test environment setup]

### E2E Tests
**File**: `path/to/e2e.test.ts`
- **Tests**: [User flow to test]
- **Tools**: [Testing framework]

### Test Data
**Fixtures**: `path/to/fixtures`
- **Data**: [What test data needed]
```

**Example**:
```markdown
## Testing Strategy

### Unit Tests
**File**: `src/services/auth/oauth.service.spec.ts`
- **Tests**: 
  - Should start OAuth flow with valid provider
  - Should throw error for invalid provider
  - Should handle callback and create new user
  - Should handle callback and link existing user
  - Should validate OAuth tokens correctly
- **Mocks**: UserService, UserLinkingService, OAuthProvider implementations

**File**: `src/services/auth/providers/google-provider.spec.ts`
- **Tests**:
  - Should generate correct authorization URL
  - Should exchange code for token
  - Should fetch user profile from Google API
  - Should handle API errors gracefully
- **Mocks**: HTTP client for Google API calls

### Integration Tests
**File**: `tests/integration/oauth-flow.test.ts`
- **Tests**:
  - Full OAuth flow with Google (using test credentials)
  - Full OAuth flow with GitHub (using test credentials)
  - Account linking for existing users
  - Session creation after successful OAuth
- **Setup**: Test database, test OAuth apps (Google/GitHub)

### E2E Tests
**File**: `tests/e2e/oauth-signin.e2e.ts`
- **Tests**:
  - User clicks "Sign in with Google" → Redirected → Successfully authenticated
  - User clicks "Sign in with GitHub" → Redirected → Successfully authenticated
  - Existing user links Google account → Can sign in with Google
- **Tools**: Playwright or Cypress

### Test Data
**Fixtures**: `tests/fixtures/oauth`
- **Data**: 
  - Mock OAuth responses from Google/GitHub
  - Test user profiles
  - Test OAuth tokens (expired, invalid, valid)
```

## 6. Security Considerations

**Template**:
```markdown
## Security Considerations

### Authentication/Authorization Impacts
- [Impact 1]
- [Impact 2]

### Data Validation Requirements
**Input**: [Field name]
- **Validation**: [What to validate]
- **Sanitization**: [How to sanitize]

### Security Best Practices
- [ ] [Practice 1]
- [ ] [Practice 2]

### Potential Vulnerabilities
**[Vulnerability Type]**: [Description]
- **Mitigation**: [How to prevent]
```

**Example**:
```markdown
## Security Considerations

### Authentication/Authorization Impacts
- OAuth tokens must be securely stored (encrypted in database)
- Session tokens should have expiration times (max 24 hours)
- Refresh tokens should be rotated on each use
- Failed OAuth attempts should be rate-limited

### Data Validation Requirements
**Input**: OAuth authorization code
- **Validation**: Must be single-use, validate with provider immediately
- **Sanitization**: N/A (provider-issued, validated cryptographically)

**Input**: OAuth state parameter
- **Validation**: Must match CSRF token stored in session
- **Sanitization**: Generate cryptographically random values

**Input**: Provider user ID
- **Validation**: Must be string, max 255 characters
- **Sanitization**: Escape before database storage

### Security Best Practices
- [ ] Use HTTPS for all OAuth redirects
- [ ] Implement CSRF protection with state parameter
- [ ] Validate OAuth provider SSL certificates
- [ ] Store client secrets in environment variables (never commit)
- [ ] Implement rate limiting on OAuth endpoints
- [ ] Log all OAuth authentication attempts
- [ ] Use secure session storage (HTTP-only, Secure, SameSite cookies)

### Potential Vulnerabilities
**OAuth Token Theft**: Attacker intercepts OAuth tokens
- **Mitigation**: Use HTTPS, short-lived tokens, rotate refresh tokens

**CSRF Attack**: Attacker tricks user into OAuth flow
- **Mitigation**: Implement state parameter validation

**Account Takeover via Linking**: Attacker links OAuth account to wrong user
- **Mitigation**: Require user to be authenticated before linking, confirm email match

**Replay Attacks**: Attacker reuses authorization codes
- **Mitigation**: Validate codes are single-use with provider
```

## 7. Performance Considerations

**Template**:
```markdown
## Performance Considerations

### Expected Performance Impact
- [Impact description]
- [Metrics: latency, throughput, etc.]

### Optimization Opportunities
**[Area]**: [Description]
- **Strategy**: [How to optimize]
- **Expected gain**: [Performance improvement]

### Scalability Concerns
- [Concern 1]
- [Solution 1]

### Caching Strategies
**[What to cache]**: [Why and how]
- **TTL**: [Cache lifetime]
- **Invalidation**: [When to invalidate]
```

**Example**:
```markdown
## Performance Considerations

### Expected Performance Impact
- OAuth flow adds 2-3 seconds latency (external API calls to Google/GitHub)
- Database queries increase by 2-3 per authentication (user lookup, OAuth account lookup)
- Token validation adds ~50ms per request (JWT decode + signature verification)

### Optimization Opportunities
**User Profile Caching**: Cache OAuth user profiles after fetch
- **Strategy**: Cache in Redis for 1 hour after successful OAuth callback
- **Expected gain**: Reduce duplicate API calls by 80%

**Database Query Optimization**: Add indexes on OAuth IDs
- **Strategy**: Create indexes on `users.google_id`, `users.github_id`, `oauth_accounts.provider_user_id`
- **Expected gain**: Reduce user lookup time from ~50ms to ~5ms

### Scalability Concerns
- OAuth provider rate limits (5000 req/hour for GitHub)
  - **Solution**: Implement request queuing and retry logic

- Database connection pool exhaustion
  - **Solution**: Use connection pooling with max 100 connections

- Session storage growth
  - **Solution**: Implement automatic session cleanup (delete sessions older than 30 days)

### Caching Strategies
**OAuth User Profiles**: Cache after successful authentication
- **TTL**: 1 hour
- **Invalidation**: On user profile update or manual refresh

**OAuth Provider Discovery Documents**: Cache provider endpoints
- **TTL**: 24 hours
- **Invalidation**: On provider configuration change

**User OAuth Accounts**: Cache user's linked OAuth accounts
- **TTL**: 15 minutes
- **Invalidation**: On account link/unlink
```

## 8. Migration Path

**Template**:
```markdown
## Migration Path

### Breaking Changes
**[Change description]**
- **Impact**: [Who/what is affected]
- **Migration**: [How to migrate]

### Data Migration Steps
1. [Step 1]
2. [Step 2]

### Backward Compatibility
- [Compatibility consideration 1]
- [Compatibility consideration 2]

### Rollback Strategy
1. [Rollback step 1]
2. [Rollback step 2]
```

**Example**:
```markdown
## Migration Path

### Breaking Changes
**Email/Password Authentication Remains**: No breaking changes - OAuth is additive
- **Impact**: Existing users continue using email/password
- **Migration**: Optional migration to OAuth via account linking

### Data Migration Steps
1. **Add OAuth columns to users table**:
   ```sql
   ALTER TABLE users ADD COLUMN google_id VARCHAR(255);
   ALTER TABLE users ADD COLUMN github_id VARCHAR(255);
   ALTER TABLE users ADD COLUMN oauth_provider VARCHAR(50);
   CREATE INDEX idx_users_google_id ON users(google_id);
   CREATE INDEX idx_users_github_id ON users(github_id);
   ```

2. **Create oauth_accounts table**:
   ```sql
   CREATE TABLE oauth_accounts (
     id SERIAL PRIMARY KEY,
     user_id INTEGER REFERENCES users(id),
     provider VARCHAR(50) NOT NULL,
     provider_user_id VARCHAR(255) NOT NULL,
     access_token TEXT,
     refresh_token TEXT,
     created_at TIMESTAMP DEFAULT NOW(),
     updated_at TIMESTAMP DEFAULT NOW(),
     UNIQUE(provider, provider_user_id)
   );
   ```

3. **No existing data migration needed**: This is a new feature, existing users unaffected

### Backward Compatibility
- Email/password authentication continues working unchanged
- Existing session tokens remain valid
- No changes to existing authentication endpoints
- Users can use email/password or OAuth interchangeably

### Rollback Strategy
1. **Remove OAuth routes**: Comment out OAuth routes in routing configuration
2. **Revert database changes**: 
   ```sql
   DROP TABLE oauth_accounts;
   ALTER TABLE users DROP COLUMN google_id;
   ALTER TABLE users DROP COLUMN github_id;
   ALTER TABLE users DROP COLUMN oauth_provider;
   ```
3. **Remove OAuth dependencies**: Uninstall passport libraries
4. **Redeploy previous version**: Deploy last known good version

**Note**: Rollback is safe because OAuth is additive. Users who signed up via OAuth will need to use password reset to regain access.
```

## 9. Documentation Updates

**Template**:
```markdown
## Documentation Updates

### Code Documentation
**File**: `path/to/file.ts`
- **Add**: [What documentation to add]

### README Updates
- [ ] [Update 1]
- [ ] [Update 2]

### API Documentation
**Endpoint**: `[METHOD] /path`
- **Description**: [What it does]
- **Request**: [Request format]
- **Response**: [Response format]

### User-Facing Documentation
**Document**: [Doc name/path]
- **Section**: [Which section]
- **Content**: [What to add]
```

**Example**:
```markdown
## Documentation Updates

### Code Documentation
**File**: `src/services/auth/oauth.service.ts`
- **Add**: JSDoc comments for all public methods with examples
  ```typescript
  /**
   * Initiates OAuth authentication flow for a given provider.
   * 
   * @param provider - OAuth provider name ('google' or 'github')
   * @param req - Express request object containing session data
   * @returns Authorization URL to redirect user to
   * @throws {Error} If provider is not supported
   * 
   * @example
   * const authUrl = await oauthService.startOAuth('google', req);
   * res.redirect(authUrl);
   */
  async startOAuth(provider: string, req: Request): Promise<string>
  ```

**File**: `src/controllers/auth/oauth.controller.ts`
- **Add**: Route documentation with OpenAPI/Swagger annotations

### README Updates
- [ ] Add OAuth setup instructions in "Authentication" section
- [ ] Document environment variables for OAuth (client IDs, secrets)
- [ ] Add OAuth configuration example in `.env.example`
- [ ] Update "Getting Started" with OAuth setup steps

### API Documentation
**Endpoint**: `GET /auth/oauth/:provider`
- **Description**: Initiates OAuth authentication flow
- **Parameters**: `provider` - OAuth provider name ('google' or 'github')
- **Response**: Redirects to OAuth provider authorization page

**Endpoint**: `GET /auth/oauth/:provider/callback`
- **Description**: OAuth callback endpoint (handles provider redirect)
- **Parameters**: 
  - `provider` - OAuth provider name
  - `code` - Authorization code (query param)
  - `state` - CSRF token (query param)
- **Response**: Redirects to app with session token

**Endpoint**: `POST /auth/oauth/link`
- **Description**: Links OAuth account to existing authenticated user
- **Request**: 
  ```json
  {
    "provider": "google",
    "code": "auth_code_from_provider"
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "provider": "google",
    "linked_at": "2026-02-19T10:30:00Z"
  }
  ```

### User-Facing Documentation
**Document**: `docs/user-guide/authentication.md`
- **Section**: "Signing In"
- **Content**: 
  - Add section "Sign in with Google or GitHub"
  - Include screenshots of OAuth login buttons
  - Explain account linking for existing users
  - FAQ: "Can I use both email/password and OAuth?"
```

## 10. Rollout Plan

**Template**:
```markdown
## Rollout Plan

### Deployment Steps
1. [Step 1]
2. [Step 2]

### Feature Flags
**Flag Name**: `[flag-name]`
- **Purpose**: [Why flag is needed]
- **Default**: [enabled/disabled]
- **Rollout**: [Phased rollout plan]

### Monitoring and Metrics
**Metric**: [metric-name]
- **What**: [What to measure]
- **Threshold**: [Alert threshold]

### Rollback Procedures
**Trigger**: [When to rollback]
**Steps**:
1. [Rollback step 1]
2. [Rollback step 2]
```

**Example**:
```markdown
## Rollout Plan

### Deployment Steps
1. **Deploy database migrations** (downtime: none):
   ```bash
   npm run migrate:up
   ```
2. **Deploy application code** to staging environment:
   - Run full test suite
   - Manual QA testing of OAuth flows
   - Verify monitoring and logging

3. **Deploy to production** (canary deployment):
   - Deploy to 10% of servers
   - Monitor for 1 hour
   - If successful, deploy to 50% of servers
   - Monitor for 2 hours
   - Deploy to 100% of servers

4. **Enable OAuth feature flag** (gradual rollout):
   - Day 1: Enable for internal users only
   - Day 3: Enable for 10% of users
   - Day 7: Enable for 50% of users
   - Day 14: Enable for 100% of users

### Feature Flags
**Flag Name**: `oauth-authentication-enabled`
- **Purpose**: Control rollout of OAuth feature to users
- **Default**: disabled
- **Rollout**: Gradual rollout over 14 days (see deployment steps)

**Flag Name**: `oauth-provider-google`
- **Purpose**: Enable/disable Google OAuth provider independently
- **Default**: enabled (once main flag enabled)
- **Rollout**: Enabled with main flag

**Flag Name**: `oauth-provider-github`
- **Purpose**: Enable/disable GitHub OAuth provider independently
- **Default**: enabled (once main flag enabled)
- **Rollout**: Enabled with main flag

### Monitoring and Metrics
**Metric**: `oauth_authentication_attempts_total`
- **What**: Count of OAuth authentication attempts by provider
- **Threshold**: Alert if drops to 0 (indicates provider outage)

**Metric**: `oauth_authentication_success_rate`
- **What**: Percentage of successful OAuth authentications
- **Threshold**: Alert if drops below 95%

**Metric**: `oauth_authentication_latency_p95`
- **What**: 95th percentile latency for OAuth flow
- **Threshold**: Alert if exceeds 5 seconds

**Metric**: `oauth_provider_errors_total`
- **What**: Count of errors from OAuth providers by provider and error type
- **Threshold**: Alert if rate exceeds 10 errors/minute

**Metric**: `oauth_account_linking_total`
- **What**: Count of users linking OAuth accounts
- **Threshold**: Track for adoption metrics

**Logs to Monitor**:
- OAuth authentication successes/failures
- OAuth provider API errors
- CSRF token validation failures
- Account linking attempts

### Rollback Procedures
**Trigger**: OAuth success rate drops below 90% OR critical security issue discovered

**Steps**:
1. **Disable feature flag immediately**:
   ```bash
   feature-flag-cli set oauth-authentication-enabled false
   ```

2. **Notify users**: Post status page update about temporary OAuth issues

3. **Investigate root cause**: Check logs, metrics, provider status pages

4. **If database rollback needed**:
   - Only needed if migrations caused issues
   - Run migration rollback: `npm run migrate:down`
   - Verify data integrity

5. **If code rollback needed**:
   - Deploy previous stable version
   - Verify email/password authentication working
   - Monitor for stability

6. **Post-mortem**: Document incident, root cause, prevention steps

**Rollback Impact**:
- Users who signed up via OAuth will be unable to log in (must use password reset)
- Minimal impact since OAuth is additive feature
- Email/password authentication unaffected
```

## Summary

Each plan section serves a specific purpose:

1. **Overview** - Sets context and goals
2. **Technical Architecture** - Defines structure and design
3. **Implementation Steps** - Provides actionable tasks
4. **Dependencies** - Identifies external requirements
5. **Testing Strategy** - Ensures quality and correctness
6. **Security Considerations** - Protects users and data
7. **Performance Considerations** - Maintains system efficiency
8. **Migration Path** - Handles transitions safely
9. **Documentation Updates** - Maintains knowledge base
10. **Rollout Plan** - Deploys changes safely

Use these templates to create comprehensive, production-ready implementation plans.
