# Findings Summary

This is a short index of the findings. The full write ups, evidence, business impact,
and remediation are in the report under `report/`. Severity and remediation status
below match the approved report (version 2.0.0). Totals: 4 Critical, 5 High,
14 Medium, 7 Low, and 9 Informational.

## Critical

| Finding | Remediation status |
|---------|--------------------|
| MongoExpress web application default credentials | Resolved |
| Unprotected LSASS allows credential theft | Open |
| Unauthenticated climate control access leading to loss of life | Open |
| Weak or default credentials on bridge navigation | Open |

## High

| Finding | Remediation status |
|---------|--------------------|
| Web application broken access control | Resolved |
| Reflected XSS via CRLF injection | Open |
| Password re-use | Partially resolved |
| Information disclosure via source code comments (password hash) | Open |
| SMB signing turned off | Open |

## Medium

| Finding | Remediation status |
|---------|--------------------|
| Exposed Prometheus metrics endpoint | Open |
| Information disclosure via verbose database error messages | Open |
| Lack of rate limiting on authentication service | Open |
| Unauthenticated OpenAPI schema exposure | Resolved |
| Unrestricted database access via PostgreSQL MCP | Open |
| Missing Content Security Policy | Open |
| Reflected XSS via CRLF injection in route parameter (port 8080) | Open |
| Weak password policy | Open |
| PostgreSQL remote code execution | Open |
| Jellyfin default credentials usage | Open |
| Keycloak administrative access via default credentials | Open |
| Stored XSS in route builder functionality (port 8080) | Open |
| Web application information disclosure | Resolved |
| PostgreSQL arbitrary file read via COPY FROM | Open |

## Low

| Finding | Remediation status |
|---------|--------------------|
| Kerberoasting | Partially resolved |
| Missing HTTP security headers | Open |
| Insecure use of HTTP basic authentication | Open |
| Insecure cross-origin resource sharing | Open |
| Sensitive credential hash exposure in web dashboard | Open |
| AI security bypass via prompt injection and social engineering | Open |
| Expired SSL and TLS certificates | Open |

## Informational

- End of life software components
- Information disclosure at chats.allports.tours
- Local file traversal via route parameter on web application
- Missing anti-CSRF tokens
- MySQL username enumeration via exposed service (port 3306)
- Unauthenticated metrics endpoint exposure (/metrics)
- Unrestricted filesystem access via MCP server
- Web application missing authentication (Route Controller, 10.0.1.15:8080)

## Where the evidence lives

The strongest chains and their proof in this repository:

- 10.0.1.11 Penny AI. PostgreSQL remote code execution and arbitrary file read through
  the AI assistant MCP, used to read the database and print environment variables that
  held AWS, Stripe, JWT, and other secrets. Also weak password policy and AI prompt
  injection. See `evidence/10.0.1.11-pennyai/`.
- 10.0.1.10 climate and ballast control. Unauthenticated climate control that accepts
  an out of range setpoint (integer overflow), and ballast control reachable with the
  default login `guest:guest`. See `evidence/10.0.1.10-climate-ballast/`.
- 10.0.1.20 and 10.0.1.21 Deckhand workstations. SMB signing disabled, which enables
  relay attacks. See `evidence/10.0.1.20-deckhand-01/` and `evidence/10.0.1.21-deckhand-02/`.
- 10.0.1.99 Go applications and MySQL. Exposed metrics and pprof endpoints, verbose
  errors, expired certificates, and MySQL username enumeration. See
  `evidence/10.0.1.99-golang-mysql/`.
- 10.0.1.30 Jellyfin. Default credentials. See `evidence/10.0.1.30-jellyfin/`.
