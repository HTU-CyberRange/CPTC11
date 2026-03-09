# Findings Tracking Document
# Engagement: allports.local Penetration Test

## Finding Status Legend
- DISCOVERED: Initial discovery, requires validation
- TESTING: Actively testing/validating
- VALIDATED: Confirmed and reproducible
- DOCUMENTED: Ready for final report
- FALSE_POSITIVE: Not a valid finding

---

## Finding F001: Unauthorized Database Access via LibreChat MCP
Status: TESTING
Discovered: 2026-01-09
Target: 10.0.1.11 (penny.allports.tours)

Description:
LibreChat application exposes Postgres MCP (Model Context Protocol) server that allows authenticated users to execute arbitrary SQL queries against the application database.

Initial Discovery:
- User "pentester" can execute SELECT queries against all tables
- Database contains 19 tables including user_account, staff_list, customer_details, order, etc.
- No apparent query restrictions or access controls

Evidence Location: /home/pentester/cptc/evidence/F001/

Testing Required:
- [ ] Confirm table enumeration
- [ ] Extract user_account table (credentials)
- [ ] Extract staff_list table (credentials)
- [ ] Extract customer_details (PII)
- [ ] Test for data modification (INSERT/UPDATE/DELETE)
- [ ] Test for privilege escalation
- [ ] Test cross-user access (can we see other users' data)
- [ ] Determine if this is intended functionality or misconfiguration

Severity: TBD (pending impact assessment)
CVSS: TBD

---

## Finding F002: Integer Overflow in Climate Control System
Status: DISCOVERED
Discovered: 2026-01-09 (by orchestrator agent)
Target: 10.0.1.10:6768

Description:
Climate Control System displays temperature value of 1.0e32 degrees Celsius, suggesting integer overflow condition.

Evidence Location: /home/pentester/cptc/custom-protocols/climate-control-status.txt

Testing Required:
- [ ] Reproduce the overflow condition
- [ ] Determine if overflow is controllable by attacker
- [ ] Assess if this affects actual control systems or just display
- [ ] Test for buffer overflow or memory corruption
- [ ] Determine actual impact on physical systems

Severity: CRITICAL (preliminary)
CVSS: 9.8 (preliminary, requires validation)

---

## Finding F003: Weak Password Policy in LibreChat
Status: DISCOVERED
Discovered: 2026-01-09 (by orchestrator agent)
Target: 10.0.1.11

Description:
LibreChat configuration allows 1-character passwords.

Evidence Location: /home/pentester/cptc/web-apps/10.0.1.11-api-config-formatted.json

Testing Required:
- [ ] Verify configuration is actually enforced
- [ ] Attempt to create account with 1-character password
- [ ] Check if existing accounts use weak passwords
- [ ] Test password complexity requirements

Severity: HIGH (preliminary)
CVSS: 7.5 (preliminary, requires validation)

---

## Finding F004: SMB Signing Not Required
Status: DISCOVERED
Discovered: 2026-01-09 (by orchestrator agent)
Target: 10.0.1.20, 10.0.1.21

Description:
Windows workstations have SMB signing enabled but not required, potentially vulnerable to relay attacks.

Evidence Location: /home/pentester/cptc/windows-enum/nxc-smb-scan.txt

Testing Required:
- [ ] Verify SMB signing status with multiple tools
- [ ] Determine if NTLM relay attack is feasible
- [ ] Check if systems are otherwise hardened against relay
- [ ] Assess actual exploitability in this network

Severity: HIGH (preliminary)
CVSS: 8.1 (preliminary, requires validation)

---

## Finding F005: Authentication Issues in Ballast Control System
Status: DISCOVERED
Discovered: 2026-01-09 (by orchestrator agent)
Target: 10.0.1.10:9000

Description:
Ballast Control System requires authentication but may lack rate limiting or account lockout.

Evidence Location: /home/pentester/cptc/custom-protocols/ballast-control-prompt.txt

Testing Required:
- [ ] Test for rate limiting on login attempts
- [ ] Test for account lockout after failed attempts
- [ ] Attempt credential guessing with common passwords
- [ ] Determine if timing attacks are possible

Severity: HIGH (preliminary)
CVSS: 8.1 (preliminary, requires validation)

---

## Next Steps

Priority 1: Complete validation of F001 (Database Access)
- Extract all sensitive data
- Document exact access capabilities
- Determine if data modification is possible

Priority 2: Validate F002 (Integer Overflow)
- Reproduce condition
- Determine exploitability

Priority 3: Test remaining findings

Priority 4: Prepare findings for formal report
