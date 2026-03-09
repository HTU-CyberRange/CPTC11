# 10.0.1.99 - Go Applications + MySQL

## Host Overview

**IP Address:** 10.0.1.99
**Hostname:** go-mysql (inferred)
**OS:** Linux
**Status:** Under Investigation
**Testing Status:** Enumeration Complete - Exploitation Phase

---

## Services Discovered

### Go Web Applications - Ports 80/443/8080
- **Protocol:** HTTP/HTTPS
- **Status:** Under Investigation
- **Description:** Multiple Go-based web applications

### MySQL Database - Port 3306
- **Protocol:** MySQL
- **Version:** MySQL 8.0.43
- **Status:** Enumerated - Testing in progress
- **Description:** MySQL database server

---

## Services Detail

### HTTP (Port 80)
- Go web application
- Standard HTTP responses
- Multiple endpoints discovered

### HTTPS (Port 443)
- Go web application with TLS
- Similar endpoints to port 80
- Certificate information available

### HTTPS (Port 8080)
- Additional Go application instance
- May be development/staging environment
- Different endpoint structure

### MySQL (Port 3306)
- MySQL 8.0.43
- Tested for default credentials (negative)
- Anonymous access tested (negative)
- Standard configuration detected

---

## Directory Contents

### `/enumeration/`
Contains all enumeration data for this host:

#### Web Application Data
- `10.0.1.99-80-root.txt` - HTTP port 80 root response
- `10.0.1.99-443-root.txt` - HTTPS port 443 root response
- `10.0.1.99-8080-root.txt` - HTTPS port 8080 root response
- `10.0.1.99-robots.txt` - Robots.txt file
- `10.0.1.99-endpoint-admin.txt` - Admin endpoint response
- `10.0.1.99-endpoint-api.txt` - API endpoint response
- `10.0.1.99-endpoint-debug.txt` - Debug endpoint response
- `10.0.1.99-endpoint-health.txt` - Health check endpoint
- `10.0.1.99-endpoint-metrics.txt` - Metrics endpoint response
- `10.0.1.99-endpoint-status.txt` - Status endpoint response

#### Database Enumeration Data
- `10.0.1.99-mysql-nmap.txt` - Nmap MySQL script results
- `10.0.1.99-mysql-creds-test.txt` - Credential testing results
- `10.0.1.99-mysql-anon-root.txt` - Anonymous access testing

### `/findings/`
Contains validated findings specific to this host (currently being populated)

### `/evidence/`
Contains proof-of-concept code and exploitation evidence

### `/scripts/`
Contains testing scripts specific to this host:
- `enum-target-99.sh` - General enumeration for this host
- `enum-mysql.sh` - MySQL-specific enumeration
- `enum-web-apps.sh` - Web application enumeration

---

## Testing Notes

### Go Web Applications
- Multiple instances running on different ports
- Standard Go HTTP server responses
- Various endpoints discovered:
  - `/admin` - Administrative interface
  - `/api` - API endpoints
  - `/debug` - Debug information (potential info leak)
  - `/health` - Health check
  - `/metrics` - Application metrics (potential info leak)
  - `/status` - Status information

### Endpoint Analysis
- **Debug endpoint:** May expose sensitive debugging information
- **Metrics endpoint:** May leak system and application statistics
- **Admin endpoint:** Requires authentication analysis
- **API endpoint:** Needs further enumeration

### MySQL Database
- Version: 8.0.43 (recent, likely patched)
- Default credentials: Not found
- Anonymous access: Disabled
- Authentication required for access
- Connection encryption available

### Potential Vectors
1. Information disclosure via debug/metrics endpoints
2. Authentication bypass on admin interfaces
3. API security issues
4. SQL injection in web applications
5. Database credential discovery

---

## Current Testing Status

### Completed
- Port scanning and service identification
- Web application endpoint enumeration
- MySQL version detection and basic testing
- Initial credential testing (negative results)

### In Progress
- Detailed API endpoint analysis
- Web application authentication testing
- Debug/metrics endpoint information gathering
- Database credential hunting in configs/files

### Pending
- SQL injection testing
- Authentication bypass attempts
- Authorization testing on discovered endpoints
- Session management testing
- Database access attempts with discovered credentials

---

## Priority Actions

1. **HIGH:** Analyze debug and metrics endpoints for information disclosure
2. **HIGH:** Test authentication on admin interfaces
3. **MEDIUM:** Comprehensive API endpoint testing
4. **MEDIUM:** Search for database credentials in application files
5. **LOW:** SQL injection testing on web forms/parameters

---

## Notes

- Host appears to be well-configured (no default credentials)
- Multiple application instances suggest development/staging setup
- MySQL access will require credential discovery
- Debug/metrics endpoints are primary targets for information gathering

---

## Related Documentation

- **Main Index:** `/INDEX.md`
- **Findings Report:** `/reports/technical/FINDINGS-REPORT.md`
- **Host Inventory:** `/reports/tracking/HOST-INVENTORY.md`

---

**Last Updated:** 2026-01-10
**Responsibility:** Our team
**Status:** Active enumeration and testing
