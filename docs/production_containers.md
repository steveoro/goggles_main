# Production container architecture

This document describes the deployed container topology of the Goggles stack on the
production droplet. All components are defined in `docker-compose.prod.yml` (extracted
from the `goggles-main` image at each deploy) and started by
`config/goggles_deploy.public/deploy_prod.sh`.

## Services overview

```text
                        host reverse proxy (TLS termination)
                          │                │
                    127.0.0.1:8080   127.0.0.1:8081
                          │                │
┌─────────────────────────┼────────────────┼─────────────────────────────────────┐
│ docker network          │                │                                     │
│                    ┌────▼─────┐    ┌─────▼─────┐                               │
│                    │  main    │    │   api     │                               │
│                    │ Puma 8080│    │ Puma 8081 │                               │
│                    │ (Main UI)│    │ (REST API)│                               │
│                    └────┬─────┘    └─────┬─────┘                               │
│                         │                │                                     │
│                    ┌────▼─────┐          │                                     │
│                    │  jobs    │          │   ┌──────────────────┐              │
│                    │ bin/jobs │          │   │   autoheal       │              │
│                    │ Solid Q. │          │   │ restarts labeled │              │
│                    │ supervis.│          │   │ unhealthy svcs   │              │
│                    └────┬─────┘          │   └────────▲─────────┘              │
│                         │                │            │docker.sock             │
│                    ┌────▼────────────────▼─┐          │                        │
│                    │     goggles-db        │          │                        │
│                    │    mariadb:11.8.6     │   127.0.0.1:33060 -> :3306        │
│                    └───────────────────────┘                                   │
└────────────────────────────────────────────────────────────────────────────────┘
```

| Service     | Image                         | Entrypoint / command                | Exposed port          | Restart policy |
| ----------- | ----------------------------- | ----------------------------------- | --------------------- | -------------- |
| `goggles-db`| `mariadb:11.8.6`               | stock entrypoint, `--max_allowed_packet=64M` | `127.0.0.1:33060` | `always` + healthcheck |
| `api`       | `steveoro/goggles-api:$TAG`    | `entrypoints/docker.prod.sh`        | `127.0.0.1:8081`      | `always`       |
| `main`      | `steveoro/goggles-main:$TAG`   | `entrypoints/docker.prod.sh`        | `127.0.0.1:8080`      | `always` + healthcheck (`/up`¹) + `autoheal` |
| `jobs`      | `steveoro/goggles-main:$TAG`   | `entrypoints/jobs.prod.sh`          | none                  | `always` + heartbeat healthcheck + `autoheal` |
| `autoheal`  | `willfarrell/autoheal:latest`  | stock                               | none                  | `always`       |

## Process model

- `main` — `rails db:prepare` (creates/migrates all DBs, incl. support DBs) →
  `exec rails s -b 0.0.0.0 -p 8080`. Single Puma process, 5 threads.
- `jobs` — `rails db:prepare` (idempotent no-op once `main` is healthy, see boot
  order) → `exec bin/jobs`: the Solid Queue **fork supervisor** spawning
  - a **worker** (`queues: *`, 3 threads),
  - a **dispatcher** (scheduled-execution dispatching + concurrency maintenance),
  - a **scheduler** (recurring tasks from `config/recurring.yml`).
- `api` — `exec rails s -b 0.0.0.0 -p 8081`. No Solid* components at all.
- `autoheal` — polls the Docker socket every `AUTOHEAL_INTERVAL` (60 s) and
  restarts containers carrying the `autoheal` label while they report `unhealthy`.

¹ `main`'s probe sends `X-Forwarded-Proto: https` because `config.force_ssl`
301-redirects plain HTTP to HTTPS — without the header wget dies doing TLS on a
plain-HTTP port and the container flaps `unhealthy`.

## Boot order (health gating)

```text
goggles-db  ──(healthcheck: mariadb-admin ping)──▶ healthy
    │
    ▼
api ──────────────────────────────── starts
main ── db:prepare ── puma /up ────── healthy
    │                                   ▲
    └── jobs (depends_on main:          │
         service_healthy, so support    │
         DBs already exist)             │
                                        │
autoheal ── watches: main, jobs ────────┘
```

## Databases

All databases live inside the `goggles-db` MariaDB container
(volume `~/Projects/goggles_deploy/db.prod` → `/var/lib/mysql`):

| Database        | Used by            | Contents                                    |
| --------------- | ------------------ | ------------------------------------------- |
| `goggles`       | `api`, `main`, `jobs` | primary application data                  |
| `goggles_queue` | `main` (enqueue), `jobs` | Solid Queue: jobs, executions, processes, recurring tasks |
| `goggles_cable` | `main`             | Solid Cable messages                        |

Rails cache is `:memory_store` inside the `main` Puma process — no cache DB, no
request-path DB hits for Rack::Attack counters, fragment caches, or
`Rails.cache.fetch` calls.

Schema sources: `db/queue_schema.rb` / `db/cable_schema.rb` (loaded by
`rails db:prepare` because each support DB sets `schema_format: :ruby`), then
pending migrations from `db/queue_migrate` / `db/cable_migrate`.

## Volumes / secrets

| Host path (deploy dir)                | Mounted into            | Purpose                       |
| ------------------------------------- | ----------------------- | ----------------------------- |
| `storage.prod`                        | `api`, `main`, `jobs`   | ActiveStorage files           |
| `backups`                             | `api`, `main`, `jobs`   | `db/dump` — backup & batch SQL files (ImportProcessorJob) |
| `db.prod`                             | `goggles-db`            | MariaDB datadir               |
| `log.prod`                            | `api`, `main`           | `production.log` (jobs logs to docker stdout instead) |
| `master-api.key`, `master-main.key`   | `api`, `main`, `jobs` (ro) | Rails master keys          |
| `/var/run/docker.sock`                | `autoheal`              | container watchdog            |

`.env` (uncommitted, in the deploy dir): `MYSQL_ROOT_PASSWORD`, `TAG`,
`DATABASE_*`, `SECRET_KEY_BASE`, `RAILS_MASTER_KEY`. Docker Hub credentials are
never stored — `deploy_prod.sh` receives them from CI/manual export for
`docker login` only.

## Deploy flow

```text
CircleCI/manual:  deploy_prod.sh (TAG from .env)
        │
        ├─ docker pull goggles-main:$TAG, goggles-api:$TAG
        ├─ extract docker-compose.prod.yml from the goggles-main image
        ├─ compose down
        ├─ up -d goggles-db    → wait healthy
        └─ up -d --no-build api main jobs autoheal
```

`main` runs `db:prepare` at boot, so new migrations and the support DBs are
applied automatically during rollout. `jobs` waits for `main` to report healthy.

## Notes

- Solid Queue/Cable used to live in per-service SQLite files under `storage.prod`.
  They were moved to MariaDB to eliminate file-lock stalls (`SQLite3::BusyException`)
  under the multi-process load. Leftover `production_*.sqlite3*` files in
  `storage.prod` are dormant and can be removed.
- `main` used to run `bin/jobs` in-process backgrounded; it is now a dedicated
  service so its supervisor has an independent restart lifecycle.
- `autoheal` needs the Docker socket — it runs with implicit host-root
  equivalence. Keep its image pinned and the socket mount read-only in spirit
  (write access is required for `docker restart`).
