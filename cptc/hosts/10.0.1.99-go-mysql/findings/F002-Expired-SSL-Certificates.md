# Expired SSL/TLS Certificates

## Summary
The HTTPS services on ports 443 and 8080 are using expired SSL certificates that expired on November 15, 2025 (nearly 2 months ago). While connections still function due to clients accepting invalid certificates, this creates trust issues and exposes users to man-in-the-middle attacks as browsers display security warnings that train users to ignore certificate errors.

## Title
Expired SSL/TLS Certificates

## CVSS
CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:A/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N
**Score: 6.3 (Medium)**

## Short Recommendation
Renew SSL certificates immediately using Let's Encrypt or appropriate CA. Implement automated certificate renewal to prevent future expirations.

## Affected Components
- **Address**: 10.0.1.99 (*.allports.tours)
- **Ports**: 443 (HTTPS), 8080 (HTTPS)
- **Component**: TLS/SSL certificates
- **Certificate Authority**: Let's Encrypt (E5)
- **Certificate Type**: Wildcard (*.allports.tours)

## Technical Description
Both HTTPS endpoints (ports 443 and 8080) use identical wildcard SSL certificates issued by Let's Encrypt that expired on November 15, 2025. Current date is January 10, 2026, meaning the certificates have been expired for approximately 56 days (nearly 2 months).

**Certificate Details:**
- **Subject**: CN=*.allports.tours
- **Issuer**: C=US, O=Let's Encrypt, CN=E5
- **Valid From**: Aug 17 14:27:45 2025 GMT
- **Valid To**: Nov 15 14:27:44 2025 GMT
- **Status**: EXPIRED (56 days past expiration)
- **Serial**: 05:8d:62:a9:13:68:c8:c6:e9:fd:9f:b6:7b:ac:bf:ab:92:6e
- **Public Key**: ECDSA P-256 (256-bit)
- **Signature**: ecdsa-with-SHA384

**Impact of Expired Certificates:**

1. **Browser Warnings**: Users see security warnings (NET::ERR_CERT_DATE_INVALID)
2. **Trust Erosion**: Users trained to bypass security warnings
3. **MITM Vulnerability**: Easier to social engineer users into accepting malicious certificates
4. **API Client Failures**: Automated clients may reject connections entirely
5. **Compliance Violations**: PCI DSS, HIPAA, SOC 2 require valid certificates
6. **Reputation Damage**: Security-conscious users lose trust in organization

The certificates use Let's Encrypt which provides free 90-day certificates with automated renewal support, making this expiration particularly concerning as it suggests:
- Lack of automated certificate management
- No monitoring/alerting for certificate expiration
- Possible abandonment of certificate renewal processes
- Inadequate operational procedures

## Evidence

**Certificate Expiration Check:**
```bash
openssl s_client -connect 10.0.1.99:443 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -dates
```

**Results:**
```
notBefore=Aug 17 14:27:45 2025 GMT
notAfter=Nov 15 14:27:44 2025 GMT
```

**Current Date:** Jan 10, 2026
**Days Expired:** 56 days

**Full Certificate Details:**
```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 05:8d:62:a9:13:68:c8:c6:e9:fd:9f:b6:7b:ac:bf:ab:92:6e
        Signature Algorithm: ecdsa-with-SHA384
        Issuer: C=US, O=Let's Encrypt, CN=E5
        Validity
            Not Before: Aug 17 14:27:45 2025 GMT
            Not After : Nov 15 14:27:44 2025 GMT
        Subject: CN=*.allports.tours
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
        X509v3 extensions:
            X509v3 Subject Alternative Name:
                DNS:*.allports.tours
```

**Browser Error Example:**
```
NET::ERR_CERT_DATE_INVALID
Subject: *.allports.tours
Issuer: Let's Encrypt Authority E5
Expired on: Nov 15, 2025
Current date: Jan 10, 2026
```

## Proof of Concept Commands

**Check Certificate Expiration (Port 443):**
```bash
echo | openssl s_client -connect 10.0.1.99:443 2>/dev/null | openssl x509 -noout -dates
```

**Expected Result:**
```
notAfter=Nov 15 14:27:44 2025 GMT
```

**Check Certificate Expiration (Port 8080):**
```bash
echo | openssl s_client -connect 10.0.1.99:8080 2>/dev/null | openssl x509 -noout -dates
```

**Expected Result:** Same expiration date (Nov 15, 2025)

**Verify Certificate Subject:**
```bash
echo | openssl s_client -connect 10.0.1.99:443 2>/dev/null | openssl x509 -noout -subject -issuer
```

**Expected Result:**
```
subject=CN=*.allports.tours
issuer=C=US, O=Let's Encrypt, CN=E5
```

**Check Days Until/Past Expiration:**
```bash
echo | openssl s_client -connect 10.0.1.99:443 2>/dev/null | openssl x509 -noout -checkend 0
```

**Expected Result:** `Certificate will expire` or `Certificate has expired`

## Recommendation

**Immediate (Within 4 Hours):**
- Renew certificates using Let's Encrypt or existing CA:
  ```bash
  # Using certbot (Let's Encrypt)
  certbot renew --force-renewal

  # For wildcard cert
  certbot certonly --manual --preferred-challenges dns \
    -d *.allports.tours --force-renewal
  ```
- Deploy new certificates to servers:
  ```bash
  # Restart web services after cert deployment
  systemctl reload nginx  # or appropriate service
  ```
- Verify renewal:
  ```bash
  echo | openssl s_client -connect 10.0.1.99:443 2>/dev/null | \
    openssl x509 -noout -dates
  ```

**Urgent (Within 24 Hours):**
- Implement automated certificate renewal:
  ```bash
  # Add certbot renewal cron job
  0 0,12 * * * certbot renew --quiet --deploy-hook "systemctl reload nginx"
  ```
- Set up monitoring for certificate expiration:
  ```bash
  # Monitor via Prometheus/Nagios/Zabbix
  # Alert when < 30 days remaining
  ```
- Document certificate renewal procedures
- Identify why automated renewal failed
- Check Let's Encrypt rate limits if renewal fails

**Short-term (Within 1 Week):**
- Implement certificate monitoring dashboard
- Set up alerts at 30, 14, and 7 days before expiration
- Email notifications to security/ops team
- Slack/PagerDuty integration for critical alerts
- Test renewal process in staging environment
- Document runbook for emergency certificate replacement
- Audit all other certificates in infrastructure

**Long-term:**
- Migrate to automated certificate management solution:
  - cert-manager (Kubernetes)
  - AWS Certificate Manager
  - Azure Key Vault
  - HashiCorp Vault with PKI
- Implement certificate lifecycle management policy
- Regular certificate inventory audits (quarterly)
- Certificate pinning for mobile apps/critical APIs
- Consider longer-duration certificates (if compliance allows)
- Automated testing of certificate renewal process

## References
- OWASP Top 10 2021: A02:2021 - Cryptographic Failures
- OWASP Top 10 2021: A05:2021 - Security Misconfiguration
- CWE-295: Improper Certificate Validation
- CWE-298: Improper Validation of Certificate Expiration
- RFC 5280: X.509 Certificate and CRL Profile
- Let's Encrypt: https://letsencrypt.org/docs/
- PCI DSS Requirement 4.1: Use strong cryptography and security protocols
- NIST SP 800-52 Rev. 2: Guidelines for TLS Implementations

## Re-test Status
Not yet retested

## Re-test Notes
Retesting should verify:
1. Certificate expiration date is in the future (> 30 days)
2. Both ports 443 and 8080 use valid, non-expired certificates
3. Certificate chain is complete and trusted
4. Browser shows padlock without warnings
5. Automated renewal is configured and tested

**Test Commands:**
```bash
# Check expiration
echo | openssl s_client -connect 10.0.1.99:443 2>/dev/null | \
  openssl x509 -noout -dates

# Check if expires in 30+ days
echo | openssl s_client -connect 10.0.1.99:443 2>/dev/null | \
  openssl x509 -noout -checkend 2592000
```

**Expected After Fix:**
- `notAfter` date is > 30 days in the future
- `checkend` returns: `Certificate will not expire`
- Browser shows valid HTTPS with no warnings

**Verify Automated Renewal:**
```bash
# Check certbot timer status
systemctl status certbot.timer

# Test renewal dry-run
certbot renew --dry-run
```

## Impact

**Confidentiality (HIGH - Conditional):** Expired certificates enable MITM attacks:
- **User trust erosion**: Security warnings train users to bypass certificate checks
- **MITM vulnerability**: Attackers can present their own certificates, users may accept
- **Session hijacking**: Intercepted HTTPS traffic can expose session tokens
- **Credential theft**: Login forms over "insecure HTTPS" can be intercepted
- **Data exfiltration**: All HTTPS traffic potentially interceptable

**Integrity (HIGH - Conditional):** Man-in-the-middle attacks enable content manipulation:
- Attackers can modify responses (inject malware, change data)
- JavaScript injection into pages
- Malicious redirects
- Form data tampering

**Availability (LOW):**
- Some API clients refuse expired certificates (service disruption)
- Automated systems may fail health checks
- Monitoring tools may report service down

**Compliance Impact:**
- **PCI DSS**: Requirement 4.1 mandates strong cryptography with valid certificates
  - Non-compliance = loss of payment processing privileges
  - Fines: $5,000-$100,000 per month
- **HIPAA**: Technical safeguards require valid encryption (§164.312(e)(1))
  - Violations: $100-$50,000 per incident
- **SOC 2**: Trust Services Criteria CC6.7 (encryption in transit)
  - Failed audits, loss of customer trust
- **GDPR**: Article 32 requires appropriate technical measures
  - Potential fines up to €20M or 4% annual revenue

**Business Impact:**
- **Customer trust loss**: Security warnings visible to all users
- **Brand reputation**: "Not Secure" in browser damages credibility
- **Conversion rate drop**: Users abandon checkout on security warnings
- **Support costs**: Customer inquiries about security warnings
- **SEO penalties**: Google ranks sites with SSL issues lower
- **Partner concerns**: B2B partners may suspend integration

**Attack Scenarios:**

**Scenario 1: Man-in-the-Middle Attack**
1. User connects to https://10.0.1.99 (or *.allports.tours subdomain)
2. Browser shows "NET::ERR_CERT_DATE_INVALID" warning
3. User clicks "Proceed Anyway" (trained behavior after seeing warning repeatedly)
4. Attacker on network intercepts connection
5. Presents own certificate (user already bypassing warnings)
6. User accepts attacker certificate
7. Attacker intercepts all HTTPS traffic (credentials, session tokens, PII)

**Scenario 2: Phishing Campaign**
1. Attackers create phishing site mimicking allports.tours
2. Use expired certificates (matches legitimate site behavior)
3. Users see same security warning as legitimate site
4. Users can't distinguish legitimate from malicious
5. Enter credentials on phishing site
6. Account compromise across platform

**Scenario 3: API Client Failures**
1. Mobile app or partner API client connects to API endpoint
2. SSL library checks certificate validity
3. Detects expiration, refuses connection
4. API calls fail, service disrupted
5. Business transactions fail
6. Customer complaints, revenue loss

**Scenario 4: Compliance Audit Failure**
1. Annual PCI DSS or SOC 2 audit conducted
2. Auditor discovers expired certificates (automatic test)
3. Critical finding in audit report
4. Failed audit = loss of certification
5. Payment processors suspend service
6. Cannot process credit cards until remediated

**Likelihood:** CRITICAL - Certificate expiration is objectively verifiable and already occurred. 100% of users connecting via HTTPS see security warnings. Attack success depends on user behavior, but warning fatigue makes exploitation likely.

**Technical Notes:**
The 56-day expiration period is particularly concerning for Let's Encrypt certificates which:
- Expire after 90 days (industry standard)
- Provide free automated renewal tools (certbot, acme.sh)
- Send expiration warning emails at 20, 10, and 1 days before expiration
- Support automated renewal via cron jobs/systemd timers

The fact that certificates expired despite these safeguards suggests systematic operational failures rather than simple oversight. This increases the severity as it indicates broader security hygiene issues.

**Comparison to Active Exploitation:**
While not as immediately severe as the LibreChat RCE (F001 - CVSS 9.8), expired certificates create conditions for high-impact attacks. The CVSS score of 6.3 reflects the conditional nature (requires MITM position + user accepts certificate) but real-world impact is often underestimated. Organizations like Google, Microsoft, and financial institutions treat certificate expirations as P0/critical incidents requiring immediate response.
