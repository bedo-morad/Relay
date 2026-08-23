# Relay — Version Matrix (spec §6.1 deliverable)

All versions pinned here and in `../docker-compose.yml`. Lockfiles/toolchain files land with the backend/frontend code.

| Layer | Technology | Pinned version                     | Notes |
|---|---|------------------------------------|---|
| Backend | Spring Boot | 4.0.8                              | spec §6, mandatory |
| JVM | Java | 17 (Eclipse Temurin 17.0.19)       | Boot 4 baseline; user-familiar choice, spec allows 17+ |
| Frontend | Angular | 22.1 (TypeScript) + Bootstrap      | spec §6 |
| Node | — | pinned with frontend lockfile      | set when frontend scaffolds |
| Database | PostgreSQL | 18.6                               | source of truth |
| Identity | Keycloak | 26.7.0 (`start-dev` locally)       | owns its own schema `keycloak` in shared Postgres for local dev |
| Cache | Redis | 8.10.0, AOF enabled                | single node per D-15 |
| Object storage | MinIO | RELEASE.2025-09-07T16-13-09Z-cpuv1 | S3-compatible, attachments (D-14); last patched community release — repo archived Apr 2026, RustFS is the swap-in candidate |
| API docs | springdoc-openapi | 3.x                                | must verify Boot 4.x compat when backend scaffolds (§6.1) |
| Build | Maven/Gradle + npm | lockfiles as deliverables          | §13.1 |

## Local port map (defaults, host side)

| Service       | Host port | Container                                     |
|---------------|-----------|-----------------------------------------------|
| Spring Boot   | 8080      | 8080                                          |
| PostgreSQL    | 5432      | 5432                                          |
| Redis         | 6379      | 6379                                          |
| Keycloak      | **9090**  | 8080 (host 8080 reserved for Spring Boot API) |
| MinIO S3 API  | 9000      | 9000                                          |
| MinIO console | 9001      | 9001                                          |

> Local-only: default credentials live in `../.env.example`. In production nothing but nginx/LB is internet-exposed; DB/Redis/MinIO stay on the internal network.

