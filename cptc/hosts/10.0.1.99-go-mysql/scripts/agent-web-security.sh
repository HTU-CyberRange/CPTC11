#!/bin/bash
# Web Application Security Agent
# Target: 10.0.1.99 (ports 80, 443, 8080) and 10.0.1.10:9091
# Focus: HTTP/HTTPS endpoints, Go framework vulnerabilities, authentication

set -e

TARGET_99="10.0.1.99"
TARGET_10="10.0.1.10"
EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"
FINDINGS_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/findings"

mkdir -p "$EVIDENCE_DIR/web-security"
mkdir -p "$FINDINGS_DIR"

AGENT_LOG="$EVIDENCE_DIR/web-security/agent-web-security.log"
echo "[$(date)] Web Application Security Agent Started" | tee -a "$AGENT_LOG"

# Function to test endpoint
test_endpoint() {
    local url="$1"
    local output_file="$2"
    local description="$3"

    echo "[$(date)] Testing: $description - $url" | tee -a "$AGENT_LOG"

    # Test with curl
    curl -s -k -v -m 10 "$url" > "$output_file" 2>&1 || true

    # Check response code
    response_code=$(curl -s -k -o /dev/null -w "%{http_code}" -m 10 "$url" 2>/dev/null || echo "000")
    echo "[$(date)] Response code: $response_code" | tee -a "$AGENT_LOG"
}

# Test common Go framework paths
echo "[$(date)] Phase 1: Go Framework Path Discovery" | tee -a "$AGENT_LOG"

COMMON_GO_PATHS=(
    "/"
    "/api"
    "/api/v1"
    "/api/v2"
    "/admin"
    "/debug/pprof"
    "/debug/pprof/heap"
    "/debug/pprof/goroutine"
    "/debug/vars"
    "/metrics"
    "/health"
    "/healthz"
    "/readyz"
    "/status"
    "/swagger"
    "/swagger.json"
    "/swagger.yaml"
    "/api-docs"
    "/docs"
    "/graphql"
    "/graphiql"
    "/config"
    "/env"
    "/version"
    "/.env"
    "/actuator"
    "/actuator/health"
    "/actuator/env"
    "/internal"
    "/private"
)

# Test port 80
echo "[$(date)] Testing HTTP port 80" | tee -a "$AGENT_LOG"
for path in "${COMMON_GO_PATHS[@]}"; do
    test_endpoint "http://${TARGET_99}${path}" \
        "$EVIDENCE_DIR/web-security/80${path//\//-}.txt" \
        "HTTP:80$path"
    sleep 0.5
done

# Test port 443
echo "[$(date)] Testing HTTPS port 443" | tee -a "$AGENT_LOG"
for path in "${COMMON_GO_PATHS[@]}"; do
    test_endpoint "https://${TARGET_99}${path}" \
        "$EVIDENCE_DIR/web-security/443${path//\//-}.txt" \
        "HTTPS:443$path"
    sleep 0.5
done

# Test port 8080
echo "[$(date)] Testing HTTPS port 8080" | tee -a "$AGENT_LOG"
for path in "${COMMON_GO_PATHS[@]}"; do
    test_endpoint "https://${TARGET_99}:8080${path}" \
        "$EVIDENCE_DIR/web-security/8080${path//\//-}.txt" \
        "HTTPS:8080$path"
    sleep 0.5
done

# Test port 9091 on 10.0.1.10
echo "[$(date)] Testing HTTP port 9091 on 10.0.1.10" | tee -a "$AGENT_LOG"
for path in "${COMMON_GO_PATHS[@]}"; do
    test_endpoint "http://${TARGET_10}:9091${path}" \
        "$EVIDENCE_DIR/web-security/10-9091${path//\//-}.txt" \
        "HTTP:9091$path"
    sleep 0.5
done

# Phase 2: pprof Debug Endpoint Testing
echo "[$(date)] Phase 2: Go pprof Debug Endpoint Analysis" | tee -a "$AGENT_LOG"

PPROF_ENDPOINTS=(
    "/debug/pprof/"
    "/debug/pprof/cmdline"
    "/debug/pprof/profile"
    "/debug/pprof/symbol"
    "/debug/pprof/trace"
    "/debug/pprof/allocs"
    "/debug/pprof/block"
    "/debug/pprof/heap"
    "/debug/pprof/mutex"
    "/debug/pprof/goroutine"
    "/debug/pprof/threadcreate"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        target="${TARGET_99}:${port}"
    fi

    for path in "${PPROF_ENDPOINTS[@]}"; do
        test_endpoint "${protocol}://${target}${path}" \
            "$EVIDENCE_DIR/web-security/pprof-${port}${path//\//-}.txt" \
            "pprof:${port}$path"
        sleep 0.5
    done
done

# Phase 3: API Fuzzing and Parameter Testing
echo "[$(date)] Phase 3: API Parameter Testing" | tee -a "$AGENT_LOG"

# Test API endpoints with common parameters
API_PARAMS=(
    "?id=1"
    "?id=admin"
    "?id=1'"
    "?id=1%20OR%201=1"
    "?user=admin"
    "?username=admin"
    "?token=test"
    "?key=test"
    "?api_key=test"
    "?debug=true"
    "?debug=1"
    "?test=true"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        target="${TARGET_99}:${port}"
    fi

    for param in "${API_PARAMS[@]}"; do
        test_endpoint "${protocol}://${target}/api${param}" \
            "$EVIDENCE_DIR/web-security/api-params-${port}-${param//[?=]/-}.txt" \
            "API:${port}${param}"
        sleep 0.5
    done
done

# Phase 4: Authentication Testing
echo "[$(date)] Phase 4: Authentication Bypass Testing" | tee -a "$AGENT_LOG"

# Test authentication headers
AUTH_TESTS=(
    "-H 'Authorization: Bearer test'"
    "-H 'Authorization: Bearer admin'"
    "-H 'Authorization: Basic YWRtaW46YWRtaW4='"
    "-H 'X-API-Key: test'"
    "-H 'X-API-Key: admin'"
    "-H 'X-Admin: true'"
    "-H 'X-Admin: 1'"
    "-H 'X-Debug: true'"
    "-H 'X-Forwarded-For: 127.0.0.1'"
    "-H 'X-Original-URL: /admin'"
    "-H 'X-Rewrite-URL: /admin'"
)

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        target="${TARGET_99}:${port}"
    fi

    idx=0
    for auth_test in "${AUTH_TESTS[@]}"; do
        echo "[$(date)] Testing auth bypass: $auth_test on port $port" | tee -a "$AGENT_LOG"
        eval "curl -s -k -v -m 10 $auth_test '${protocol}://${target}/admin'" > \
            "$EVIDENCE_DIR/web-security/auth-test-${port}-${idx}.txt" 2>&1 || true
        ((idx++))
        sleep 0.5
    done
done

# Phase 5: Method Testing
echo "[$(date)] Phase 5: HTTP Method Testing" | tee -a "$AGENT_LOG"

METHODS=("GET" "POST" "PUT" "DELETE" "PATCH" "OPTIONS" "HEAD" "TRACE")

for port in 80 443 8080; do
    protocol="http"
    target="${TARGET_99}"
    if [ "$port" != "80" ]; then
        protocol="https"
        target="${TARGET_99}:${port}"
    fi

    for method in "${METHODS[@]}"; do
        echo "[$(date)] Testing $method on port $port" | tee -a "$AGENT_LOG"
        curl -s -k -v -X "$method" -m 10 "${protocol}://${target}/" > \
            "$EVIDENCE_DIR/web-security/method-${port}-${method}.txt" 2>&1 || true
        sleep 0.5
    done
done

# Phase 6: Directory Brute Force (targeted)
echo "[$(date)] Phase 6: Targeted Directory Discovery" | tee -a "$AGENT_LOG"

# Use gobuster for more comprehensive scanning
if command -v gobuster &> /dev/null; then
    echo "[$(date)] Running gobuster on port 80" | tee -a "$AGENT_LOG"
    gobuster dir -u "http://${TARGET_99}/" \
        -w /usr/share/wordlists/dirb/common.txt \
        -t 10 -q -k --no-error \
        -o "$EVIDENCE_DIR/web-security/gobuster-80.txt" 2>&1 || true

    echo "[$(date)] Running gobuster on port 443" | tee -a "$AGENT_LOG"
    gobuster dir -u "https://${TARGET_99}/" \
        -w /usr/share/wordlists/dirb/common.txt \
        -t 10 -q -k --no-error \
        -o "$EVIDENCE_DIR/web-security/gobuster-443.txt" 2>&1 || true
fi

# Phase 7: SSL Certificate Analysis
echo "[$(date)] Phase 7: SSL Certificate Analysis" | tee -a "$AGENT_LOG"

# Test certificate validation bypass opportunities
echo "[$(date)] Analyzing expired certificates" | tee -a "$AGENT_LOG"

# Get certificate details
echo | openssl s_client -connect ${TARGET_99}:443 -servername ${TARGET_99} 2>&1 | \
    tee "$EVIDENCE_DIR/web-security/ssl-cert-443.txt"

echo | openssl s_client -connect ${TARGET_99}:8080 -servername ${TARGET_99} 2>&1 | \
    tee "$EVIDENCE_DIR/web-security/ssl-cert-8080.txt"

# Test SSL/TLS configuration
testssl.sh --severity MEDIUM --quiet "${TARGET_99}:443" > \
    "$EVIDENCE_DIR/web-security/testssl-443.txt" 2>&1 || true

testssl.sh --severity MEDIUM --quiet "${TARGET_99}:8080" > \
    "$EVIDENCE_DIR/web-security/testssl-8080.txt" 2>&1 || true

echo "[$(date)] Web Application Security Agent Completed" | tee -a "$AGENT_LOG"
echo "[$(date)] Results saved to: $EVIDENCE_DIR/web-security/" | tee -a "$AGENT_LOG"
