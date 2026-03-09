# Ballast Control System Exploitation Script

## Overview

This script performs comprehensive security testing against the Ballast Control System running on `10.0.1.10:9000`.

**Target Information:**
- Host: 10.0.1.10
- Port: 9000
- Protocol: TCP text-based
- Service: Ballast Control System
- Authentication: `LOGIN <username> <password>`

## Features

The script performs the following test phases:

1. **Basic Connection Testing** - Connect and retrieve banner
2. **Unauthenticated Commands** - Test commands without authentication
3. **SQL Injection** - Test SQL injection in login fields
4. **Command Injection** - Test OS command injection
5. **Authentication Bypass** - Test bypass techniques (null bytes, case variations, etc.)
6. **Credential Bruteforce** - Test common username/password combinations
7. **Protocol Fuzzing** - Test malformed inputs and special characters
8. **Buffer Overflow** - Test with incrementally larger payloads

## Usage

### Run All Tests

```bash
python3 /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/ballast-exploit.py --all
```

### Run Specific Test Phase

```bash
# Connection test only
python3 ballast-exploit.py --phase connection

# SQL injection testing
python3 ballast-exploit.py --phase sqli

# Credential brute force
python3 ballast-exploit.py --phase bruteforce

# Protocol fuzzing
python3 ballast-exploit.py --phase fuzzing
```

### Adjust Settings

```bash
# Faster testing (1 second delay)
python3 ballast-exploit.py --all --delay 1.0

# Longer timeout
python3 ballast-exploit.py --all --timeout 15

# Custom target
python3 ballast-exploit.py --host 10.0.1.10 --port 9000 --all
```

## Output and Evidence

All test results are saved to:
```
/home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/ballast-exploitation/
```

### Evidence Files Generated

1. **ballast-exploit-YYYYMMDD-HHMMSS.log** - Full execution log with all attempts
2. **01-banner.txt** - Initial banner and connection test
3. **02-unauthenticated-commands.txt** - Pre-auth command testing results
4. **03-sql-injection-tests.txt** - SQL injection attempt results
5. **04-command-injection-tests.txt** - Command injection results
6. **05-auth-bypass-tests.txt** - Authentication bypass attempts
7. **06-credential-bruteforce.txt** - Credential testing results
8. **07-protocol-fuzzing.txt** - Protocol fuzzing results
9. **08-buffer-overflow-tests.txt** - Buffer overflow testing results
10. **SUCCESS-username-password-TIMESTAMP.txt** - Full authenticated session transcript (if successful)
11. **SUCCESSFUL_CREDENTIALS.txt** - Summary of all successful logins

## Safety Features

- **Rate Limiting**: 2-second delay between attempts (configurable)
- **Timeout Handling**: 10-second socket timeout (configurable)
- **Error Recovery**: Graceful error handling with detailed logging
- **Connection Management**: Proper socket cleanup
- **Detailed Logging**: All actions logged to file and console

## Tested Credentials

The script tests the following common credentials:

```
admin/admin
admin/password
admin/123456
root/root
root/password
ballast/ballast
ballast/password
operator/operator
captain/captain
cruise/cruise
allports/allports
+ more variations
```

## SQL Injection Payloads

Includes testing for:
- Classic SQLi: `' OR '1'='1`
- Comment-based: `admin' --`, `admin' #`
- Union-based: `' UNION SELECT NULL --`
- Boolean-based: `' or 1=1 or ''='`

## Command Injection Payloads

Tests for command injection using:
- `;ls`, `; id`, `; whoami`
- `&& ls`, `|| ls`
- `$(ls)`, `` `ls` ``
- Newline/carriage return injection

## Example Session

```bash
$ python3 ballast-exploit.py --all

================================================================================
BALLAST CONTROL SYSTEM EXPLOITATION SCRIPT
Target: 10.0.1.10:9000
Evidence Directory: /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/ballast-exploitation
================================================================================

================================================================================
PHASE: Basic Connection
================================================================================
2026-01-10 14:30:00 - BallastExploiter - INFO - [+] Testing basic connection and banner...
2026-01-10 14:30:00 - BallastExploiter - INFO - Banner received:
Ballast Control System
Authentication Required (LOGIN <user> <pass>)
>

================================================================================
PHASE: Credential Bruteforce
================================================================================
2026-01-10 14:30:10 - BallastExploiter - INFO - [+] Testing common credentials...
2026-01-10 14:30:12 - BallastExploiter - INFO - [FAILED] admin:admin
2026-01-10 14:30:14 - BallastExploiter - INFO - [FAILED] admin:password
...

================================================================================
TESTING COMPLETE
================================================================================
[*] No successful authentication found.
[*] All evidence saved to: /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/ballast-exploitation
```

## Troubleshooting

### Connection Refused
```
Error: [Errno 111] Connection refused
```
- Verify target is up: `nc -zv 10.0.1.10 9000`
- Check firewall rules
- Confirm service is running

### Timeout Issues
```
Error: timed out
```
- Increase timeout: `--timeout 20`
- Check network connectivity
- Service may be slow or unresponsive

### Permission Denied (Evidence Directory)
```
Error: Permission denied
```
- Ensure write permissions to evidence directory
- Use custom directory: `--evidence-dir /tmp/ballast-test`

## Notes

- The script is designed to be safe and methodical
- Default 2-second delay prevents service overload
- All actions are logged for audit trail
- Successful credentials are clearly highlighted and saved
- Script can be interrupted with Ctrl+C safely

## Related Findings

- **F005-ballast-auth**: Initial reconnaissance showing authentication requirement
- Located at: `/home/pentester/cptc/findings/validated/F005-ballast-auth/`

## Script Location

```
/home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/ballast-exploit.py
```
