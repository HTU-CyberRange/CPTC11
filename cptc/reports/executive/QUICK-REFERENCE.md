# Quick Reference - Vulnerability Remediation Guide
## All Ports Tours Pentest Findings

---

## CRITICAL Priority (Fix Immediately)

### ❌ FINDING 1: Climate Control Integer Overflow
**Target:** 10.0.1.10:6768
**Quick Fix:**
```python
# Add validation to SET command handler
def set_temperature(value):
    if not (-50 <= value <= 50):
        return "Error: Temperature must be between -50 and 50 °C"
    # Continue with validated value
```

**Testing:**
```bash
echo -e "STATUS\nEXIT" | nc 10.0.1.10 6768
```

---

## HIGH Priority (Fix This Week)

### ❌ FINDING 2: Weak Password Policy
**Target:** 10.0.1.11 (LibreChat)
**Quick Fix:**
Update LibreChat configuration:
```json
{
    "minPasswordLength": 12
}
```

**Location:** LibreChat config file (likely `.env` or `librechat.yaml`)

---

### ❌ FINDING 3: SMB Signing Disabled
**Targets:** 10.0.1.20, 10.0.1.21
**Quick Fix via Group Policy:**
```
1. Open Group Policy Management Console
2. Navigate to: Computer Configuration > Policies > Windows Settings >
   Security Settings > Local Policies > Security Options
3. Enable: "Microsoft network server: Digitally sign communications (always)"
4. Enable: "Microsoft network client: Digitally sign communications (always)"
5. Run: gpupdate /force
```

**Quick Fix via PowerShell:**
```powershell
# On each workstation
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
Set-SmbClientConfiguration -RequireSecuritySignature $true -Force
```

**Verification:**
```bash
nxc smb 10.0.1.20 10.0.1.21
# Should show: (signing:True)
```

---

### ❌ FINDING 4: Ballast Control Authentication
**Target:** 10.0.1.10:9000
**Quick Fix:**
```python
# Add account lockout mechanism
failed_attempts = {}

def login(username, password):
    if failed_attempts.get(username, 0) >= 5:
        return "Account locked. Contact administrator."

    if not authenticate(username, password):
        failed_attempts[username] = failed_attempts.get(username, 0) + 1
        return "Invalid credentials."

    failed_attempts[username] = 0
    return "Login successful"
```

---

## MEDIUM Priority (Review This Month)

### ⚠️ FINDING 5: API Information Disclosure
**Target:** 10.0.1.11/api/config
**Quick Fix:**
```nginx
# Add to nginx config
location /api/config {
    auth_request /auth;
    proxy_pass http://backend;
}

location = /auth {
    internal;
    proxy_pass http://auth-service/verify;
}
```

---

### ⚠️ FINDING 6: Meilisearch Exposure
**Target:** 10.0.1.11:7700
**Quick Fix:**
```bash
# Update firewall rules
sudo ufw deny 7700/tcp
sudo ufw allow from 10.0.1.0/24 to any port 7700
```

**Or in nginx:**
```nginx
location /search {
    allow 10.0.1.0/24;
    deny all;
    proxy_pass http://127.0.0.1:7700;
}
```

---

### ⚠️ FINDING 7: HTTP Basic Auth Over Unencrypted Connection
**Target:** 10.0.1.11:8081
**Quick Fix:**
```nginx
# Redirect HTTP to HTTPS
server {
    listen 8081;
    return 301 https://$host$request_uri;
}

server {
    listen 8443 ssl;
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:8081;
    }
}
```

---

## Testing Commands Cheat Sheet

### Climate Control Testing
```bash
# Check status
echo -e "STATUS\nEXIT" | nc 10.0.1.10 6768

# Test SET command
echo -e "SET 72\nEXIT" | nc 10.0.1.10 6768
```

### Ballast Control Testing
```bash
# Test authentication
echo "LOGIN admin password" | nc 10.0.1.10 9000
```

### Web Application Testing
```bash
# Check API config
curl -s http://10.0.1.11/api/config | jq .

# Test Meilisearch
curl -s http://10.0.1.11:7700/version
```

### Windows SMB Testing
```bash
# Check SMB signing status
nxc smb 10.0.1.20 10.0.1.21

# Test null session
smbclient -L //10.0.1.20 -N
```

### MySQL Testing
```bash
# Test connection
mysql -h 10.0.1.99 -u root -p

# Check version
nmap -p 3306 --script mysql-info 10.0.1.99
```

---

## Evidence Files

| Finding | Evidence Location |
|---------|-------------------|
| Climate Overflow | /home/pentester/cptc/custom-protocols/climate-control-status.txt |
| Ballast Auth | /home/pentester/cptc/custom-protocols/ballast-control-prompt.txt |
| Weak Password | /home/pentester/cptc/web-apps/10.0.1.11-api-config-formatted.json |
| SMB Signing | /home/pentester/cptc/windows-enum/nxc-smb-scan.txt |
| API Disclosure | /home/pentester/cptc/web-apps/10.0.1.11-api-config.txt |

---

## Verification Checklist

After remediation, verify fixes with these tests:

- [ ] Climate Control: STATUS command returns valid temperature (-50 to 50°C)
- [ ] Climate Control: SET command rejects out-of-range values
- [ ] LibreChat: Cannot create password less than 12 characters
- [ ] SMB: nxc shows "signing:True" for both workstations
- [ ] Ballast: Account locks after 5 failed login attempts
- [ ] API: /api/config returns 401 without authentication
- [ ] Meilisearch: Port 7700 blocked from external networks
- [ ] 8081: HTTP redirects to HTTPS

---

## Emergency Contacts

**Security Team:** [Contact Info]
**Network Team:** [Contact Info]
**Maritime Systems Team:** [Contact Info]
**Management:** [Contact Info]

---

**Last Updated:** 2026-01-09
