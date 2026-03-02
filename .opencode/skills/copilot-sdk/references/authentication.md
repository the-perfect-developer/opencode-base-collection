# Authentication

## Table of Contents

- [Methods Overview](#methods-overview)
- [GitHub Signed-in User](#github-signed-in-user)
- [OAuth GitHub App](#oauth-github-app)
- [Environment Variables](#environment-variables)
- [BYOK — Bring Your Own Key](#byok--bring-your-own-key)
- [Authentication Priority Order](#authentication-priority-order)
- [Disabling Auto-Login](#disabling-auto-login)

---

## Methods Overview

| Method | Use Case | Copilot Subscription |
|---|---|---|
| Signed-in user | Interactive desktop/CLI apps | Required |
| OAuth GitHub App | Web apps acting on behalf of users | Required |
| Environment variables | CI/CD, automation, server-to-server | Required |
| BYOK | Use own API keys (Azure, OpenAI, Anthropic) | Not required |

---

## GitHub Signed-in User

Default method. Users authenticate via the Copilot CLI device flow; credentials are stored in the system keychain.

```bash
# One-time setup
copilot  # follow the OAuth device flow
```

No SDK configuration required — all SDKs use stored credentials by default:

```typescript
// TypeScript — default
const client = new CopilotClient();
```

```python
# Python — default
client = CopilotClient()
await client.start()
```

**When to use:** Desktop apps, development environments, any scenario with interactive login.

---

## OAuth GitHub App

Pass a user access token obtained from your own OAuth GitHub App:

```typescript
// TypeScript
const client = new CopilotClient({
    githubToken: userAccessToken,
    useLoggedInUser: false,
});
```

```python
# Python
client = CopilotClient({
    "github_token": user_access_token,
    "use_logged_in_user": False,
})
await client.start()
```

```go
// Go
client := copilot.NewClient(&copilot.ClientOptions{
    GithubToken:     userAccessToken,
    UseLoggedInUser: copilot.Bool(false),
})
```

```csharp
// .NET
await using var client = new CopilotClient(new CopilotClientOptions
{
    GithubToken = userAccessToken,
    UseLoggedInUser = false,
});
```

**Supported token prefixes:**

| Prefix | Type |
|---|---|
| `gho_` | OAuth user access token |
| `ghu_` | GitHub App user access token |
| `github_pat_` | Fine-grained personal access token |
| `ghp_` | Classic PAT — **not supported** |

**When to use:** SaaS web apps, multi-user services acting on behalf of GitHub users.

---

## Environment Variables

Set one of the following; the SDK detects them automatically, no code changes needed:

| Variable | Priority | Notes |
|---|---|---|
| `COPILOT_GITHUB_TOKEN` | 1st | Recommended for Copilot-specific usage |
| `GH_TOKEN` | 2nd | GitHub CLI compatible |
| `GITHUB_TOKEN` | 3rd | GitHub Actions compatible |

```bash
export COPILOT_GITHUB_TOKEN=gho_xxxxxxxxxxxxxxxxxxxx
```

```typescript
// No change needed — SDK picks up the env var
const client = new CopilotClient();
```

**When to use:** CI/CD pipelines (GitHub Actions, Jenkins), automated scripts, server-side service accounts.

---

## BYOK — Bring Your Own Key

Use your own LLM provider API keys. No GitHub Copilot subscription required. Configure via the `provider` field in `SessionConfig`.

**`model` is required when using a custom provider.**

### OpenAI-Compatible Endpoints

```typescript
const session = await client.createSession({
    model: "gpt-4",
    provider: {
        type: "openai",
        baseUrl: "https://my-api.example.com/v1",
        apiKey: process.env.MY_API_KEY,
    },
});
```

```python
session = await client.create_session({
    "model": "gpt-4",
    "provider": {
        "type": "openai",
        "base_url": "https://my-api.example.com/v1",
        "api_key": os.environ["MY_API_KEY"],
    },
})
```

### Ollama (local, no key required)

```typescript
const session = await client.createSession({
    model: "deepseek-coder-v2:16b",
    provider: {
        type: "openai",
        baseUrl: "http://localhost:11434/v1",
        // apiKey omitted — not needed for Ollama
    },
});
```

### Azure OpenAI

```typescript
const session = await client.createSession({
    model: "gpt-4",
    provider: {
        type: "azure",          // Must be "azure", NOT "openai"
        baseUrl: "https://my-resource.openai.azure.com",  // host only, no path
        apiKey: process.env.AZURE_OPENAI_KEY,
        azure: { apiVersion: "2024-10-21" },
    },
});
```

```python
session = await client.create_session({
    "model": "gpt-4",
    "provider": {
        "type": "azure",
        "base_url": "https://my-resource.openai.azure.com",  # host only
        "api_key": os.environ["AZURE_OPENAI_KEY"],
        "azure": {"api_version": "2024-10-21"},
    },
})
```

**ProviderConfig fields:**

| Field | Type | Description |
|---|---|---|
| `type` | string | `"openai"` \| `"azure"` \| `"anthropic"` (default: `"openai"`) |
| `baseUrl` / `base_url` | string | API endpoint host — no path suffix |
| `apiKey` / `api_key` | string | API key (optional for local providers) |
| `bearerToken` / `bearer_token` | string | Bearer token — takes precedence over `apiKey` |
| `wireApi` / `wire_api` | string | `"completions"` \| `"responses"` (default: `"completions"`) |
| `azure.apiVersion` | string | Azure API version (default: `"2024-10-21"`) |

**Critical notes:**
- For `*.openai.azure.com` endpoints, use `type: "azure"` — never `"openai"`
- `baseUrl` must be the host only — the SDK appends the correct path
- BYOK uses key-based auth only — Microsoft Entra ID and managed identities are not supported

**When to use:** Enterprise LLM deployments, self-hosted models, direct billing with a provider, scenarios without a Copilot subscription.

---

## Authentication Priority Order

When multiple methods are available, the SDK resolves in this order:

1. Explicit `githubToken` passed to the client constructor
2. `CAPI_HMAC_KEY` or `COPILOT_HMAC_KEY` environment variables
3. `GITHUB_COPILOT_API_TOKEN` with `COPILOT_API_URL`
4. `COPILOT_GITHUB_TOKEN` environment variable
5. `GH_TOKEN` environment variable
6. `GITHUB_TOKEN` environment variable
7. Stored OAuth credentials from previous `copilot` CLI login
8. GitHub CLI (`gh auth`) credentials

---

## Disabling Auto-Login

Prevent the SDK from using stored CLI credentials or `gh auth` credentials. Useful when tokens should only come from explicit configuration:

```typescript
const client = new CopilotClient({ useLoggedInUser: false });
```

```python
client = CopilotClient({"use_logged_in_user": False})
```

```go
client := copilot.NewClient(&copilot.ClientOptions{
    UseLoggedInUser: copilot.Bool(false),
})
```

```csharp
await using var client = new CopilotClient(new CopilotClientOptions
{
    UseLoggedInUser = false,
});
```

**Note:** `useLoggedInUser` cannot be combined with `cliUrl`.
