# CPTC Workspace Quick Start Guide

## New Organization - Start Here!

The workspace has been completely reorganized (2026-01-10). This guide will help you get oriented quickly.

---

## First Time? Read These Files In Order:

1. **This file** - Quick orientation (you are here)
2. **INDEX.md** - Complete navigation guide
3. **REORGANIZATION-SUMMARY.md** - What changed and why
4. Your host's README - Detailed host information

---

## Quick Navigation

### I need to...

#### See the big picture
```bash
cat /home/pentester/cptc/INDEX.md
```

#### Find executive reports
```bash
ls -la /home/pentester/cptc/reports/executive/
cat /home/pentester/cptc/reports/executive/EXECUTIVE-SUMMARY.md
```

#### Find technical reports
```bash
ls -la /home/pentester/cptc/reports/technical/
cat /home/pentester/cptc/reports/technical/FINDINGS-REPORT.md
```

#### Check what I should be testing
```bash
ls /home/pentester/cptc/hosts/
# Our responsibility: All hosts in this directory
```

#### See what the other team member is doing
```bash
cat /home/pentester/cptc/team-member-scope/README.md
ls /home/pentester/cptc/team-member-scope/
```

#### Find data about a specific host
```bash
# Example for 10.0.1.11:
cat /home/pentester/cptc/hosts/10.0.1.11-librechat/README.md
ls /home/pentester/cptc/hosts/10.0.1.11-librechat/enumeration/
```

#### See all findings
```bash
ls /home/pentester/cptc/findings/validated/
cat /home/pentester/cptc/reports/tracking/FINDINGS-TRACKER.md
```

#### Find testing scripts
```bash
# Host-specific scripts:
ls /home/pentester/cptc/hosts/*/scripts/

# For a specific host:
ls /home/pentester/cptc/hosts/10.0.1.11-librechat/scripts/
```

---

## Our Testing Scope (Our Team)

### Critical Priority
- **10.0.1.10** - Custom control systems (CRITICAL findings F002, F005)
- **10.0.1.11** - LibreChat/Penny AI (CRITICAL findings F001, F003)

### Medium Priority
- **10.0.1.99** - Go applications + MySQL (under investigation)
- **10.0.1.14** - Reverse proxy (limited testing)

### Low Priority
- **10.0.1.30** - Jellyfin media server (no critical findings)

All in: `/home/pentester/cptc/hosts/`

---

## Team Member Scope (Other Team Member)

### Windows Hosts
- **10.0.1.20** - Deckhand-01 Windows workstation (Finding F004)
- **10.0.1.21** - Deckhand-02 Windows workstation (Finding F004)

Location: `/home/pentester/cptc/team-member-scope/`
Status: Enumeration complete, exploitation by team member

---

## Out of Scope (DO NOT TEST)

- **10.0.1.6** - Active Directory DC
- **10.0.1.13** - Various services
- **10.0.0.0/24** - Different network segment
- **Cloud infrastructure** - Laforge platform

Location: `/home/pentester/cptc/out-of-scope/`

---

## Critical Findings Summary

| ID | Severity | Host | Description |
|---|---|---|---|
| F001 | CRITICAL | 10.0.1.11 | Database access via LibreChat |
| F002 | CRITICAL | 10.0.1.10 | Integer overflow in climate control |
| F003 | HIGH | 10.0.1.11 | Weak password policy |
| F004 | HIGH | 10.0.1.20/21 | SMB signing disabled (team member) |
| F005 | HIGH | 10.0.1.10 | Ballast control auth issues |

---

## Directory Structure At-A-Glance

```
/home/pentester/cptc/
├── INDEX.md                    # Comprehensive navigation guide
├── QUICK-START.md              # This file
├── REORGANIZATION-SUMMARY.md   # What changed
├── README.md                   # Legacy (reference reports/)
│
├── hosts/                      # OUR TESTING SCOPE
│   ├── 10.0.1.10-custom-control/
│   ├── 10.0.1.11-librechat/
│   ├── 10.0.1.14-reverse-proxy/
│   ├── 10.0.1.30-jellyfin/
│   └── 10.0.1.99-go-mysql/
│       ├── README.md           # Host details
│       ├── enumeration/        # Scan data
│       ├── findings/           # Findings for this host
│       ├── evidence/           # PoC evidence
│       └── scripts/            # Testing scripts
│
├── team-member-scope/          # TEAM MEMBER RESPONSIBILITY
│   ├── README.md               # Handoff documentation
│   ├── 10.0.1.20-deckhand-01/
│   └── 10.0.1.21-deckhand-02/
│
├── reports/                    # ALL REPORTS
│   ├── executive/              # For management
│   ├── technical/              # For technical teams
│   └── tracking/               # Progress tracking
│
├── findings/                   # MASTER FINDINGS
│   └── validated/              # Confirmed findings
│
├── out-of-scope/               # DO NOT TEST
│
└── _archive/                   # Old structure preserved
```

---

## Common Tasks

### Starting work on a host
```bash
# 1. Read the host README
cat /home/pentester/cptc/hosts/10.0.1.11-librechat/README.md

# 2. Review existing enumeration data
ls /home/pentester/cptc/hosts/10.0.1.11-librechat/enumeration/

# 3. Check existing findings
ls /home/pentester/cptc/hosts/10.0.1.11-librechat/findings/

# 4. Use or create scripts
ls /home/pentester/cptc/hosts/10.0.1.11-librechat/scripts/
```

### Documenting a new finding
```bash
# 1. Create finding directory in master findings
mkdir /home/pentester/cptc/findings/validated/F00X-finding-name/

# 2. Copy finding to host directory
cp -r /home/pentester/cptc/findings/validated/F00X-finding-name/ \
      /home/pentester/cptc/hosts/HOSTNAME/findings/

# 3. Update findings tracker
vim /home/pentester/cptc/reports/tracking/FINDINGS-TRACKER.md
```

### Adding evidence
```bash
# Save evidence to host-specific directory
cp evidence.txt /home/pentester/cptc/hosts/HOSTNAME/evidence/

# Or to finding directory
cp evidence.txt /home/pentester/cptc/hosts/HOSTNAME/findings/F00X-finding-name/
```

### Checking team member progress
```bash
# Read handoff documentation
cat /home/pentester/cptc/team-member-scope/README.md

# Check their enumeration
ls /home/pentester/cptc/team-member-scope/10.0.1.20-deckhand-01/

# Review findings they're working on
ls /home/pentester/cptc/team-member-scope/10.0.1.20-deckhand-01/findings/
```

---

## Important Notes

1. **Nothing was deleted** - All original data is in `/_archive/`
2. **Host-based organization** - Everything organized by target host
3. **Clear ownership** - Our scope vs team member scope vs out-of-scope
4. **Comprehensive docs** - README files at every level
5. **Preserved findings** - Master copies + host-specific copies

---

## Need Help?

1. **INDEX.md** - Comprehensive guide to everything
2. **Host README files** - Detailed host information
3. **REORGANIZATION-SUMMARY.md** - Complete change documentation
4. **Team member README** - Handoff and coordination info

---

## Key Files to Bookmark

- **Navigation:** `/home/pentester/cptc/INDEX.md`
- **This Guide:** `/home/pentester/cptc/QUICK-START.md`
- **Executive Summary:** `/home/pentester/cptc/reports/executive/EXECUTIVE-SUMMARY.md`
- **Findings Report:** `/home/pentester/cptc/reports/technical/FINDINGS-REPORT.md`
- **Findings Tracker:** `/home/pentester/cptc/reports/tracking/FINDINGS-TRACKER.md`
- **Host Inventory:** `/home/pentester/cptc/reports/tracking/HOST-INVENTORY.md`

---

## What Changed?

The workspace was reorganized from a flat, scattered structure into a clean host-based organization:

- Reports consolidated into `/reports/`
- Enumeration data organized by host
- Duplicate files eliminated
- Team responsibilities clarified
- Comprehensive documentation added
- All original data preserved in `/_archive/`

See **REORGANIZATION-SUMMARY.md** for complete details.

---

## Ready to Work?

1. Read INDEX.md for complete navigation
2. Review your target host's README file
3. Check existing enumeration in host's directory
4. Start testing and document in host's directories
5. Update tracking documents as you progress

**Good luck with your testing!**

---

Last Updated: 2026-01-10
