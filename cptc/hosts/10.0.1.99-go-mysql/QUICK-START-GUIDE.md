# Quick Start Guide
## Multi-Agent Penetration Testing Framework

**Target:** 10.0.1.99 (Go Applications + MySQL Database)
**Framework Status:** READY TO EXECUTE

---

## 🚀 Execute Assessment in 3 Steps

### Step 1: Navigate to Scripts Directory
```bash
cd /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts
```

### Step 2: Make Scripts Executable
```bash
chmod +x *.sh
```

### Step 3: Launch Assessment

**Option A: Full Comprehensive Assessment (15-30 minutes)**
```bash
bash launch-assessment.sh
```

**Option B: Fast Demo Assessment (5-10 minutes) - RECOMMENDED FOR FIRST RUN**
```bash
bash demo-coordinator.sh
```

---

## ⏱️ What Happens During Execution

### Parallel Agent Deployment

```
[Web Security Agent]     [Database Security Agent]     [Network Security Agent]     [API Testing Agent]
        ↓                          ↓                            ↓                            ↓
  Testing ports                MySQL 8.0.43              SSL Certificate              API Discovery
  80, 443, 8080          Credential Testing            Expired Cert Analysis       REST/GraphQL Testing
  Go pprof endpoints     Vulnerability Scanning        Security Headers            Authentication Testing
  Auth bypass attempts   Config disclosure             Cipher Analysis             Rate Limiting Check
        ↓                          ↓                            ↓                            ↓
        └──────────────────────────┴────────────────────────────┴────────────────────────────┘
                                                 │
                                    Evidence Collection & Report Generation
                                                 │
                                    GO-APPLICATIONS-ASSESSMENT.md
```

---

## 📊 View Results

### View Complete Report
```bash
cat /home/pentester/cptc/hosts/10.0.1.99-go-mysql/GO-APPLICATIONS-ASSESSMENT.md
```

### Or Use Pagination
```bash
less /home/pentester/cptc/hosts/10.0.1.99-go-mysql/GO-APPLICATIONS-ASSESSMENT.md
```

### Browse Evidence Files
```bash
cd /home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence
ls -la web-security/
ls -la database-security/
ls -la network-security/
ls -la api-testing/
```

---

## 🔍 Monitor Progress (Optional)

### Open a Second Terminal and Run
```bash
cd /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts
bash monitor-progress.sh
```

This displays real-time updates on:
- Agent status (RUNNING/COMPLETE)
- Last activity timestamp
- Evidence files generated count

---

## 📁 Directory Structure

```
/home/pentester/cptc/hosts/10.0.1.99-go-mysql/
│
├── GO-APPLICATIONS-ASSESSMENT.md       ← FINAL REPORT
├── MULTI-AGENT-FRAMEWORK.md           ← Framework documentation
├── DEPLOYMENT-SUMMARY.md              ← Deployment details
├── QUICK-START-GUIDE.md              ← This file
│
├── scripts/                          ← All executable scripts
│   ├── agent-web-security.sh         ← Web testing agent
│   ├── agent-database-security.sh    ← Database testing agent
│   ├── agent-network-security.sh     ← Network testing agent
│   ├── agent-api-testing.sh          ← API testing agent
│   ├── demo-coordinator.sh           ← Fast demo launcher ⭐
│   ├── launch-assessment.sh          ← Full assessment launcher
│   ├── master-coordinator.sh         ← Master orchestrator
│   ├── generate-report.sh            ← Report generator
│   └── monitor-progress.sh           ← Progress monitor
│
├── evidence/                         ← All testing evidence
│   ├── web-security/                 ← Web agent output
│   ├── database-security/            ← Database agent output
│   ├── network-security/             ← Network agent output
│   ├── api-testing/                  ← API agent output
│   └── master-coordinator.log        ← Main coordination log
│
└── findings/                         ← Validated findings
```

---

## 🎯 What Gets Tested

### Web Security Agent
- ✅ Go pprof debug endpoints (`/debug/pprof/`)
- ✅ Health/metrics endpoints
- ✅ Common web paths (100+ per port)
- ✅ Authentication bypass (11 techniques)
- ✅ HTTP methods (GET, POST, PUT, DELETE, etc.)
- ✅ Ports: 80, 443, 8080 on 10.0.1.99
- ✅ Port: 9091 on 10.0.1.10

### Database Security Agent
- ✅ MySQL 8.0.43 credential testing (1,200+ combinations)
- ✅ Version-specific vulnerabilities
- ✅ Configuration disclosure attempts
- ✅ Anonymous access testing
- ✅ Default credential testing

### Network Security Agent
- ✅ SSL/TLS certificate analysis
- ✅ Expired certificate detection
- ✅ Cipher suite enumeration
- ✅ Security header validation (HSTS, CSP, etc.)
- ✅ Protocol version testing

### API Testing Agent
- ✅ API documentation discovery (Swagger/OpenAPI)
- ✅ REST endpoint enumeration
- ✅ GraphQL endpoint testing
- ✅ Authentication mechanism analysis
- ✅ CORS policy testing
- ✅ Rate limiting assessment

---

## ⚠️ Expected Findings

Based on initial reconnaissance, expect findings in:

1. **Expired SSL Certificates** (HIGH) - Ports 443 & 8080
2. **Missing Security Headers** (MEDIUM)
3. **Information Disclosure** - If debug endpoints are accessible
4. **MySQL Access Control** - Varies based on credential strength

---

## 🔧 Troubleshooting

### Issue: Permission Denied
```bash
chmod +x /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts/*.sh
```

### Issue: Target Not Reachable
```bash
ping 10.0.1.99
# Check VPN/network connectivity
```

### Issue: Agent Stuck
```bash
# View agent log
tail -f /home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence/web-security/agent-web-security.log

# Kill and restart if needed
ps aux | grep agent-
kill {PID}
```

### Issue: Missing Tools
```bash
# Check what's missing
bash /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts/preflight-check.sh

# Install if needed
sudo apt-get install nmap curl mysql-client openssl netcat gobuster hydra
```

---

## 📈 Timeline Expectations

### Demo Mode (Recommended for First Run)
- **Setup:** < 1 minute
- **Execution:** 5-10 minutes
- **Report Generation:** < 1 minute
- **Total:** ~10 minutes

### Full Assessment Mode
- **Setup:** < 1 minute
- **Execution:** 15-30 minutes
- **Report Generation:** < 1 minute
- **Total:** ~30 minutes

---

## 🎓 Learning Opportunities

### Review Agent Logs to Learn
```bash
# See exactly what each agent tested
cat evidence/web-security/agent-web-security.log
cat evidence/database-security/agent-database-security.log
cat evidence/network-security/agent-network-security.log
cat evidence/api-testing/agent-api-testing.log
```

### Examine Evidence Files
```bash
# See actual responses
cat evidence/web-security/pprof-443.txt
cat evidence/network-security/ssl-cert-443.txt
cat evidence/database-security/cred-test-root-empty.txt
```

### Study the Report Generator
```bash
cat scripts/generate-report.sh
# Learn how findings are correlated and reported
```

---

## ✅ Success Indicators

After execution completes, you should see:

✓ **All 4 agents complete successfully**
✓ **Evidence directory contains 50+ files (demo) or 500+ files (full)**
✓ **GO-APPLICATIONS-ASSESSMENT.md generated**
✓ **No agent errors in master-coordinator.log**
✓ **Comprehensive findings documented**

---

## 🚀 Ready to Start?

### Recommended First Run (Demo Mode)

```bash
cd /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts
chmod +x *.sh
bash demo-coordinator.sh
```

**Why Demo Mode First?**
- Faster execution (5-10 minutes)
- Validates framework functionality
- Tests critical vulnerabilities
- Generates complete report
- Safe for production environment

After demo succeeds, you can run full assessment for comprehensive coverage.

---

## 📞 Need Help?

### Check Documentation
1. `DEPLOYMENT-SUMMARY.md` - Complete deployment details
2. `MULTI-AGENT-FRAMEWORK.md` - Architecture and design
3. `scripts/README.md` - Script-specific documentation

### Review Logs
```bash
# Master coordination log
cat evidence/master-coordinator.log

# Individual agent logs
ls -la evidence/*/agent-*.log
```

### Validate Environment
```bash
bash scripts/preflight-check.sh
```

---

## 🎯 One-Line Launch Commands

### Demo Mode (Fast - Recommended)
```bash
cd /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts && chmod +x *.sh && bash demo-coordinator.sh
```

### Full Assessment Mode (Comprehensive)
```bash
cd /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts && chmod +x *.sh && bash launch-assessment.sh
```

### View Report
```bash
cat /home/pentester/cptc/hosts/10.0.1.99-go-mysql/GO-APPLICATIONS-ASSESSMENT.md | less
```

---

**Framework Status:** ✅ READY
**All Systems:** ✅ OPERATIONAL
**Target:** ✅ IN SCOPE

**You're all set! Execute the demo coordinator to begin your multi-agent security assessment.**

---

*Last Updated: 2026-01-10*
*Framework Version: 1.0*
*Status: Production Ready*
