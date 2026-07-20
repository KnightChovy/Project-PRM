# SmartStay-AI

AI-powered hotel booking platform — Flutter client + Node.js API in a single repository.

| Workspace             | Stack                                                    | Docs                                 |
| --------------------- | -------------------------------------------------------- | ------------------------------------ |
| [client/](client/)    | Flutter, Clean Architecture, provider, dio, go_router     | [client/README.md](client/README.md) |
| [server/](server/)    | Express + TypeScript, Prisma, PostgreSQL + pgvector       | [server/README.md](server/README.md) |

## Quick start

**1. API** (start this first — the app has nothing to fetch without it)

```bash
cd server
cp .env.example .env      # then fill in DATABASE_URL
npm install
npx prisma migrate dev
npm run dev               # → http://localhost:5000
```

**2. App**

```bash
cd client
flutter pub get
flutter run
```

## Configuring the API endpoint

The client reads its base URL from
[client/lib/core/constants/api_constants.dart](client/lib/core/constants/api_constants.dart).

Pick the host that matches your target — `localhost` resolves to the *device*,
not your machine, on everything except desktop and iOS simulator:

| Target             | Base URL                     |
| ------------------ | ---------------------------- |
| Android emulator   | `http://10.0.2.2:5000/v1`    |
| iOS simulator      | `http://localhost:5000/v1`   |
| Desktop (win/macOS)| `http://localhost:5000/v1`   |
| Physical device    | `http://<your-LAN-IP>:5000/v1` |

## Repository layout

One git repository, two independent workspaces. They share no code and no build
step — the only contract between them is the REST API.

See [CLAUDE.md](CLAUDE.md) for conventions and commit prefixes.
