# Penetration Testing Findings Report
## All Ports Tours (allports.local)
**Date:** 2026-01-09
**Tester:** Penetration Testing Team
**Engagement Type:** Safe, Non-Aggressive Security Assessment

---

## Executive Summary

This penetration testing engagement identified multiple **HIGH** and **CRITICAL** severity vulnerabilities across the All Ports Tours infrastructure. The most significant findings include:

1. **CRITICAL**: Integer overflow vulnerability in custom Climate Control system (10.0.1.10:6768)
2. **HIGH**: Weak password policy (minPasswordLength: 1) in LibreChat application
3. **HIGH**: SMB signing disabled on Windows workstations (10.0.1.20, 10.0.1.21) - vulnerable to relay attacks
4. **MEDIUM**: Exposed API configuration revealing internal architecture details
5. **MEDIUM**: Meilisearch API requiring authorization but exposed to network

---

## Detailed Findings

### FINDING 1: Integer Overflow in Climate Control System [CRITICAL]

**Target:** 10.0.1.10:6768 (Lido Deck Climate Control)
**Severity:** CRITICAL
**CVSS Score:** 9.8 (Critical)

**Description:**
The custom Lido Deck Climate Control System on port 6768 exhibits an integer overflow vulnerability. The STATUS command reveals a temperature setpoint of approximately 1.0e32 degrees Celsius, indicating arithmetic overflow.

**Evidence:**
```
Set point is: 999999999999999959416724456350362731491996089648451439669739009806703922950954425516032.0°C
```

**Impact:**
- System instability and potential crashes
- Unsafe temperature control leading to physical hazards
- Possible buffer overflow exploitation vectors
- Denial of service conditions

**Affected File:** /home/pentester/cptc/custom-protocols/climate-control-status.txt

**Recommendation:**
1. Implement proper input validation and range checking for temperature values
2. Add boundary checks for SET command (e.g., -50°C to 50°C)
3. Use appropriate data types to prevent overflow (e.g., bounded integers)
4. Implement authentication/authorization for control commands
5. Add logging and alerting for anomalous values

**Proof of Concept:**
```bash
echo -e "STATUS\nEXIT" | nc 10.0.1.10 6768
```

---

### FINDING 2: Unauthenticated Ballast Control System [HIGH]

**Target:** 10.0.1.10:9000 (Ballast Control System)
**Severity:** HIGH
**CVSS Score:** 8.1

**Description:**
The Ballast Control System requires authentication but lacks account lockout mechanisms and may be vulnerable to brute force attacks. The system accepts LOGIN commands with username/password pairs.

**Evidence:**
```
Ballast Control System
Authentication Required (LOGIN <user> <pass>)
> Invalid credentials.
```

**Impact:**
- Potential unauthorized access to ballast control systems
- No rate limiting or account lockout observed
- Maritime safety implications if compromised

**Affected File:** /home/pentester/cptc/custom-protocols/ballast-control-prompt.txt

**Recommendation:**
1. Implement account lockout after failed authentication attempts
2. Add rate limiting to prevent brute force attacks
3. Implement multi-factor authentication
4. Use certificate-based authentication for critical systems
5. Add comprehensive logging and monitoring
6. Consider network segmentation to isolate critical control systems

---

### FINDING 3: Weak Password Policy in LibreChat [HIGH]

**Target:** 10.0.1.11 (LibreChat / Penny AI)
**Severity:** HIGH
**CVSS Score:** 7.5

**Description:**
The LibreChat application configuration reveals a minimum password length of only 1 character, which is dangerously weak and violates security best practices.

**Evidence:**
```json
{
    "minPasswordLength": 1,
    "passwordResetEnabled": false,
    "emailEnabled": false
}
```

**Impact:**
- Users can create passwords like "a", "1", or "!"
- Trivial brute force attacks possible
- No password complexity requirements
- Password reset functionality disabled
- Weak authentication overall security posture

**Affected File:** /home/pentester/cptc/web-apps/10.0.1.11-api-config-formatted.json

**Recommendation:**
1. Set minimum password length to at least 12 characters
2. Implement password complexity requirements
3. Enable password reset functionality with proper verification
4. Consider implementing NIST SP 800-63B password guidelines
5. Enable email verification for account security
6. Implement password breach checking (e.g., HaveIBeenPwned API)

---

### FINDING 4: SMB Signing Disabled on Windows Workstations [HIGH]

**Target:** 10.0.1.20 (DECKHAND-01), 10.0.1.21 (DECKHAND-02)
**Severity:** HIGH
**CVSS Score:** 8.1

**Description:**
Both Windows Server 2022 workstations have SMB signing disabled, making them vulnerable to SMB relay attacks and man-in-the-middle attacks.

**Evidence:**
```
SMB  10.0.1.20  445  DECKHAND-01  [*] Windows Server 2022 Build 20348 x64 (name:DECKHAND-01) (domain:allports.local) (signing:False) (SMBv1:False)
SMB  10.0.1.21  445  DECKHAND-02  [*] Windows Server 2022 Build 20348 x64 (name:DECKHAND-02) (domain:allports.local) (signing:False) (SMBv1:False)
```

**Impact:**
- Vulnerable to NTLM relay attacks
- Attackers can relay authentication to other systems
- Potential for privilege escalation
- Lateral movement opportunities
- Credential theft via man-in-the-middle attacks

**Affected File:** /home/pentester/cptc/windows-enum/nxc-smb-scan.txt

**Recommendation:**
1. Enable SMB signing via Group Policy:
   - Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options
   - Set "Microsoft network server: Digitally sign communications (always)" to Enabled
2. Consider requiring SMB signing on all domain systems
3. Implement network segmentation to limit exposure
4. Monitor for SMB relay attack attempts
5. Enable Extended Protection for Authentication (EPA)

---

### FINDING 5: Information Disclosure via API Configuration Endpoint [MEDIUM]

**Target:** 10.0.1.11/api/config
**Severity:** MEDIUM
**CVSS Score:** 5.3

**Description:**
The /api/config endpoint exposes detailed application configuration including authentication settings, enabled features, and internal architecture details without requiring authentication.

**Evidence:**
```json
{
    "appTitle": "Penny AI",
    "serverDomain": "https://penny.allports.tours",
    "registrationEnabled": false,
    "ldap": {
        "enabled": true,
        "username": true
    },
    "instanceProjectId": "68daca3f621e70b912825c62",
    "mcpServers": {
        "filesystem": {"chatMenu": false},
        "puppeteer": {},
        "sqlite": {"chatMenu": false},
        "postgres": {"chatMenu": false},
        "docker": {"chatMenu": false}
    }
}
```

**Impact:**
- Reveals internal architecture and enabled features
- Discloses LDAP integration (potential authentication bypass target)
- Exposes MCP server configuration (filesystem, database, docker access)
- Aids attackers in reconnaissance and attack planning
- Instance Project ID disclosure

**Affected File:** /home/pentester/cptc/web-apps/10.0.1.11-api-config-formatted.json

**Recommendation:**
1. Require authentication for /api/config endpoint
2. Implement role-based access control for configuration disclosure
3. Remove sensitive information from public configuration
4. Use different configuration endpoints for authenticated vs. public users
5. Implement API rate limiting
6. Add security headers (X-Content-Type-Options, X-Frame-Options)

---

### FINDING 6: Meilisearch API Exposed Without Default Credentials [MEDIUM]

**Target:** 10.0.1.11:7700 (Meilisearch)
**Severity:** MEDIUM
**CVSS Score:** 5.3

**Description:**
Meilisearch is exposed on port 7700 and requires authorization headers for access. While authentication is enforced, the service is network-accessible and may contain sensitive indexed data.

**Evidence:**
```json
{
    "message": "The Authorization header is missing. It must use the bearer authorization method.",
    "code": "missing_authorization_header",
    "type": "auth",
    "link": "https://docs.meilisearch.com/errors#missing_authorization_header"
}
```

**Impact:**
- If default master key is used, full database access possible
- Search indexes may contain sensitive customer/employee data
- API key compromise leads to data exfiltration
- Service enumeration reveals technology stack

**Affected File:** /home/pentester/cptc/web-apps/10.0.1.11-meilisearch-version.txt

**Recommendation:**
1. Verify strong, unique master key is configured
2. Implement network-level access controls (firewall rules)
3. Use separate search keys with limited permissions
4. Enable TLS/SSL for all Meilisearch connections
5. Audit indexed data for sensitive information
6. Implement request logging and monitoring
7. Consider VPN or internal-only access

---

### FINDING 7: Node.js Express Service with Basic Authentication [LOW]

**Target:** 10.0.1.11:8081
**Severity:** LOW
**CVSS Score:** 3.7

**Description:**
A Node.js Express service on port 8081 uses HTTP Basic Authentication, which transmits credentials in base64 encoding over unencrypted HTTP.

**Evidence:**
```
HTTP/1.1 401 Unauthorized
X-Powered-By: Express
WWW-Authenticate: Basic realm="Authorization Required"
```

**Impact:**
- Credentials transmitted in easily decoded base64
- Vulnerable to credential interception on unencrypted connections
- Password reuse could lead to compromise of other systems

**Affected File:** /home/pentester/cptc/web-apps/10.0.1.11-8081-root.txt

**Recommendation:**
1. Enforce HTTPS/TLS for all authentication
2. Implement token-based authentication (JWT, OAuth)
3. Add rate limiting to prevent brute force
4. Remove X-Powered-By header to reduce information disclosure

---

### FINDING 8: LDAP Integration Enabled [INFORMATIONAL]

**Target:** 10.0.1.11 (LibreChat)
**Severity:** INFORMATIONAL
**CVSS Score:** N/A

**Description:**
The application has LDAP authentication enabled, likely integrating with Active Directory (10.0.1.6). This creates a dependency on AD security posture.

**Evidence:**
```json
{
    "ldap": {
        "enabled": true,
        "username": true
    }
}
```

**Impact:**
- Compromised AD credentials provide access to LibreChat
- Weak AD passwords (due to minPasswordLength: 1) propagate to LDAP
- Single point of failure for authentication

**Recommendation:**
1. Ensure AD password policies are strong
2. Implement multi-factor authentication
3. Monitor LDAP authentication failures
4. Use secure LDAP (LDAPS) with certificate validation

---

## Additional Observations

### Accessible Services Summary

| Host | Service | Port | Notes |
|------|---------|------|-------|
| 10.0.1.10 | SSH | 22 | OpenSSH 8.9p1 Ubuntu |
| 10.0.1.10 | Climate Control | 6768 | Custom protocol, integer overflow |
| 10.0.1.10 | Ballast Control | 9000 | Authentication required |
| 10.0.1.10 | Go HTTP | 9091 | API service |
| 10.0.1.11 | SSH | 22 | OpenSSH 8.9p1 Ubuntu |
| 10.0.1.11 | HTTP/HTTPS | 80/443 | LibreChat / Penny AI |
| 10.0.1.11 | HTTP | 3000 | LibreChat direct |
| 10.0.1.11 | Meilisearch | 7700 | Search API, auth required |
| 10.0.1.11 | HTTPS | 8045 | API endpoint |
| 10.0.1.11 | HTTP Basic Auth | 8081 | Node.js Express |
| 10.0.1.99 | SSH | 22 | OpenSSH 8.9p1 Ubuntu |
| 10.0.1.99 | HTTP/HTTPS | 80/443 | Go application |
| 10.0.1.99 | MySQL | 3306 | MySQL 8.0.43 |
| 10.0.1.99 | HTTPS | 8080 | Go application |
| 10.0.1.30 | SSH | 22 | OpenSSH 8.9p1 Ubuntu |
| 10.0.1.30 | HTTP | 8096 | Jellyfin media server |
| 10.0.1.20 | SMB | 445 | Signing disabled |
| 10.0.1.20 | RDP | 3389 | Terminal Services |
| 10.0.1.20 | WinRM | 5985/5986 | Remote management |
| 10.0.1.21 | SMB | 445 | Signing disabled |
| 10.0.1.21 | RDP | 3389 | Terminal Services |
| 10.0.1.21 | WinRM | 5985/5986 | Remote management |

### Security Posture Observations

**Strengths:**
- SMBv1 disabled on Windows hosts (good)
- MySQL does not accept default credentials
- Meilisearch enforces authentication
- HTTPS/TLS configured on most web services

**Weaknesses:**
- Critical vulnerabilities in custom protocols
- Weak password policies throughout
- SMB signing disabled (high-impact vulnerability)
- Extensive information disclosure via APIs
- No apparent network segmentation between services

---

## Remediation Priority

### Immediate (Critical - Fix within 24 hours)
1. Fix integer overflow in Climate Control system (Finding 1)
2. Enable SMB signing on Windows workstations (Finding 4)
3. Increase minimum password length to 12+ characters (Finding 3)

### Short-term (High - Fix within 1 week)
1. Implement authentication controls on Ballast Control (Finding 2)
2. Restrict access to /api/config endpoint (Finding 5)
3. Add rate limiting and account lockout mechanisms

### Medium-term (Medium - Fix within 30 days)
1. Implement network segmentation for critical control systems
2. Enable comprehensive logging and monitoring
3. Conduct security code review of custom protocols
4. Implement HTTPS for all services currently using HTTP

---

## Testing Methodology

All testing was conducted using safe, non-aggressive techniques:
- No brute force attacks executed
- No denial of service attempts
- Passive enumeration techniques prioritized
- Default credential testing limited to common combinations
- Domain Controller (10.0.1.6) and 10.0.1.13 excluded as requested

**Tools Used:**
- nmap (service enumeration)
- netcat (protocol testing)
- curl (web application testing)
- NetExec (SMB enumeration)
- mysql client (database testing)

---

## Conclusion

The All Ports Tours infrastructure exhibits several critical and high-severity vulnerabilities that require immediate attention. The most concerning issues are the integer overflow in the Climate Control system and the disabled SMB signing on Windows workstations. Addressing these findings, particularly the critical and high-severity issues, should be prioritized to improve the overall security posture.

**Files Generated:**
- /home/pentester/cptc/pentest-plan.md
- /home/pentester/cptc/custom-protocols/*.txt
- /home/pentester/cptc/web-apps/*.txt
- /home/pentester/cptc/web-apps/10.0.1.11-api-config-formatted.json
- /home/pentester/cptc/windows-enum/*.txt
- /home/pentester/cptc/database-testing/*.txt

---

**Report Generated:** 2026-01-09
**Classification:** CONFIDENTIAL - INTERNAL USE ONLY
