# Connection & Authentication Reference

Comprehensive guide to authenticating SDK connections, managing auth tokens, and applying fine-grained access control in Turso.

## Table of Contents

- [Database URL Formats](#database-url-formats)
- [Auth Tokens](#auth-tokens)
- [Token Scopes](#token-scopes)
- [Fine-Grained Permissions](#fine-grained-permissions)
- [JWKS / External Auth Providers](#jwks--external-auth-providers)
- [Security Checklist](#security-checklist)
- [Environment Variable Patterns](#environment-variable-patterns)

---

## Database URL Formats

```
libsql://[DB-NAME]-[ORG-NAME].turso.io    # WebSocket (persistent connections)
https://[DB-NAME]-[ORG-NAME].turso.io     # HTTP (single queries, serverless)
file:path/to/db.db                         # Local SQLite file
:memory:                                   # In-memory (testing)
http://127.0.0.1:8080                      # Local turso dev server
```

**Protocol guidance**:
- `libsql://` — preferred for servers, VMs, long-lived processes; WebSockets amortize the connection cost across multiple queries
- `https://` — preferred for serverless functions, edge workers, one-shot scripts; no persistent socket overhead
- Benchmark both protocols for workloads between 1–5 queries per invocation to determine the better fit

Retrieve your database URL:

```bash
turso db show <database-name> --url
```

---

## Auth Tokens

Turso uses JWT-based auth tokens. Every SDK connection to a remote database requires an `authToken`. Local file connections (`file:`) and `turso dev` do not require a token.

### Creating Tokens

```bash
# Database-scoped token (recommended)
turso db tokens create <db-name>

# Group-scoped token (applies to all databases in the group)
turso group tokens create <group-name>

# Expiring token (e.g., 7 days)
turso db tokens create <db-name> --expiration 7d

# Read-only token
turso db tokens create <db-name> --read-only
```

Via Platform API:

```bash
curl -X POST "https://api.turso.tech/v1/organizations/{org}/databases/{db}/auth/tokens" \
  -H "Authorization: Bearer $TURSO_API_TOKEN"
```

### Rotating / Invalidating Tokens

```bash
# Invalidate all tokens for a database (triggers rotation)
turso db tokens invalidate <db-name>

# Invalidate all tokens for a group
turso group tokens invalidate <group-name>
```

After invalidating, create new tokens and redeploy applications. All existing connections using the old token will be rejected.

### Using Tokens in SDKs

```ts
// TypeScript
import { createClient } from "@libsql/client";

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN!,
});
```

```python
# Python
import libsql_client
import os

client = libsql_client.create_client_sync(
    url=os.environ["TURSO_DATABASE_URL"],
    auth_token=os.environ["TURSO_AUTH_TOKEN"],
)
```

```go
// Go
import "github.com/tursodatabase/go-libsql"

connector, err := libsql.NewEmbeddedReplicaConnector(
    dbPath,
    os.Getenv("TURSO_DATABASE_URL"),
    libsql.WithAuthToken(os.Getenv("TURSO_AUTH_TOKEN")),
)
```

---

## Token Scopes

| Scope | Created via | Coverage |
|---|---|---|
| Database token | `turso db tokens create` | Single database only |
| Group token | `turso group tokens create` | All databases in the group |
| Read-only token | `--read-only` flag | SELECT only, no writes |
| Expiring token | `--expiration <duration>` | Short-lived access (e.g., `1h`, `7d`) |

**Best practice**: use database-scoped tokens per service. Avoid sharing a single token across multiple services or environments.

---

## Fine-Grained Permissions

Fine-grained permissions restrict a JWT token to specific tables and operations. Pass permissions as a claim when minting tokens via the Platform API.

### Permission Actions

| Action | Description |
|---|---|
| `read` | SELECT from a table |
| `write` | INSERT, UPDATE, DELETE on a table |
| `create` | CREATE TABLE in the database |
| `drop` | DROP TABLE from the database |

### Minting a Restricted Token

```bash
# Read-only access to the 'orders' table
turso db tokens create my-db \
  --claims '{"permissions": {"table": {"orders": {"read": true}}}}'
```

```bash
# Write access to 'orders', read access to 'products'
turso db tokens create my-db \
  --claims '{"permissions": {
    "table": {
      "orders": {"read": true, "write": true},
      "products": {"read": true}
    }
  }}'
```

Use restricted tokens for:
- Public-facing API endpoints (read-only tokens)
- Multi-tenant systems (per-tenant tokens with table restrictions)
- Microservices accessing only their own tables

---

## JWKS / External Auth Providers

Configure Turso to validate JWTs issued by your authentication provider (Clerk, Auth0, Supabase Auth, custom IdP). The provider's JWKS endpoint is used to verify token signatures.

### Setup via CLI

```bash
turso db config set <db-name> \
  --jwks-url "https://your-auth-provider.com/.well-known/jwks.json"
```

### How it works

1. User authenticates with your auth provider
2. Auth provider issues a JWT signed with its private key
3. Client passes the JWT as `authToken` to the libSQL SDK
4. Turso fetches the JWKS from the configured URL and validates the signature
5. If valid, the connection is authorized

### Token Claims for Fine-Grained Permissions

Auth provider JWTs can include a `turso` claim with permission rules:

```json
{
  "sub": "user_123",
  "turso": {
    "permissions": {
      "table": {
        "user_data": { "read": true, "write": true }
      }
    }
  }
}
```

This allows per-user row/table level access control driven entirely by your auth provider.

---

## Security Checklist

- [ ] Store `TURSO_DATABASE_URL` and `TURSO_AUTH_TOKEN` in environment variables — never hardcode in source
- [ ] Use database-scoped tokens, not group-scoped, unless the service needs all databases in the group
- [ ] Use read-only tokens for endpoints that only read data
- [ ] Set token expiration for short-lived tasks (`--expiration 1h`)
- [ ] Apply fine-grained permissions for multi-tenant or public-facing access
- [ ] Rotate tokens periodically via `turso db tokens invalidate`
- [ ] Use JWKS integration to avoid token distribution in multi-user systems
- [ ] Never commit `.env` files containing real tokens to version control
- [ ] Use `file:local.db` with no token for local development to avoid token leakage
- [ ] Enable encryption at rest for embedded replicas containing sensitive data

---

## Environment Variable Patterns

Standard naming across all environments:

```bash
# .env (local dev — no token needed for file:)
TURSO_DATABASE_URL=file:local.db

# .env.staging
TURSO_DATABASE_URL=libsql://mydb-myorg.turso.io
TURSO_AUTH_TOKEN=eyJ...staging-token...

# .env.production
TURSO_DATABASE_URL=libsql://mydb-myorg.turso.io
TURSO_AUTH_TOKEN=eyJ...prod-token...
```

For serverless / edge deployments, set these as secrets in the platform (Vercel, Cloudflare, Fly.io, etc.) rather than committing them to the repository.

Switching between environments with a single code path:

```ts
const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN, // undefined is fine for file: URLs
});
```
