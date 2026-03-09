#!/bin/bash
# Demo Coordinator - Fast demonstration of multi-agent coordination
# Performs targeted testing to demonstrate framework capabilities

TARGET_99="10.0.1.99"
TARGET_10="10.0.1.10"
EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"
FINDINGS_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/findings"
REPORT_FILE="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/GO-APPLICATIONS-ASSESSMENT.md"

mkdir -p "$EVIDENCE_DIR"/{web-security,database-security,network-security,api-testing}
mkdir -p "$FINDINGS_DIR"

echo "=========================================="
echo "Multi-Agent Penetration Test - DEMO MODE"
echo "=========================================="
echo "Target: 10.0.1.99 + 10.0.1.10:9091"
echo "Mode: Focused demonstration"
echo "Started: $(date)"
echo "=========================================="
echo ""

# Agent 1: Web Security (subset of tests)
{
    echo "[$(date)] Web Application Security Agent - Demo Mode Started"

    # Test key Go framework endpoints
    echo "[$(date)] Testing Go pprof debug endpoints..."
    for port in 80 443 8080; do
        protocol="http"
        target="${TARGET_99}"
        [ "$port" != "80" ] && protocol="https" && [ "$port" == "8080" ] && target="${TARGET_99}:${port}"

        curl -s -k -m 5 "${protocol}://${target}/debug/pprof/" > "$EVIDENCE_DIR/web-security/pprof-${port}.txt" 2>&1 || true
        curl -s -k -m 5 "${protocol}://${target}/debug/pprof/heap" > "$EVIDENCE_DIR/web-security/pprof-heap-${port}.txt" 2>&1 || true
        curl -s -k -m 5 "${protocol}://${target}/metrics" > "$EVIDENCE_DIR/web-security/metrics-${port}.txt" 2>&1 || true
    done

    # Test 10.0.1.10:9091
    curl -s -m 5 "http://${TARGET_10}:9091/" > "$EVIDENCE_DIR/web-security/10-9091-root.txt" 2>&1 || true
    curl -s -m 5 "http://${TARGET_10}:9091/metrics" > "$EVIDENCE_DIR/web-security/10-9091-metrics.txt" 2>&1 || true
    curl -s -m 5 "http://${TARGET_10}:9091/debug/pprof/" > "$EVIDENCE_DIR/web-security/10-9091-pprof.txt" 2>&1 || true

    echo "[$(date)] Web Application Security Agent - Demo Complete"
} > "$EVIDENCE_DIR/web-security/agent-web-security.log" 2>&1 &
WEB_PID=$!

# Agent 2: Database Security (limited scope)
{
    echo "[$(date)] Database Security Agent - Demo Mode Started"

    # Test a few key credentials
    echo "[$(date)] Testing critical MySQL credentials..."

    # Test root with empty password
    timeout 3 mysql -h "$TARGET_99" -P 3306 -u root -e "SELECT VERSION();" \
        > "$EVIDENCE_DIR/database-security/cred-root-empty.txt" 2>&1 || true

    # Test root with common passwords
    for pass in password admin mysql root; do
        timeout 3 mysql -h "$TARGET_99" -P 3306 -u root -p"$pass" -e "SELECT VERSION();" \
            > "$EVIDENCE_DIR/database-security/cred-root-${pass}.txt" 2>&1 || true
    done

    # Run nmap MySQL scripts
    nmap -p 3306 --script mysql-info,mysql-empty-password "$TARGET_99" \
        > "$EVIDENCE_DIR/database-security/nmap-mysql.txt" 2>&1 || true

    echo "[$(date)] Database Security Agent - Demo Complete"
} > "$EVIDENCE_DIR/database-security/agent-database-security.log" 2>&1 &
DB_PID=$!

# Agent 3: Network Security (focused)
{
    echo "[$(date)] Network Security Agent - Demo Mode Started"

    # SSL Certificate analysis
    echo "[$(date)] Analyzing SSL certificates..."

    echo | openssl s_client -connect ${TARGET_99}:443 2>&1 | \
        tee "$EVIDENCE_DIR/network-security/ssl-cert-443.txt" | \
        openssl x509 -noout -text > "$EVIDENCE_DIR/network-security/ssl-cert-details-443.txt" 2>&1 || true

    echo | openssl s_client -connect ${TARGET_99}:8080 2>&1 | \
        tee "$EVIDENCE_DIR/network-security/ssl-cert-8080.txt" | \
        openssl x509 -noout -text > "$EVIDENCE_DIR/network-security/ssl-cert-details-8080.txt" 2>&1 || true

    # Get certificate dates
    echo | openssl s_client -connect ${TARGET_99}:443 2>&1 | \
        openssl x509 -noout -dates > "$EVIDENCE_DIR/network-security/ssl-dates-443.txt" 2>&1 || true

    echo | openssl s_client -connect ${TARGET_99}:8080 2>&1 | \
        openssl x509 -noout -dates > "$EVIDENCE_DIR/network-security/ssl-dates-8080.txt" 2>&1 || true

    # Test security headers
    curl -s -I -m 5 "http://${TARGET_99}/" > "$EVIDENCE_DIR/network-security/headers-80.txt" 2>&1 || true
    curl -s -k -I -m 5 "https://${TARGET_99}/" > "$EVIDENCE_DIR/network-security/headers-443.txt" 2>&1 || true

    # Quick cipher scan
    nmap --script ssl-enum-ciphers -p 443 "$TARGET_99" > "$EVIDENCE_DIR/network-security/ciphers-443.txt" 2>&1 || true

    echo "[$(date)] Network Security Agent - Demo Complete"
} > "$EVIDENCE_DIR/network-security/agent-network-security.log" 2>&1 &
NET_PID=$!

# Agent 4: API Testing (targeted)
{
    echo "[$(date)] API Testing Agent - Demo Mode Started"

    # Test common API paths
    echo "[$(date)] Testing API endpoints..."

    for port in 80 443 8080; do
        protocol="http"
        target="${TARGET_99}"
        [ "$port" != "80" ] && protocol="https" && [ "$port" == "8080" ] && target="${TARGET_99}:${port}"

        # Test API documentation
        curl -s -k -m 5 "${protocol}://${target}/api" > "$EVIDENCE_DIR/api-testing/api-${port}.txt" 2>&1 || true
        curl -s -k -m 5 "${protocol}://${target}/api/v1" > "$EVIDENCE_DIR/api-testing/api-v1-${port}.txt" 2>&1 || true
        curl -s -k -m 5 "${protocol}://${target}/swagger.json" > "$EVIDENCE_DIR/api-testing/swagger-${port}.txt" 2>&1 || true

        # Test GraphQL
        curl -s -k -X POST -H "Content-Type: application/json" \
            -d '{"query": "{__schema{types{name}}}"}' \
            -m 5 "${protocol}://${target}/graphql" > "$EVIDENCE_DIR/api-testing/graphql-${port}.txt" 2>&1 || true
    done

    # Test 10.0.1.10:9091
    curl -s -m 5 "http://${TARGET_10}:9091/api" > "$EVIDENCE_DIR/api-testing/10-9091-api.txt" 2>&1 || true
    curl -s -m 5 "http://${TARGET_10}:9091/metrics" > "$EVIDENCE_DIR/api-testing/10-9091-metrics.txt" 2>&1 || true

    echo "[$(date)] API Testing Agent - Demo Complete"
} > "$EVIDENCE_DIR/api-testing/agent-api-testing.log" 2>&1 &
API_PID=$!

# Monitor agents
echo "[*] Agents deployed in parallel:"
echo "    Web Security Agent (PID: $WEB_PID)"
echo "    Database Security Agent (PID: $DB_PID)"
echo "    Network Security Agent (PID: $NET_PID)"
echo "    API Testing Agent (PID: $API_PID)"
echo ""
echo "[*] Waiting for agents to complete..."
echo ""

# Wait and report
wait $WEB_PID && echo "[✓] Web Security Agent completed"
wait $DB_PID && echo "[✓] Database Security Agent completed"
wait $NET_PID && echo "[✓] Network Security Agent completed"
wait $API_PID && echo "[✓] API Testing Agent completed"

echo ""
echo "[*] All agents completed. Generating report..."
echo ""

# Generate report
bash /home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts/generate-report.sh

echo ""
echo "=========================================="
echo "Multi-Agent Assessment Complete!"
echo "=========================================="
echo "Report: $REPORT_FILE"
echo "Evidence: $EVIDENCE_DIR"
echo ""
echo "Key Evidence Files:"
echo "  - Web Security: $EVIDENCE_DIR/web-security/"
echo "  - Database: $EVIDENCE_DIR/database-security/"
echo "  - Network: $EVIDENCE_DIR/network-security/"
echo "  - API Testing: $EVIDENCE_DIR/api-testing/"
echo "=========================================="
