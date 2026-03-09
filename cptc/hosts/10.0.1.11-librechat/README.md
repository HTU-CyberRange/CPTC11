# 10.0.1.11 - LibreChat / Penny AI

## Host Overview

**IP Address:** 10.0.1.11
**Hostname:** librechat / penny-ai
**OS:** Linux (containerized)
**Status:** CRITICAL FINDINGS IDENTIFIED
**Testing Status:** Active - Deep Exploitation

---

## Services Discovered

### LibreChat Application - Ports 80/443/3000
- **Protocol:** HTTP/HTTPS
- **Status:** VULNERABLE - Multiple Issues
- **Findings:** F001 (CRITICAL), F003 (HIGH)
- **Description:** AI chatbot interface with backend vulnerabilities

### Meilisearch API - Port 7700
- **Protocol:** HTTP
- **Status:** Exposed
- **Description:** Search engine API, accessible

### API Endpoint - Port 8045
- **Protocol:** HTTPS
- **Status:** Configuration Disclosure
- **Description:** Exposes sensitive configuration data

### Node.js Express - Port 8081
- **Protocol:** HTTP
- **Status:** Basic Authentication
- **Description:** Node.js service with basic auth

---

## Validated Findings

### F001 - Database Access via LibreChat (CRITICAL)
- **Severity:** CRITICAL (CVSS: 9.x+)
- **Status:** Validated with PoC
- **Impact:** Full database access, data exfiltration, potential RCE
- **Evidence:** `/findings/F001-database-access/`
- **Remediation:**
  - Disable MCP database access capabilities
  - Implement strict access controls
  - Network segmentation
- **Files:**
  - `CRITICAL-FINDINGS-SUMMARY.md` - Overview
  - `EXPLOITATION-GUIDE.md` - Step-by-step exploitation
  - `network-topology-discovery.txt` - Network enumeration data

### F003 - Weak Password Policy (HIGH)
- **Severity:** HIGH (CVSS: 7.x)
- **Status:** Validated
- **Impact:** Weak passwords allow brute force attacks
- **Evidence:** `/findings/F003-weak-password/`
- **Remediation:**
  - Increase minimum password length to 12+ characters
  - Implement password complexity requirements
  - Add account lockout mechanism
- **Files:**
  - `10.0.1.11-api-config-formatted.json` - Configuration showing weak policy
  - `10.0.1.11-api-config.txt` - Raw configuration data

---

## Directory Contents

### `/enumeration/`
Contains all enumeration data for this host:
- API endpoint responses (`10.0.1.11-api-*.txt`)
- Configuration dumps (`*.json`)
- Authentication testing results (`auth-test*.txt`)
- Session data (`cookies.txt`, `session-vars.sh`)
- MCP (Model Context Protocol) testing (`mcp-*.txt`, `mcp-*.json`)
- Conversation dumps (`conversations.json`, `convos-raw.txt`)
- User data (`user-info.json`, `messages.json`)
- Web application responses (`initial-page.html`)
- Meilisearch API data (`meilisearch-*.txt`)

### `/findings/`
Contains validated findings specific to this host:
- `F001-database-access/` - Critical database access vulnerability
- `F003-weak-password/` - Password policy issues

### `/evidence/`
Contains screenshots, session recordings, and exploitation evidence

### `/scripts/`
Contains testing scripts specific to this host:
- `test-api.py` - API testing automation
- `test-mcp-agents.py` - MCP agent testing
- `test-admin-endpoints.sh` - Admin endpoint enumeration
- `test-mcp-endpoints.sh` - MCP endpoint testing
- `test-session.sh` - Session management testing
- `selenium-test.py` - Browser automation testing
- `session-vars.sh` - Session variables

---

## Testing Notes

### LibreChat Application
- AI chatbot interface (Penny AI)
- Uses MCP (Model Context Protocol) for tool integration
- **CRITICAL:** MCP filesystem server provides database access
- Configuration disclosure at `/api/config`
- Weak password policy (8 character minimum)
- Multiple API endpoints exposed

### MCP (Model Context Protocol)
- Allows AI to interact with filesystem
- Database file accessible via MCP
- Can read arbitrary files through AI interface
- No proper access controls on sensitive operations

### API Security
- Multiple endpoints discovered and tested
- Configuration endpoint leaks sensitive data
- Authentication tokens in responses
- Session management issues identified

### Database Exposure
- SQLite database accessible
- Contains user data, conversations, API keys
- Network topology information discoverable
- Potential for data exfiltration and manipulation

---

## Priority Actions

1. **CRITICAL:** Disable or severely restrict MCP filesystem access (F001)
2. **CRITICAL:** Implement network segmentation to protect database
3. **HIGH:** Update password policy to 12+ characters (F003)
4. **HIGH:** Restrict access to `/api/config` endpoint
5. **MEDIUM:** Review all exposed API endpoints
6. **MEDIUM:** Implement rate limiting on authentication endpoints

---

## Exploitation Summary

### Current Access Level
- User-level access to LibreChat
- Database read access via MCP
- Configuration disclosure
- Network topology visibility

### Potential for Escalation
- Database write access (not fully tested)
- RCE via MCP capabilities
- Lateral movement to other hosts
- Access to other user data and conversations

### Data at Risk
- User credentials and hashed passwords
- API keys and tokens
- Private conversations and messages
- System configuration
- Network topology information

---

## Related Documentation

- **Main Index:** `/INDEX.md`
- **Findings Report:** `/reports/technical/FINDINGS-REPORT.md`
- **LibreChat Assessment:** `/reports/technical/librechat-security-assessment.md`
- **Executive Summary:** `/reports/executive/EXECUTIVE-SUMMARY.md`

---

**Last Updated:** 2026-01-10
**Responsibility:** Our team
**Status:** Active exploitation and documentation
**Priority:** HIGHEST - Critical vulnerabilities require immediate attention
