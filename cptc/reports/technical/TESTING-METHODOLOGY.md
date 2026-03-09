# Penetration Testing Methodology
# Target: allports.local (10.0.1.0/24)

## Testing Phases

### Phase 1: Information Gathering (COMPLETED)
- Network reconnaissance via nmap
- Service enumeration
- Technology identification
- Attack surface mapping

### Phase 2: Vulnerability Discovery (IN PROGRESS)
Current focus areas:
1. LibreChat/Penny AI application testing
2. Database access via MCP servers
3. Custom protocol testing (Climate Control, Ballast Control)
4. Web application vulnerabilities
5. Windows workstation testing

### Phase 3: Exploitation & Validation (ACTIVE)
For each potential finding:
1. Document initial discovery
2. Develop proof of concept
3. Test reproducibility
4. Capture evidence (screenshots, command output, database dumps)
5. Assess impact
6. Validate with confirmation before finalizing

### Phase 4: Reporting
- Categorize findings by severity
- Document technical details
- Provide remediation guidance
- Include evidence for each finding

---

## Current Testing Targets

### Target 1: LibreChat/Penny AI (10.0.1.11 / penny.allports.tours)
Status: ACTIVE TESTING
Access: Authorized credentials provided
Available tools: Postgres MCP server

Testing areas:
- Database enumeration and data extraction
- Privilege escalation via database access
- Cross-user data leakage
- Sensitive data exposure
- Authentication bypass possibilities

### Target 2: Custom Control Systems (10.0.1.10)
Status: INITIAL TESTING COMPLETED
Services:
- Climate Control System (port 6768)
- Ballast Control System (port 9000)

Findings requiring validation:
- Integer overflow in Climate Control
- Authentication weaknesses in Ballast Control

### Target 3: Web Services (10.0.1.11, 10.0.1.99)
Status: ENUMERATION COMPLETED
Pending deeper testing:
- API endpoint security
- Authentication mechanisms
- File upload vulnerabilities

### Target 4: Windows Workstations (10.0.1.20, 10.0.1.21)
Status: ENUMERATION COMPLETED
Finding requiring validation:
- SMB signing disabled

---

## Evidence Collection Standards

For each finding, collect:
1. Command executed or test performed
2. Full output/response
3. Timestamp of discovery
4. Reproduction steps
5. Screenshot or log file
6. Impact assessment

Evidence storage: /home/pentester/cptc/evidence/[finding-id]/

---

## Validation Checklist

Before documenting a finding as confirmed:
- [ ] Reproduced at least twice
- [ ] Evidence collected and stored
- [ ] Impact accurately assessed
- [ ] No assumptions made in technical details
- [ ] Remediation steps verified as technically sound
- [ ] Severity rating justified with CVSS if applicable

---

## Out of Scope Reminders

DO NOT TEST:
- 10.0.1.6 (Active Directory Domain Controller)
- 10.0.1.13 (Excluded per client request)
- Any underlying cloud infrastructure
- Competition platform (laforge)
- Infrastructure layer (hypervisor, metadata services)

SCOPE LIMITED TO:
- Application layer only
- 10.0.1.0/24 network
- prod.allports.local domain
- Services and applications running on target hosts
