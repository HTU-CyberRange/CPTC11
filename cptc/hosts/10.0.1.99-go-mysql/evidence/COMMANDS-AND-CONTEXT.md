# Commands and Context - Go Applications Testing
## Target: 10.0.1.99 and 10.0.1.10:9091

**Date:** 2026-01-10
**Testing Framework:** Multi-Agent Parallel Testing
**Authorization:** Confirmed

---

## Testing Context

### Target Services
- **10.0.1.99:80** - HTTP (Golang net/http server)
- **10.0.1.99:443** - HTTPS (Golang net/http server) - EXPIRED CERT
- **10.0.1.99:3306** - MySQL 8.0.43
- **10.0.1.99:8080** - HTTPS (Golang net/http server) - EXPIRED CERT
- **10.0.1.10:9091** - HTTP (Golang net/http server)

### Testing Objectives
- Discover exposed debug endpoints
- Test authentication mechanisms
- Enumerate API endpoints
- Test MySQL credentials
- Analyze SSL/TLS configuration

---

## Web Application Testing Commands

### Go pprof Debug Endpoint Testing

**Context:** Go applications often expose pprof profiling endpoints that can leak sensitive information.

**Port 80 Testing:**
```bash
# Test pprof index
curl -i http://10.0.1.99/debug/pprof/

# Test heap profile
curl -i http://10.0.1.99/debug/pprof/heap

# Test goroutines
curl -i http://10.0.1.99/debug/pprof/goroutine

# Test command line
curl -i http://10.0.1.99/debug/pprof/cmdline

# Test symbols
curl -i http://10.0.1.99/debug/pprof/symbol
```

**Port 443 Testing (HTTPS with expired cert):**
```bash
# Test pprof index (ignore cert errors)
curl -k -i https://10.0.1.99/debug/pprof/

# Test heap profile
curl -k -i https://10.0.1.99/debug/pprof/heap

# Test goroutines
curl -k -i https://10.0.1.99/debug/pprof/goroutine
```

**Port 8080 Testing (HTTPS with expired cert):**
```bash
# Test pprof index
curl -k -i https://10.0.1.99:8080/debug/pprof/

# Test heap profile
curl -k -i https://10.0.1.99:8080/debug/pprof/heap
```

**Port 9091 Testing (10.0.1.10):**
```bash
# Test pprof index
curl -i http://10.0.1.10:9091/debug/pprof/

# Test metrics endpoint (common in Go apps)
curl -i http://10.0.1.10:9091/metrics

# Test root
curl -i http://10.0.1.10:9091/
```

**Result:** Port 9091 returned metrics data (9518 bytes). Other ports returned 404.

---

### Common Endpoint Enumeration

**Port 80:**
```bash
# Test common paths
curl -i http://10.0.1.99/
curl -i http://10.0.1.99/api/
curl -i http://10.0.1.99/api/v1/
curl -i http://10.0.1.99/admin/
curl -i http://10.0.1.99/login
curl -i http://10.0.1.99/health
curl -i http://10.0.1.99/healthz
curl -i http://10.0.1.99/ready
curl -i http://10.0.1.99/metrics
curl -i http://10.0.1.99/status
```

**Port 443:**
```bash
# Test common HTTPS paths
curl -k -i https://10.0.1.99/
curl -k -i https://10.0.1.99/api/
curl -k -i https://10.0.1.99/api/v1/
curl -k -i https://10.0.1.99/swagger/
curl -k -i https://10.0.1.99/docs/
```

---

### Authentication Testing

**Authorization Header Tests:**
```bash
# Test with admin token
curl -i -H "Authorization: Bearer admin" http://10.0.1.99/api/

# Test with API key header
curl -i -H "X-API-Key: test123" http://10.0.1.99/api/

# Test X-Admin header
curl -i -H "X-Admin: true" http://10.0.1.99/admin/

# Test IP spoofing
curl -i -H "X-Forwarded-For: 127.0.0.1" http://10.0.1.99/admin/
curl -i -H "X-Real-IP: 127.0.0.1" http://10.0.1.99/admin/
```

---

### HTTP Method Testing

```bash
# Test various HTTP methods
curl -i -X GET http://10.0.1.99/api/
curl -i -X POST http://10.0.1.99/api/
curl -i -X PUT http://10.0.1.99/api/
curl -i -X DELETE http://10.0.1.99/api/
curl -i -X OPTIONS http://10.0.1.99/api/
curl -i -X HEAD http://10.0.1.99/api/
curl -i -X PATCH http://10.0.1.99/api/
curl -i -X TRACE http://10.0.1.99/api/
```

---

## Database Testing Commands

### MySQL Connection Testing

**Context:** Testing MySQL 8.0.43 on port 3306 for weak credentials.

**Basic Connection Test:**
```bash
# Test MySQL connectivity
nc -zv 10.0.1.99 3306

# Test MySQL banner
echo "SELECT VERSION();" | mysql -h 10.0.1.99 -u root -p
```

**Nmap MySQL Testing:**
```bash
# MySQL info script
nmap -p 3306 --script mysql-info 10.0.1.99

# MySQL brute force (limited attempts for safety)
nmap -p 3306 --script mysql-brute --script-args userdb=users.txt,passdb=pass.txt 10.0.1.99

# MySQL empty password
nmap -p 3306 --script mysql-empty-password 10.0.1.99

# MySQL enum (if accessible)
nmap -p 3306 --script mysql-enum 10.0.1.99
```

**Credential Testing (sample):**
```bash
# Test root with common passwords
mysql -h 10.0.1.99 -u root -p'root'
mysql -h 10.0.1.99 -u root -p'password'
mysql -h 10.0.1.99 -u root -p'toor'
mysql -h 10.0.1.99 -u root -p''
mysql -h 10.0.1.99 -u root -p'mysql'
mysql -h 10.0.1.99 -u root -p'admin'

# Test admin user
mysql -h 10.0.1.99 -u admin -p'admin'
mysql -h 10.0.1.99 -u admin -p'password'

# Test webapp user
mysql -h 10.0.1.99 -u webapp -p'webapp'
mysql -h 10.0.1.99 -u webapp -p'password'

# Test anonymous access
mysql -h 10.0.1.99
```

**Result:** All credential attempts failed. Database properly secured.

---

## Network/SSL Testing Commands

### Certificate Analysis

**Context:** Certificates on ports 443 and 8080 are expired (valid Aug-Nov 2025).

**OpenSSL Certificate Check:**
```bash
# Check certificate on port 443
openssl s_client -connect 10.0.1.99:443 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -text

# Check certificate dates
openssl s_client -connect 10.0.1.99:443 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -dates

# Check certificate on port 8080
openssl s_client -connect 10.0.1.99:8080 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -text

# Check certificate subject
openssl s_client -connect 10.0.1.99:443 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -subject -issuer
```

**Certificate Details Extracted:**
```
Subject: CN=*.allports.tours
Issuer: (Certificate Authority)
Valid From: Aug 17, 2025 14:27:45 GMT
Valid To: Nov 15, 2025 14:27:44 GMT
Status: EXPIRED
```

**SSL/TLS Configuration Testing:**
```bash
# Test SSL protocols
nmap --script ssl-enum-ciphers -p 443,8080 10.0.1.99

# Test for SSL vulnerabilities
nmap --script ssl-* -p 443,8080 10.0.1.99

# Using testssl.sh (if available)
testssl.sh https://10.0.1.99:443
testssl.sh https://10.0.1.99:8080
```

---

## API Testing Commands

### API Documentation Discovery

```bash
# Swagger/OpenAPI paths
curl -i http://10.0.1.99/swagger.json
curl -i http://10.0.1.99/swagger.yaml
curl -i http://10.0.1.99/openapi.json
curl -i http://10.0.1.99/api-docs
curl -i http://10.0.1.99/api/swagger
curl -i http://10.0.1.99/swagger-ui/
curl -i http://10.0.1.99/docs/
curl -i http://10.0.1.99/v1/docs
curl -i http://10.0.1.99/api/v1/docs

# GraphQL endpoint
curl -i http://10.0.1.99/graphql
curl -i -X POST -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}' \
  http://10.0.1.99/graphql
```

### REST API Enumeration

```bash
# Common REST endpoints
curl -i http://10.0.1.99/api/users
curl -i http://10.0.1.99/api/v1/users
curl -i http://10.0.1.99/api/auth
curl -i http://10.0.1.99/api/login
curl -i http://10.0.1.99/api/config
curl -i http://10.0.1.99/api/settings
curl -i http://10.0.1.99/api/status
curl -i http://10.0.1.99/api/health
```

### CORS Testing

```bash
# Test CORS headers
curl -i -H "Origin: https://evil.com" http://10.0.1.99/api/

# Test CORS with credentials
curl -i -H "Origin: https://evil.com" \
  -H "Access-Control-Request-Method: POST" \
  -X OPTIONS http://10.0.1.99/api/
```

---

## Findings Summary with Commands

### Finding 1: Go Metrics Endpoint Exposed

**Severity:** MEDIUM
**Location:** 10.0.1.10:9091/metrics

**Discovery Command:**
```bash
curl -i http://10.0.1.10:9091/metrics
```

**Result:** 9518 bytes of metrics data returned
**Evidence:** `/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence/web-security/10-9091-metrics.txt`

**Impact:** Exposes application metrics and internal statistics

---

### Finding 2: Expired SSL Certificates

**Severity:** HIGH
**Location:** 10.0.1.99:443, 10.0.1.99:8080

**Discovery Command:**
```bash
openssl s_client -connect 10.0.1.99:443 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -dates
```

**Result:**
```
notBefore=Aug 17 14:27:45 2025 GMT
notAfter=Nov 15 14:27:44 2025 GMT
```

**Current Date:** Jan 10, 2026
**Status:** Certificate expired ~2 months ago

**Evidence:** `/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence/network-security/`

---

### Finding 3: MySQL - No Weak Credentials

**Severity:** N/A (Positive Finding)
**Location:** 10.0.1.99:3306

**Testing Commands (sample of 1200+ attempts):**
```bash
mysql -h 10.0.1.99 -u root -p'root'
mysql -h 10.0.1.99 -u root -p'password'
mysql -h 10.0.1.99 -u admin -p'admin'
mysql -h 10.0.1.99 -u webapp -p'webapp'
# ... 1200+ combinations tested
```

**Result:** All authentication attempts failed
**Status:** Database properly secured with strong credentials

**Evidence:** `/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence/database-security/`

---

### Finding 4: pprof Endpoints Not Accessible

**Severity:** N/A (Secure Configuration)
**Locations:** Tested on all ports

**Testing Commands:**
```bash
curl -i http://10.0.1.99/debug/pprof/
curl -k -i https://10.0.1.99/debug/pprof/
curl -k -i https://10.0.1.99:8080/debug/pprof/
curl -i http://10.0.1.10:9091/debug/pprof/
```

**Result:** 404 Not Found on all tested endpoints
**Status:** Debug endpoints properly disabled or protected

---

## Reproduction Steps for Report

### To Verify Metrics Endpoint:
```bash
curl http://10.0.1.10:9091/metrics
```

### To Verify Expired Certificates:
```bash
echo | openssl s_client -connect 10.0.1.99:443 2>/dev/null | openssl x509 -noout -dates
echo | openssl s_client -connect 10.0.1.99:8080 2>/dev/null | openssl x509 -noout -dates
```

### To Verify MySQL Security:
```bash
mysql -h 10.0.1.99 -u root -p'test123'
# Should fail with: ERROR 1045 (28000): Access denied
```

---

## Testing Timeline

1. **Web Security Agent:** Tested HTTP/HTTPS endpoints, pprof, auth bypass (2 minutes)
2. **Database Security Agent:** Tested 1200+ MySQL credentials (2 minutes)
3. **Network Security Agent:** Analyzed SSL/TLS certificates (1 minute)
4. **API Testing Agent:** Enumerated API endpoints, tested documentation (2 minutes)

**Total Execution Time:** ~7-8 minutes (parallel execution)
**Evidence Files Generated:** 50+ files across 4 agent directories

---

**Report prepared for:** Final penetration test documentation
**Context:** All commands documented for reproduction and validation
**Evidence Location:** `/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence/`
