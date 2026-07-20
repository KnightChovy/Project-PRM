# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SmartStay AI backend — a hotel booking platform REST API (graduation project). Node.js + Express + TypeScript + PostgreSQL + Prisma 7. This `server/` directory is part of a monorepo; the React frontend lives in `../client/`.

**Read `AGENTS.md` first** — it contains the full conventions, code templates (controller/service/validation/route), and the pre-commit checklist (in Vietnamese). Note where it has drifted from the actual code:

- It references `src/docs/routes.yml`; the actual file is `src/docs/swagger.yml` (swagger-jsdoc loads `src/docs/*.yml`). Endpoint docs still must be updated there whenever routes change.
- Its templates show object-literal service exports; the actual services are **classes exported as singleton instances** (`export const authService = new AuthService()` in `src/services/auth.service.ts`). Follow the real code.
- It shows `import prisma from '@/config/prisma'`; there are **no path aliases** in `tsconfig.json` — use relative imports (`../config/prisma`).

## Commands

```bash
npm run dev          # nodemon + tsx, hot-reloads on .ts/.json/.yml changes
npm run build        # tsc → dist/ (must pass before commit)
npm start            # run compiled dist/index.js
npm run lint         # eslint (airbnb-base + security + prettier)
npm run lint:fix

# Database (Prisma; prisma.config.js loads .env for DATABASE_URL)
npx prisma db push       # sync schema to dev DB
npx prisma migrate dev   # create/apply a migration
npx prisma db seed       # runs tsx prisma/seed.ts
npx prisma generate      # regenerate client after schema changes
```

Tests: `npm test` (jest, serial) / `npx jest tests/integration/auth.test.js` / `npx jest -t "test name"` for a single test. **Caveat:** the `tests/` directory is leftover boilerplate from the original Mongoose template (`setupTestDB.js` connects to MongoDB, fixtures use Mongoose models) — it predates the Prisma migration and does not test the current code.

Husky pre-commit runs lint-staged (eslint on staged `.js` only — TypeScript errors are caught by `npm run build`, not the hook).

Setup: copy `.env.example` → `.env`. `src/config/config.ts` validates env with Joi at startup and **throws if `NODE_ENV`, `DATABASE_URL`, or `JWT_SECRET` are missing**.

## Architecture

Request flow (strict layering — see AGENTS.md templates):

```
Route (mounts auth + validate middleware)
  → Controller (wrapped in catchAsync; parse req, call service, send response — NO business logic)
    → Service (business logic; ALL DB access via the shared prisma instance from src/config/prisma)
```

- **Errors:** throw `new ApiError(status, message)` anywhere; `catchAsync` forwards to `errorConverter`/`errorHandler` in `src/middlewares/error.ts`, which produce a uniform JSON shape. Never write try/catch boilerplate in controllers.
- **Validation:** every endpoint that accepts input gets a Joi schema in `src/validations/` mounted via `validate(schema)` at the route layer.
- **Prisma:** single client in `src/config/prisma.ts` (pg Pool + `@prisma/adapter-pg`). Never instantiate `PrismaClient` elsewhere. Schema in `prisma/schema.prisma` is large (full hotel platform: hotels, rooms, bookings, payments, reviews, AI chat, loyalty, marketing) — most models have no API yet; only Auth & Users are implemented.
- **Routes:** versioned under `/v1` (`src/routes/v1/index.ts`). Swagger UI at `/v1/docs` (development only).
- **DTOs:** request/service input types live in `src/dto/` (e.g. `CreateUserDto`), separate from Prisma types.

### Auth system (the implemented core)

- **Registration is OTP-gated:** `generateAndSendOtp` emails a 6-digit code (stored hashed in `verification_tokens`, 10-min expiry, locked after 5 wrong attempts), then `registerUser` consumes it. In non-production the OTP is logged to console so SMTP isn't required locally.
- **Refresh tokens are sessions:** stored hashed (`hashToken`) in `user_sessions`, rotated on every refresh. A replayed (already-revoked) token is treated as theft → all the user's sessions are revoked (`auth.service.ts` `refreshAuth`).
- **RBAC:** `src/config/roles.ts` maps the 7 `UserRole` enum values to rights; `auth('someRight')` middleware enforces them. A user without the right can still access a resource when `req.params.userId` equals their own id.
- Always return users through `sanitizeUser()` (strips `passwordHash`).

## Conventions

- TypeScript strict; **never use `any`**; explicit param and return types.
- Readability is the top priority after correctness/security (this is a graduation project) — short single-purpose functions, no premature abstraction, comment the "why" only for non-obvious code (especially security logic).
- File names: `feature.layer.ts` (e.g. `auth.controller.ts`, `user.validation.ts`).
- Conventional Commits: `<type>(<scope>): <description>` — scopes like `auth`, `user`, `booking`, `database`, `swagger`, `middleware`.
- When adding/changing an endpoint, update `src/docs/swagger.yml` in the same change.
