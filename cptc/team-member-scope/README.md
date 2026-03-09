# Team Member Scope - Windows Hosts

## Overview

This directory contains all enumeration data and findings for Windows hosts that are assigned to another team member for exploitation and post-exploitation activities.

**Assigned To:** Other Team Member
**Our Role:** Initial enumeration completed, handed off for exploitation
**Status:** Enumeration Complete - Exploitation by Team Member

---

## Hosts in This Scope

### 10.0.1.20 - Deckhand-01 (Windows Workstation)
- **Status:** Enumerated - Passed to team member
- **Finding:** F004 (SMB Signing Disabled)
- **Directory:** `10.0.1.20-deckhand-01/`

### 10.0.1.21 - Deckhand-02 (Windows Workstation)
- **Status:** Enumerated - Passed to team member
- **Finding:** F004 (SMB Signing Disabled)
- **Directory:** `10.0.1.21-deckhand-02/`

---

## Shared Enumeration Data

### Files in This Directory

- **cme-smb-scan.txt** - CrackMapExec SMB scan results for both hosts
- **nxc-smb-scan.txt** - NetExec SMB scan results for both hosts
- **relay-targets.txt** - Identified SMB relay target list
- **enum-windows-smb.sh** - SMB enumeration script

---

## Finding Summary

### F004 - SMB Signing Disabled (HIGH)
- **Severity:** HIGH (CVSS: 7.x)
- **Affected Hosts:** 10.0.1.20, 10.0.1.21
- **Status:** Validated - Exploitation by team member
- **Impact:** Susceptible to SMB relay attacks
- **Remediation:** Enable SMB signing via Group Policy

**Evidence Location:**
- `10.0.1.20-deckhand-01/findings/F004-smb-signing/`
- `10.0.1.21-deckhand-02/findings/F004-smb-signing/`

---

## Our Contributions

### Enumeration Completed
1. SMB service identification
2. SMB signing detection
3. NetBIOS enumeration
4. RPC enumeration
5. Null session testing
6. Share enumeration
7. User enumeration via RPC
8. Domain information gathering

### Tools Used
- Nmap with SMB scripts
- CrackMapExec (CME)
- NetExec (NXC)
- enum4linux
- rpcclient
- smbclient

### Data Collected
- Service versions
- Domain information
- User lists
- Share information
- SMB signing status
- NetBIOS information

---

## Handoff to Team Member

### What We Provided
1. Complete enumeration data in host-specific directories
2. Validated finding (F004 - SMB Signing Disabled)
3. SMB relay target list
4. Enumeration scripts for reproducibility
5. Initial assessment and security concerns

### What Team Member Should Do
1. Review all enumeration data in host directories
2. Attempt SMB relay attacks using relay-targets.txt
3. Test for additional Windows-specific vulnerabilities
4. Attempt credential harvesting
5. Post-exploitation if access gained
6. Document any additional findings
7. Update findings directories with exploitation evidence

### Coordination Points
- Share any discovered credentials
- Update if additional hosts are discovered
- Coordinate timing of SMB relay attacks
- Share post-exploitation findings

---

## Important Notes

### Scope
- These hosts are IN SCOPE for testing
- Another team member is responsible for exploitation
- We completed initial enumeration only

### SMB Relay Attack Considerations
- Both hosts vulnerable to SMB relay
- No signing requirement detected
- Attack requires careful timing and coordination
- Ensure network monitoring doesn't interfere

### Safety
- Standard Windows workstations
- Avoid denial of service
- Document all exploitation attempts
- Preserve evidence

---

## Next Steps for Team Member

1. **Review Enumeration Data**
   - Read through all files in `10.0.1.20-deckhand-01/enumeration/`
   - Read through all files in `10.0.1.21-deckhand-02/enumeration/`
   - Review `relay-targets.txt`

2. **Attempt SMB Relay**
   - Use Responder + ntlmrelayx
   - Target hosts in relay-targets.txt
   - Attempt to gain access to either or both hosts

3. **Post-Exploitation** (if successful)
   - Credential harvesting (SAM, LSA secrets)
   - Privilege escalation
   - Lateral movement paths
   - Persistent access (if authorized)

4. **Documentation**
   - Update findings directories with new evidence
   - Document exploitation steps
   - Note any additional vulnerabilities found
   - Update tracking documents

5. **Coordination**
   - Share discovered credentials with team
   - Report any critical findings immediately
   - Update progress in shared tracking documents

---

## Contact and Coordination

If you need any clarification on the enumeration data or want to coordinate testing activities:
- Review main workspace INDEX.md: `/home/pentester/cptc/INDEX.md`
- Check findings tracker: `/home/pentester/cptc/reports/tracking/FINDINGS-TRACKER.md`
- Review executive summary: `/home/pentester/cptc/reports/executive/EXECUTIVE-SUMMARY.md`

---

## Related Documentation

- **Main Index:** `/home/pentester/cptc/INDEX.md`
- **Finding F004:** See host-specific findings directories
- **Findings Report:** `/home/pentester/cptc/reports/technical/FINDINGS-REPORT.md`
- **Host Inventory:** `/home/pentester/cptc/reports/tracking/HOST-INVENTORY.md`

---

**Last Updated:** 2026-01-10
**Enumeration By:** Our team
**Exploitation By:** Other team member
**Status:** Ready for exploitation phase
