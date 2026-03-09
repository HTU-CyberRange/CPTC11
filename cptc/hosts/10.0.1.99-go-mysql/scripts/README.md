# Multi-Agent Penetration Testing Scripts

## Overview

This directory contains a coordinated multi-agent penetration testing framework designed to test Go applications and MySQL database services on host 10.0.1.99.

## Architecture

### Specialized Agents

1. **Web Application Security Agent** (`agent-web-security.sh`)
   - Tests HTTP/HTTPS endpoints on ports 80, 443, 8080, and 9091
   - Go framework vulnerability testing (pprof debug endpoints)
   - Authentication bypass attempts
   - Directory enumeration
   - HTTP method testing

2. **Database Security Agent** (`agent-database-security.sh`)
   - MySQL 8.0.43 credential testing
   - Version-specific vulnerability assessment
   - Configuration disclosure attempts
   - Database enumeration
   - Protocol analysis

3. **Network Security Agent** (`agent-network-security.sh`)
   - SSL/TLS certificate analysis
   - Expired certificate assessment
   - Cipher suite testing
   - Security headers analysis
   - Service fingerprinting

4. **API Testing Agent** (`agent-api-testing.sh`)
   - REST API endpoint discovery
   - GraphQL endpoint testing
   - API documentation discovery
   - Authentication mechanism testing
   - Rate limiting assessment
   - CORS policy testing

### Coordination Scripts

- **Master Coordinator** (`master-coordinator.sh`)
  - Orchestrates parallel agent execution
  - Monitors agent status
  - Coordinates evidence collection
  - Triggers report generation

- **Report Generator** (`generate-report.sh`)
  - Analyzes all agent results
  - Correlates findings
  - Creates comprehensive assessment report
  - Generates executive summary

### Utility Scripts

- **Launch Assessment** (`launch-assessment.sh`)
  - Main entry point
  - Runs pre-flight checks
  - Launches master coordinator

- **Pre-flight Check** (`preflight-check.sh`)
  - Validates environment
  - Checks dependencies
  - Verifies connectivity
  - Ensures directory structure

- **Progress Monitor** (`monitor-progress.sh`)
  - Real-time status display
  - Agent activity monitoring
  - Evidence file counting

## Quick Start

### Launch Complete Assessment

```bash
cd /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts
bash launch-assessment.sh
```

### Monitor Progress

In a separate terminal:

```bash
cd /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts
bash monitor-progress.sh
```

### View Results

After completion:

```bash
cat /home/pentester/cptc/hosts/10.0.1.99-go-mysql/GO-APPLICATIONS-ASSESSMENT.md
```

## Output Structure

### Evidence Directory

```
/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence/
├── web-security/           # Web app testing evidence
├── database-security/      # Database testing evidence
├── network-security/       # Network testing evidence
├── api-testing/           # API testing evidence
└── master-coordinator.log # Main coordination log
```

### Findings Directory

```
/home/pentester/cptc/hosts/10.0.1.99-go-mysql/findings/
└── (Validated security findings)
```

### Report

```
/home/pentester/cptc/hosts/10.0.1.99-go-mysql/GO-APPLICATIONS-ASSESSMENT.md
```

## Individual Agent Execution

To run agents individually (for troubleshooting or targeted testing):

```bash
# Web Application Security
bash agent-web-security.sh

# Database Security
bash agent-database-security.sh

# Network Security
bash agent-network-security.sh

# API Testing
bash agent-api-testing.sh
```

## Features

### Parallel Execution
- All agents run simultaneously
- Reduced testing time by ~75%
- Independent execution paths

### Comprehensive Coverage
- 100+ endpoint tests per port
- Extensive credential testing
- Complete SSL/TLS analysis
- API security assessment

### Evidence Collection
- All commands documented
- Full output captured
- Timestamped logging
- Reproducible results

### Safety Controls
- Production-safe testing
- No destructive operations
- Rate limiting respected
- Timeouts implemented

## Targets

### Primary: 10.0.1.99
- Port 22: SSH (OpenSSH 8.9p1)
- Port 80: HTTP (Golang net/http)
- Port 443: HTTPS (Golang net/http) - EXPIRED CERT
- Port 3306: MySQL 8.0.43
- Port 8080: HTTPS (Golang net/http) - EXPIRED CERT

### Additional: 10.0.1.10
- Port 9091: HTTP (Golang net/http)

## Requirements

### Essential Tools
- curl
- nmap
- mysql client
- openssl
- netcat (nc)

### Optional Tools (recommended)
- gobuster (for directory enumeration)
- hydra (for credential testing)
- testssl.sh (for SSL/TLS analysis)

## Timeline

Typical execution time: 15-30 minutes depending on:
- Network latency
- Service response times
- Number of endpoints discovered
- Tool availability

## Safety Notes

- **Production Environment:** All testing is non-aggressive
- **No DoS:** Rate limiting and timeouts prevent service disruption
- **No Destructive Operations:** Read-only testing only
- **Network Scope:** 10.0.1.0/24 (excluding 10.0.1.6 and 10.0.1.13)

## Troubleshooting

### Agent Not Starting
Check the pre-flight output for missing dependencies or connectivity issues.

### Agent Stuck
Review the agent's log file in the evidence directory:
```bash
tail -f /home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence/{agent-name}/agent-{agent-name}.log
```

### Missing Tools
Install optional tools:
```bash
sudo apt-get install gobuster hydra
```

## Report Contents

The final report includes:
1. Executive Summary
2. Target Environment Details
3. Testing Methodology
4. Detailed Findings by Agent
5. Risk Assessment
6. Comprehensive Recommendations
7. Evidence References
8. Reproduction Steps

## Notes

- All file paths are absolute for consistency
- Agents are designed to fail gracefully
- Evidence is preserved even if agents fail
- Report generation attempts to work with partial results

## Version

Framework Version: 1.0
Date: 2026-01-10
Coordinator: Multi-Agent Coordinator
