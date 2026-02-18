# Task Management App

Full-stack task management application using the MERN stack (MongoDB, Express, React, Node.js).

## Project Structure

- `server/` - Express API server
- `client/` - React frontend (Vite + TypeScript)
- `shared/` - Shared TypeScript types

## Tech Stack

- **Backend**: Node.js 20, Express, MongoDB (Mongoose)
- **Frontend**: React 18, TypeScript, Vite, TanStack Query
- **Testing**: Vitest (unit), Playwright (E2E)
- **Auth**: JWT-based authentication

## Development Workflow

### Local Development
- `npm run dev:server` - Start API server (port 3001)
- `npm run dev:client` - Start React dev server (port 5173)
- `npm run dev` - Start both concurrently

### Testing
- `npm test` - Run all tests
- `npm run test:unit` - Unit tests only
- `npm run test:e2e` - E2E tests only

### Database
- `npm run db:seed` - Seed development database
- `npm run db:reset` - Reset and reseed database

## Code Standards

### TypeScript
- Strict mode enabled
- Use shared types from `shared/types.ts`
- Explicit return types for API route handlers

### React
- Use functional components with hooks
- Custom hooks in `client/src/hooks/`
- TanStack Query for all API calls (no manual fetch)

### API Design

**Endpoints**:
- `/api/v1/tasks` - Task CRUD operations
- `/api/v1/auth` - Authentication endpoints
- `/api/v1/users` - User management

**Authentication**:
- Include JWT in `Authorization: Bearer <token>` header
- Refresh tokens stored in httpOnly cookies

**Error Responses**:
```json
{
  "error": "Error message",
  "code": "VALIDATION_ERROR",
  "details": {
    "field": "email",
    "message": "Invalid email format"
  }
}
```

## Testing Strategy

### Unit Tests
- Co-located with source files
- Mock external dependencies (database, APIs)
- Focus on business logic

### Integration Tests
- Test API endpoints with test database
- Use supertest for HTTP assertions
- Clean up test data in afterEach

### E2E Tests
- Test critical user flows (login, create task, etc.)
- Use Playwright for browser automation
- Run against local development server

## Environment Variables

### Development (.env.development)
- `MONGODB_URI=mongodb://localhost:27017/taskapp`
- `JWT_SECRET=dev-secret-key`
- `PORT=3001`

### Production (.env.production)
- `MONGODB_URI=<production-mongodb-url>`
- `JWT_SECRET=<secure-random-secret>`
- `PORT=3001`
- `NODE_ENV=production`

## Deployment

### Backend (Render)
1. Push to main branch
2. Auto-deploy via Render
3. Run migrations: `npm run migrate`

### Frontend (Vercel)
1. Push to main branch
2. Auto-deploy via Vercel
3. Environment variables set in Vercel dashboard
