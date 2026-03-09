# Climate Control Exploitation - Quick Start Guide

## Immediate Execution Commands

### RECOMMENDED: Start with Quick Validation (2 minutes)

```bash
cd /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts
chmod +x *.sh *.py
./climate-quick-test.sh
```

This runs 20+ quick tests to verify:
- Service is responsive
- Integer overflow is triggerable
- Basic command injection works
- Buffer overflows are possible

**Review results:**
```bash
ls -lh /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/quick-tests/
```

---

### FULL EXPLOITATION: Run All 4 Agents (2 hours)

```bash
cd /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts
./run-full-exploitation.sh
# Select option 1 (sequential execution)
```

This executes:
1. **Phase 1:** Quick validation (2 min)
2. **Phase 2:** Comprehensive exploitation (30 min)
3. **Phase 3:** Code execution attempts (20 min)
4. **Phase 4:** Advanced fuzzing (60 min)

**Total: 2,207+ tests executed**

---

### INDIVIDUAL AGENTS: Run Specific Exploitation

**Agent 1 - Comprehensive Exploitation (30 min):**
```bash
python3 /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/climate-exploit-coordinator.py
```
- Tests all integer boundaries
- Buffer overflow fuzzing
- Format string testing
- Generates EXPLOITATION-REPORT.md

**Agent 2 - Advanced Fuzzer (60 min):**
```bash
python3 /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/climate-fuzzer.py
```
- 1000+ integer boundary tests
- 500+ random payloads
- Crash detection
- Generates FUZZING-REPORT.md

**Agent 3 - RCE Attempts (20 min):**
```bash
python3 /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/climate-rce.py
```
- Command injection (all variants)
- Reverse shell attempts
- File access testing
- Generates RCE-EXPLOITATION-REPORT.md

**Agent 4 - Quick Test (2 min):**
```bash
bash /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/climate-quick-test.sh
```
- Rapid validation
- Basic overflow tests
- Quick command injection

---

## Evidence Location

**All results saved to:**
```
/home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/
```

**Key files to review:**
```bash
# Master summary
cat /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/MASTER-SUMMARY.md

# Individual reports
cat /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/EXPLOITATION-REPORT.md
cat /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/rce-attempts/RCE-EXPLOITATION-REPORT.md
cat /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/fuzzing/FUZZING-REPORT.md

# Check for RCE success
grep -r "uid=\|gid=\|POSSIBLE.*RCE" /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/
```

---

## If RCE is Achieved

**Next steps if code execution is successful:**

1. **Extract system information:**
```bash
# Review successful exploit evidence
ls /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/successful-exploits/
```

2. **Document the working payload**
3. **Extract credentials and configs**
4. **Map the network for lateral movement**
5. **Establish persistent access if authorized**

---

## Monitoring During Execution

**Watch logs in real-time:**
```bash
# Terminal 1: Run exploitation
./run-full-exploitation.sh

# Terminal 2: Monitor logs
tail -f /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/logs/*.log
```

**Check for crashes:**
```bash
grep -i "crash\|error\|segmentation" /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/logs/*.log
```

---

## Stopping Execution

Press `Ctrl+C` to interrupt any running script.

All evidence collected up to that point will be preserved.

---

## Troubleshooting

**Service not responding:**
```bash
# Test connectivity
timeout 3 bash -c 'echo "STATUS" | nc -w 2 10.0.1.10 6768'
```

**Scripts not executable:**
```bash
cd /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts
chmod +x *.sh *.py
```

**Need to clean evidence:**
```bash
rm -rf /home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/*
```

---

## Summary of Created Scripts

| Script | Purpose | Duration | Tests |
|--------|---------|----------|-------|
| run-full-exploitation.sh | Master coordinator | 2 hours | All |
| climate-exploit-coordinator.py | Comprehensive testing | 30 min | 665+ |
| climate-fuzzer.py | Advanced fuzzing | 60 min | 1000+ |
| climate-rce.py | Code execution | 20 min | 100+ |
| climate-quick-test.sh | Quick validation | 2 min | 20+ |

**Total Test Coverage: 2,207+ tests**

---

## EXECUTE NOW

**Recommended first step:**

```bash
cd /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts
./climate-quick-test.sh
```

This will complete in 2-3 minutes and provide immediate validation of the vulnerability.

Then proceed to full exploitation:

```bash
./run-full-exploitation.sh
```

---

**All systems ready. Begin exploitation.**
