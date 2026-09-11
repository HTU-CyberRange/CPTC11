# 10.0.1.99 - Go Applications and MySQL

Production host running several Go web applications and a MySQL database.

## Services

| Port | Service | Notes |
|------|---------|-------|
| 80, 443, 8080 | Go web applications | Multiple instances |
| 3306 | MySQL 8.0.43 | No default credentials, but username enumeration possible |

## What was found

- Exposed Prometheus metrics and Go pprof endpoints. `/metrics` and `/debug/pprof`
  respond without authentication and leak runtime and memory detail. See
  `evidence/web-security/` and `evidence/api-testing/`.
- MySQL username enumeration (Info). The service on 3306 is reachable and its handshake
  allows probing for valid usernames. Default and empty root credentials were tested and
  did not work. See `evidence/database-security/` and `enumeration/10.0.1.99-mysql-*.txt`.
- Verbose configuration issues. Missing HTTP security headers, expired SSL and TLS
  certificates, and permissive CORS were observed across the web ports. See
  `evidence/network-security/`.

## Layout

- `enumeration/` Root pages, endpoint probes, and MySQL enumeration output.
- `evidence/api-testing/` API, GraphQL, and Swagger probes across the web ports.
- `evidence/web-security/` Metrics and pprof responses.
- `evidence/database-security/` MySQL credential tests and nmap output.
- `evidence/network-security/` TLS certificate, cipher, and header checks.
- `scripts/` Enumeration scripts for the web apps and MySQL.
