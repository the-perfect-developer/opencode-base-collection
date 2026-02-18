# E-Commerce Platform Monorepo

Pnpm workspace monorepo for an e-commerce platform with multiple services.

## Workspace Structure

- `packages/shared/` - Shared utilities and types
- `packages/api/` - REST API service (Express + PostgreSQL)
- `packages/web/` - Customer-facing storefront (Next.js)
- `packages/admin/` - Admin dashboard (Next.js)
- `packages/mobile/` - Mobile app (React Native)

## Workspace Commands

- `pnpm -r build` - Build all packages
- `pnpm --filter api dev` - Run specific package
- `pnpm -r test` - Test all packages

## Import Conventions

Use workspace imports, not relative paths between packages:

```typescript
// ✓ Correct
import { formatCurrency } from '@ecommerce/shared/utils'
import { ProductService } from '@ecommerce/api/services'

// ✗ Incorrect
import { formatCurrency } from '../../shared/src/utils'
```

## Code Standards

### TypeScript
- Strict mode enabled
- Explicit return types for exported functions
- Shared types in `packages/shared/types/`

### API Conventions
- Version in path: `/api/v1/products`
- Plural resource names: `/products`, `/orders`, `/users`
- Standard HTTP methods (GET, POST, PUT, DELETE)

### Error Handling
All API errors return JSON:
```json
{
  "error": "Error message",
  "code": "ERROR_CODE",
  "requestId": "uuid"
}
```

## Testing

- Unit tests: `*.test.ts` co-located with source
- Integration tests: `tests/integration/`
- E2E tests: `tests/e2e/` (Playwright)
- Aim for 80%+ coverage on business logic

## Database

- Use Kysely query builder (type-safe SQL)
- Migrations in `packages/api/migrations/`
- Run migrations: `pnpm --filter api migrate`

## Environment Variables

Required in `.env`:
- `DATABASE_URL` - PostgreSQL connection string
- `JWT_SECRET` - Secret for JWT signing
- `REDIS_URL` - Redis connection string
- `STRIPE_SECRET_KEY` - Stripe API key
