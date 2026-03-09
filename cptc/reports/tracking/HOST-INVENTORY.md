# Host Inventory - allports.local (10.0.1.0/24)

## In-Scope Hosts

### 10.0.1.10 - Custom Services Host
**OS:** Ubuntu Linux (OpenSSH 8.9p1)
**Hostname:** Unknown
**Services:**
- Port 22: SSH (OpenSSH 8.9p1)
- Port 6768: Custom "Lido Deck Climate Control System" - Interactive menu system
- Port 9000: Custom "Ballast Control System" - Requires authentication (LOGIN <user> <pass>)
- Port 9091: HTTP (Golang net/http server)

**Purpose:** Custom maritime control system applications
**Testing Status:** Initial enumeration completed, requires deeper testing
**Findings:** Integer overflow in climate control (F002), authentication issues in ballast control (F005)

---

### 10.0.1.11 - LibreChat/Penny AI Platform
**OS:** Ubuntu Linux
**Hostname:** Unknown
**DNS:** penny.allports.tours (resolves here or to 10.0.1.14)
**Services:**
- Port 22: SSH (OpenSSH 8.9p1)
- Port 80: HTTP (nginx 1.27.0) - LibreChat
- Port 443: HTTPS (nginx 1.27.0) - LibreChat with *.allports.tours cert
- Port 3000: HTTP (Node.js) - LibreChat backend
- Port 7700: HTTP (Meilisearch) - Search engine service
- Port 8045: HTTPS (nginx 1.27.0)
- Port 8081: HTTP (Node.js Express) - Requires Basic Auth

**Purpose:** AI chat application with Claude integration, MCP servers
**Authorized Access:** YES - Username: pentester, Password: )u1h55hm-h(M(7nV
**MCP Servers Available:** postgres (confirmed), filesystem, sqlite, docker (mentioned in config but not confirmed accessible)
**Database:** Postgres with 19 tables including user_account, staff_list, customer_details, order, etc.
**Testing Status:** Active testing in progress
**Findings:** Unauthorized database access via MCP (F001), weak password policy (F003)

---

### 10.0.1.14 - Reverse Proxy
**OS:** Ubuntu Linux (OpenSSH 8.9p1)
**Hostname:** Unknown
**DNS:** chat.allports.tours
**Services:**
- Port 22: SSH (OpenSSH 8.9p1)
- Port 80: HTTP (nginx 1.18.0) - Custom server header "CruissantServer"
- Port 443: HTTPS (nginx 1.18.0) - Redirects to https://chat.allports.tours/
- Port 5001: Closed (commplex-link)

**Purpose:** Reverse proxy for chat services, likely proxies to 10.0.1.11
**Testing Status:** Basic enumeration only
**Findings:** None yet

---

### 10.0.1.20 - Deckhand-01 (Windows Workstation)
**OS:** Windows Server 2022 Build 20348
**Hostname:** Deckhand-01.allports.local
**Domain:** APT (allports.local)
**Services:**
- Port 135: MSRPC
- Port 139: NetBIOS-SSN
- Port 445: SMB (microsoft-ds)
- Port 3389: RDP (Terminal Services)
- Port 5985: WinRM HTTP
- Port 5986: WinRM HTTPS
- Port 47001: HTTPAPI
- Ports 49664-49671, 49700-49701: MSRPC

**Purpose:** Domain-joined Windows workstation
**SMB Signing:** Enabled but NOT required
**Testing Status:** Basic SMB enumeration completed
**Findings:** SMB signing not required (F004), vulnerable to NTLM relay

---

### 10.0.1.21 - Deckhand-02 (Windows Workstation)
**OS:** Windows Server 2022 Build 20348
**Hostname:** Deckhand-02.allports.local
**Domain:** APT (allports.local)
**Services:**
- Port 135: MSRPC
- Port 139: NetBIOS-SSN
- Port 445: SMB (microsoft-ds)
- Port 3389: RDP (Terminal Services)
- Port 5985: WinRM HTTP
- Port 5986: WinRM HTTPS
- Port 47001: HTTPAPI
- Ports 49664-49671, 49701-49702: MSRPC

**Purpose:** Domain-joined Windows workstation
**SMB Signing:** Enabled but NOT required
**Testing Status:** Basic SMB enumeration completed
**Findings:** SMB signing not required (F004), vulnerable to NTLM relay

---

### 10.0.1.30 - Jellyfin Media Server
**OS:** Ubuntu Linux (OpenSSH 8.9p1)
**Hostname:** Unknown
**Services:**
- Port 22: SSH (OpenSSH 8.9p1)
- Port 8096: HTTP (Microsoft Kestrel httpd) - Jellyfin media server

**Purpose:** Self-hosted media streaming server
**Testing Status:** Basic enumeration completed
**Findings:** None yet, requires authentication testing

---

### 10.0.1.99 - Application Server
**OS:** Ubuntu Linux (OpenSSH 8.9p1)
**Hostname:** Unknown
**Services:**
- Port 22: SSH (OpenSSH 8.9p1)
- Port 80: HTTP (Golang net/http server)
- Port 443: HTTPS (Golang net/http server) - *.allports.tours cert (expired: issued Aug 2025, expired Nov 2025)
- Port 3306: MySQL 8.0.43
- Port 8080: HTTPS (Golang net/http server) - Expired cert

**Purpose:** Go application backend with MySQL database
**SSL Certificate:** EXPIRED (valid Aug 17 - Nov 15, 2025)
**Testing Status:** Basic enumeration, MySQL tested (no default creds)
**Findings:** Expired SSL certificate (potential finding)

---

### 10.0.1.1 - Network Infrastructure
**OS:** Linux 5.0-5.14 or MikroTik RouterOS 7.2-7.5
**Services:**
- Port 53: DNS (tcpwrapped)

**Purpose:** DNS server / network routing
**Testing Status:** Identified only
**Note:** Likely infrastructure, low priority for application testing

---

### 10.0.1.254 - Gateway
**OS:** Unknown
**Services:**
- Port 9697: Filtered (unknown)

**Purpose:** Network gateway (traceroute shows this as hop 1)
**Testing Status:** Identified only
**Note:** Infrastructure device, out of scope for application testing

---

## Excluded Hosts (DO NOT TEST)

### 10.0.1.6 - APT-DC-01 (Active Directory Domain Controller)
**OS:** Windows Server
**Hostname:** APT-DC-01.allports.local
**Domain:** allports.local
**Status:** EXCLUDED per client request
**Reason:** Active Directory infrastructure, critical system

---

### 10.0.1.13 - Multi-Service Host
**OS:** Ubuntu Linux (OpenSSH 8.9p1)
**Services:** MySQL 5.7.44, Apache httpd, nginx, Jetty, Keycloak
**Status:** EXCLUDED per client request

---

## Testing Priority

**High Priority:**
1. 10.0.1.11 - Active testing (authorized credentials, database access via MCP)
2. 10.0.1.10 - Custom control systems (potential critical findings)
3. 10.0.1.99 - Go applications and MySQL (expired cert, database access)

**Medium Priority:**
4. 10.0.1.20, 10.0.1.21 - Windows workstations (SMB relay testing)
5. 10.0.1.30 - Jellyfin (authentication testing)
6. 10.0.1.14 - Reverse proxy (configuration testing)

**Low Priority:**
7. 10.0.1.1, 10.0.1.254 - Infrastructure (monitoring only)

---

## Summary Statistics

**Total Hosts:** 11
**In Scope:** 9
**Excluded:** 2
**Linux Hosts:** 6 in scope
**Windows Hosts:** 2 in scope
**Active Testing:** 1 (10.0.1.11)
**Pending Validation:** 5 findings across 4 hosts
