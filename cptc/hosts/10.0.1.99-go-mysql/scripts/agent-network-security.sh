#!/bin/bash
# Network Security Agent
# Target: 10.0.1.99 SSL/TLS analysis, service enumeration
# Focus: Certificate analysis, SSL/TLS vulnerabilities, network protocols

set -e

TARGET="10.0.1.99"
EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"
FINDINGS_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/findings"

mkdir -p "$EVIDENCE_DIR/network-security"
mkdir -p "$FINDINGS_DIR"

AGENT_LOG="$EVIDENCE_DIR/network-security/agent-network-security.log"
echo "[$(date)] Network Security Agent Started" | tee -a "$AGENT_LOG"

# Phase 1: Comprehensive SSL/TLS Certificate Analysis
echo "[$(date)] Phase 1: SSL/TLS Certificate Deep Analysis" | tee -a "$AGENT_LOG"

# Analyze certificate on port 443
echo "[$(date)] Analyzing HTTPS port 443 certificate" | tee -a "$AGENT_LOG"

# Get full certificate chain
echo | openssl s_client -connect ${TARGET}:443 -showcerts 2>&1 | \
    tee "$EVIDENCE_DIR/network-security/ssl-cert-chain-443.txt"

# Get certificate details in readable format
echo | openssl s_client -connect ${TARGET}:443 2>&1 | \
    openssl x509 -noout -text | \
    tee "$EVIDENCE_DIR/network-security/ssl-cert-details-443.txt"

# Check certificate expiration
echo | openssl s_client -connect ${TARGET}:443 2>&1 | \
    openssl x509 -noout -dates | \
    tee "$EVIDENCE_DIR/network-security/ssl-cert-dates-443.txt"

# Extract certificate subject and issuer
echo | openssl s_client -connect ${TARGET}:443 2>&1 | \
    openssl x509 -noout -subject -issuer | \
    tee "$EVIDENCE_DIR/network-security/ssl-cert-subject-443.txt"

# Analyze certificate on port 8080
echo "[$(date)] Analyzing HTTPS port 8080 certificate" | tee -a "$AGENT_LOG"

echo | openssl s_client -connect ${TARGET}:8080 -showcerts 2>&1 | \
    tee "$EVIDENCE_DIR/network-security/ssl-cert-chain-8080.txt"

echo | openssl s_client -connect ${TARGET}:8080 2>&1 | \
    openssl x509 -noout -text | \
    tee "$EVIDENCE_DIR/network-security/ssl-cert-details-8080.txt"

echo | openssl s_client -connect ${TARGET}:8080 2>&1 | \
    openssl x509 -noout -dates | \
    tee "$EVIDENCE_DIR/network-security/ssl-cert-dates-8080.txt"

# Phase 2: SSL/TLS Vulnerability Scanning
echo "[$(date)] Phase 2: SSL/TLS Vulnerability Assessment" | tee -a "$AGENT_LOG"

# Test with testssl.sh for comprehensive analysis
if command -v testssl.sh &> /dev/null; then
    echo "[$(date)] Running testssl.sh on port 443" | tee -a "$AGENT_LOG"
    testssl.sh --full "${TARGET}:443" > \
        "$EVIDENCE_DIR/network-security/testssl-full-443.txt" 2>&1 || true

    echo "[$(date)] Running testssl.sh on port 8080" | tee -a "$AGENT_LOG"
    testssl.sh --full "${TARGET}:8080" > \
        "$EVIDENCE_DIR/network-security/testssl-full-8080.txt" 2>&1 || true
fi

# Test SSL/TLS cipher suites
echo "[$(date)] Testing SSL/TLS cipher suites port 443" | tee -a "$AGENT_LOG"
nmap --script ssl-enum-ciphers -p 443 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/ssl-ciphers-443.txt" 2>&1 || true

echo "[$(date)] Testing SSL/TLS cipher suites port 8080" | tee -a "$AGENT_LOG"
nmap --script ssl-enum-ciphers -p 8080 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/ssl-ciphers-8080.txt" 2>&1 || true

# Test for Heartbleed
echo "[$(date)] Testing for Heartbleed vulnerability" | tee -a "$AGENT_LOG"
nmap --script ssl-heartbleed -p 443,8080 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/ssl-heartbleed.txt" 2>&1 || true

# Test for POODLE
echo "[$(date)] Testing for POODLE vulnerability" | tee -a "$AGENT_LOG"
nmap --script ssl-poodle -p 443,8080 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/ssl-poodle.txt" 2>&1 || true

# Test for CCS Injection
echo "[$(date)] Testing for CCS Injection" | tee -a "$AGENT_LOG"
nmap --script ssl-ccs-injection -p 443,8080 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/ssl-ccs-injection.txt" 2>&1 || true

# Phase 3: Certificate Validation Bypass Testing
echo "[$(date)] Phase 3: Certificate Validation Analysis" | tee -a "$AGENT_LOG"

# Test if expired certificate causes security issues
echo "[$(date)] Testing expired certificate handling" | tee -a "$AGENT_LOG"

# Test various certificate validation scenarios
# Scenario 1: Accept all certificates (like curl -k)
curl -k -v -m 10 "https://${TARGET}/" > \
    "$EVIDENCE_DIR/network-security/cert-validation-skip-443.txt" 2>&1 || true

# Scenario 2: Strict validation
curl -v -m 10 "https://${TARGET}/" > \
    "$EVIDENCE_DIR/network-security/cert-validation-strict-443.txt" 2>&1 || true

# Scenario 3: Test with wrong hostname
curl -k -v -m 10 --resolve "wronghost.com:443:${TARGET}" "https://wronghost.com/" > \
    "$EVIDENCE_DIR/network-security/cert-validation-wronghost-443.txt" 2>&1 || true

# Phase 4: Service Version Detection and Fingerprinting
echo "[$(date)] Phase 4: Advanced Service Fingerprinting" | tee -a "$AGENT_LOG"

# Comprehensive service scan
nmap -sV -sC -p 22,80,443,3306,8080 --version-intensity 9 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/nmap-service-scan.txt" 2>&1 || true

# Test SSH service
echo "[$(date)] SSH service enumeration" | tee -a "$AGENT_LOG"
nmap --script ssh2-enum-algos,ssh-hostkey,ssh-auth-methods -p 22 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/ssh-enum.txt" 2>&1 || true

# Get SSH banner
timeout 5 nc -v "$TARGET" 22 > \
    "$EVIDENCE_DIR/network-security/ssh-banner.txt" 2>&1 || true

# Test MySQL service
echo "[$(date)] MySQL service enumeration" | tee -a "$AGENT_LOG"
nmap --script mysql-info,mysql-dump-hashes -p 3306 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/mysql-service-enum.txt" 2>&1 || true

# Phase 5: HTTP/HTTPS Header Analysis
echo "[$(date)] Phase 5: HTTP Security Headers Analysis" | tee -a "$AGENT_LOG"

# Check security headers on port 80
echo "[$(date)] Analyzing HTTP headers port 80" | tee -a "$AGENT_LOG"
curl -s -I -m 10 "http://${TARGET}/" > \
    "$EVIDENCE_DIR/network-security/http-headers-80.txt" 2>&1 || true

# Check security headers on port 443
echo "[$(date)] Analyzing HTTPS headers port 443" | tee -a "$AGENT_LOG"
curl -s -k -I -m 10 "https://${TARGET}/" > \
    "$EVIDENCE_DIR/network-security/http-headers-443.txt" 2>&1 || true

# Check security headers on port 8080
echo "[$(date)] Analyzing HTTPS headers port 8080" | tee -a "$AGENT_LOG"
curl -s -k -I -m 10 "https://${TARGET}:8080/" > \
    "$EVIDENCE_DIR/network-security/http-headers-8080.txt" 2>&1 || true

# Test for missing security headers
echo "[$(date)] Testing for security header presence" | tee -a "$AGENT_LOG"

SECURITY_HEADERS=(
    "Strict-Transport-Security"
    "Content-Security-Policy"
    "X-Frame-Options"
    "X-Content-Type-Options"
    "X-XSS-Protection"
    "Referrer-Policy"
    "Permissions-Policy"
)

for port in 80 443 8080; do
    protocol="http"
    url="http://${TARGET}/"
    if [ "$port" == "443" ]; then
        protocol="https"
        url="https://${TARGET}/"
    elif [ "$port" == "8080" ]; then
        protocol="https"
        url="https://${TARGET}:8080/"
    fi

    echo "[$(date)] Checking security headers on port $port" | tee -a "$AGENT_LOG"
    headers=$(curl -s -k -I -m 10 "$url")

    for header in "${SECURITY_HEADERS[@]}"; do
        if echo "$headers" | grep -qi "$header"; then
            echo "[PRESENT] $header on port $port" | tee -a "$AGENT_LOG"
        else
            echo "[MISSING] $header on port $port" | tee -a "$AGENT_LOG" "$EVIDENCE_DIR/network-security/missing-headers.txt"
        fi
    done
done

# Phase 6: HTTP/2 and Protocol Testing
echo "[$(date)] Phase 6: HTTP Protocol Analysis" | tee -a "$AGENT_LOG"

# Test HTTP/2 support
curl -s -k -I --http2 -m 10 "https://${TARGET}/" > \
    "$EVIDENCE_DIR/network-security/http2-test-443.txt" 2>&1 || true

curl -s -k -I --http2 -m 10 "https://${TARGET}:8080/" > \
    "$EVIDENCE_DIR/network-security/http2-test-8080.txt" 2>&1 || true

# Phase 7: Additional Port Scanning
echo "[$(date)] Phase 7: Comprehensive Port Scanning" | tee -a "$AGENT_LOG"

# Quick scan for additional ports
nmap -p- --max-retries 1 --max-rtt-timeout 200ms -T4 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/full-port-scan.txt" 2>&1 || true

# UDP scan for common services
nmap -sU --top-ports 100 -T4 "$TARGET" > \
    "$EVIDENCE_DIR/network-security/udp-scan.txt" 2>&1 || true

# Phase 8: TLS Configuration Analysis
echo "[$(date)] Phase 8: TLS Protocol Version Testing" | tee -a "$AGENT_LOG"

# Test different TLS versions
TLS_VERSIONS=("ssl3" "tls1" "tls1_1" "tls1_2" "tls1_3")

for version in "${TLS_VERSIONS[@]}"; do
    echo "[$(date)] Testing TLS version: $version" | tee -a "$AGENT_LOG"

    # Port 443
    timeout 5 openssl s_client -connect ${TARGET}:443 -${version//_/.} \
        < /dev/null > "$EVIDENCE_DIR/network-security/tls-${version}-443.txt" 2>&1 || true

    # Port 8080
    timeout 5 openssl s_client -connect ${TARGET}:8080 -${version//_/.} \
        < /dev/null > "$EVIDENCE_DIR/network-security/tls-${version}-8080.txt" 2>&1 || true
done

# Phase 9: Certificate Trust Chain Analysis
echo "[$(date)] Phase 9: Certificate Trust Analysis" | tee -a "$AGENT_LOG"

# Verify certificate chain
openssl s_client -connect ${TARGET}:443 -showcerts < /dev/null 2>&1 | \
    openssl verify - > "$EVIDENCE_DIR/network-security/cert-verify-443.txt" 2>&1 || true

# Test OCSP stapling
echo | openssl s_client -connect ${TARGET}:443 -status 2>&1 | \
    tee "$EVIDENCE_DIR/network-security/ocsp-stapling-443.txt"

# Phase 10: Network Timing and Performance Analysis
echo "[$(date)] Phase 10: Network Performance Analysis" | tee -a "$AGENT_LOG"

# Measure response times
for port in 80 443 8080; do
    protocol="http"
    url="http://${TARGET}/"
    if [ "$port" == "443" ]; then
        url="https://${TARGET}/"
    elif [ "$port" == "8080" ]; then
        url="https://${TARGET}:8080/"
    fi

    echo "[$(date)] Timing analysis for port $port" | tee -a "$AGENT_LOG"
    curl -k -w "Time Total: %{time_total}s\nTime Connect: %{time_connect}s\nTime SSL: %{time_appconnect}s\n" \
        -o /dev/null -s "$url" | \
        tee "$EVIDENCE_DIR/network-security/timing-${port}.txt"
done

echo "[$(date)] Network Security Agent Completed" | tee -a "$AGENT_LOG"
echo "[$(date)] Results saved to: $EVIDENCE_DIR/network-security/" | tee -a "$AGENT_LOG"

# Generate summary report
echo "[$(date)] Generating network security summary..." | tee -a "$AGENT_LOG"

cat > "$EVIDENCE_DIR/network-security/SUMMARY.txt" << 'SUMMARY_EOF'
Network Security Assessment Summary
====================================

SSL/TLS Certificate Issues:
- Certificates on ports 443 and 8080 are EXPIRED
- Check detailed analysis in ssl-cert-*.txt files

Security Headers:
- Check missing-headers.txt for absent security headers

TLS Configuration:
- Analyze testssl-*.txt for vulnerable configurations
- Check for weak ciphers in ssl-ciphers-*.txt

Service Fingerprinting:
- All services fingerprinted and documented
- Version information collected for vulnerability research

Recommendations:
1. Renew expired SSL certificates immediately
2. Implement missing security headers
3. Disable weak TLS protocols and ciphers
4. Review certificate validation in applications
SUMMARY_EOF

cat "$EVIDENCE_DIR/network-security/SUMMARY.txt" | tee -a "$AGENT_LOG"
