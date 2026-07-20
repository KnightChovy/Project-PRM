# SmartStay-AI — Monorepo Root

AI-powered hotel booking platform. This repository holds two independent
workspaces. **There is exactly one `.git`, at this root.**

```
Project-PRM/
├── client/   Flutter app  — Clean Architecture, provider/ChangeNotifier
└── server/   Node.js API  — Express + TypeScript + PostgreSQL + pgvector
```

## Rules of engagement

**Read the workspace's own rule file before writing code in it.**

| Workspace | Rule file                              | Scope                                        |
| --------- | -------------------------------------- | -------------------------------------------- |
| `client/` | [client/CLAUDE.md](client/CLAUDE.md)   | Clean Architecture, layers, DI, state mgmt    |
| `server/` | [server/CLAUDE.md](server/CLAUDE.md), [server/AGENTS.md](server/AGENTS.md) | API conventions, Prisma, service structure |

`client/CLAUDE.md` is **binding for Flutter code only**. Do not apply its
Dependency Rule / `Either<Failure, T>` conventions to `server/`, and do not
apply server conventions to `client/`.

## Cross-workspace boundary

The two workspaces communicate **only over HTTP**. There is no shared code,
no shared build, no import path crossing the boundary.

- The contract is the REST API. When an endpoint changes, both sides must be
  updated — but in separate, clearly-scoped commits.
- Client base URL: `client/lib/core/constants/api_constants.dart`
- Server port: `5000` (see `server/.env.example`)

## Commit convention

Prefix the touched workspace so history stays readable:

```
feat(client): add hotel search filters
fix(server): correct pgvector similarity threshold
chore: bump CI node version          ← root-level only
```

Avoid commits that touch both `client/` and `server/` unless the change is
genuinely atomic (e.g. a breaking API rename shipped together).

## Local development

```bash
# API — must be running before the app can fetch anything
cd server && npm install && npm run dev      # → http://localhost:5000

# App
cd client && flutter pub get && flutter run
```

## Tooling notes

- Each workspace owns its `.gitignore`. Root `.gitignore` covers OS/IDE noise only.
- Husky hooks under `server/.husky/` are currently **inactive** — husky installs
  into the git root's `.git/hooks`, and the git root is now this directory.
  Do not assume pre-commit lint runs; run `npm run lint` in `server/` manually.
