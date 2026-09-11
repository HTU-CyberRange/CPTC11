# Engagement Overview

## Summary

Team 4 (Al Hussein Technical University, HTU) performed a Q1 penetration re-test for
All Ports Tours during the CPTC 11 Global Finals. All Ports Tours is a maritime and
cruise operator whose environment mixes standard corporate IT with industrial control
systems for onboard functions such as climate, ballast, and navigation.

- Client: All Ports Tours (`allports.local`)
- Assessment window: 9 to 10 January 2026
- Report version: 2.0.0 (final, approved)
- Result: 4 Critical, 5 High, 14 Medium, 7 Low, 9 Informational findings

## Approach

The test used a grey box, assumed breach methodology. The team started with standard
user credentials and network access, simulating an attacker who already has an initial
foothold inside the corporate network. The goal was to find and validate real attack
paths from a low privilege position, including privilege escalation and lateral movement.

Work followed the Penetration Testing Execution Standard (PTES) and the OWASP Top 10,
in three phases:

1. Reconnaissance and enumeration. Host and service discovery with nmap. Active
   Directory enumeration with BloodHound and PowerView.
2. Vulnerability and misconfiguration analysis. Service and credential checks with
   NetExec, CrackMapExec, and Impacket. Web testing with Burp Suite, Nuclei, and
   Wappalyzer.
3. Exploitation and impact validation. Lateral movement and privilege escalation
   testing to confirm real world risk.

## Rules of engagement

- In scope: the `10.0.1.0/24` internal network and the systems listed below.
- Allowed: port scanning, vulnerability scanning, web application testing,
  privilege escalation, lateral movement, and non destructive credential harvesting.
- Not allowed: denial of service, data deletion, unapproved reboots, phishing,
  physical testing, and testing of systems outside the defined scope.
- Database activity was limited to read operations where possible, and critical
  findings were reported to the client contact as they were discovered.

## Target systems

| Address | Type | Environment | Notes |
|---------|------|-------------|-------|
| 10.0.1.1 | Router | Production | MikroTik RouterOS |
| 10.0.1.6 | Domain Controller | Production | `allports.local`, APT-DC-01 |
| 10.0.1.10 | ICS | Development | Climate and ballast control |
| 10.0.1.11 | Server | Production | Penny AI (LibreChat) and Meilisearch |
| 10.0.1.13 | Server | Simulation | Navigation and Keycloak |
| 10.0.1.14 | Server | Production | CruissantServer (reverse proxy) |
| 10.0.1.15 | Server | Production | Route Controller web application |
| 10.0.1.20 | Server | Production | Deckhand-01 (Windows Server 2022) |
| 10.0.1.21 | Server | Production | Deckhand-02 (Windows Server 2022) |
| 10.0.1.30 | Server | Production | Jellyfin media server |
| 10.0.1.99 | Server | Production | Go applications and MySQL |

The evidence in this repository covers the hosts Team 4 worked directly:
10.0.1.10, 10.0.1.11, 10.0.1.14, 10.0.1.20, 10.0.1.21, 10.0.1.30, and 10.0.1.99,
plus cross host reconnaissance under `evidence/recon/`.

## Tools used

nmap, NetExec, CrackMapExec, Impacket, enum4linux, BloodHound, PowerView, Burp Suite,
Nuclei, Wappalyzer, netcat, curl, and the MySQL and PostgreSQL clients.
