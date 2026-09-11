# 10.0.1.11 - Penny AI (LibreChat) and Meilisearch

Production host running Penny AI, a LibreChat deployment that connects an AI assistant to
backend tools through the Model Context Protocol (MCP). The MCP integration turned the
assistant into a direct path to the database and host. Reached at `penny.allports.tours`.

Testing used the client authorized account `pentester`. See
`../recon/authorized-credentials.txt`.

## Services

| Port | Service | Notes |
|------|---------|-------|
| 80, 443, 3000 | LibreChat (Penny AI) | Web app and API |
| 7700 | Meilisearch | Search API, network reachable |
| 8045 | HTTPS API | Configuration disclosure |
| 8081 | Node.js Express | HTTP basic authentication |

## What was found

- PostgreSQL remote code execution (Critical chain). The PostgreSQL MCP allowed
  `COPY ... FROM PROGRAM`, which runs shell commands on the database server. Running
  `printenv` returned application secrets including AWS keys, a live Stripe key, JWT and
  session secrets, the database encryption key, the Meilisearch master key, and the Redis
  password. See `evidence/ai-chat-transcript-2026-01-10.txt` and the finding write ups in
  the report.
- PostgreSQL arbitrary file read via COPY FROM. The same MCP could read files from the
  server filesystem.
- Unrestricted database access via the PostgreSQL MCP. The assistant executed arbitrary
  SQL, including reading user tables and password hashes.
- AI security bypass via prompt injection. A low privilege user posing as the CTO and
  citing a "security audit" convinced the assistant to extract PII and password hashes
  with no real verification. See `evidence/ai-chat-transcript-2026-01-10.txt`.
- Weak password policy. The exposed config reports `minPasswordLength: 1`. See
  `enumeration/10.0.1.11-api-config-formatted.json`.
- Information disclosure. `/api/config` returns internal architecture detail including
  the MCP server list and LDAP settings without authentication.

## Layout

- `enumeration/` API responses, config dumps, MCP tests, conversation and user data, and
  the Meilisearch responses.
- `evidence/` The AI chat history and transcript that show the RCE and prompt injection,
  a screenshot, and network topology notes discovered through the host.
- `scripts/` API, MCP, session, and Selenium test scripts. Some hold expired session
  tokens from the test window.
