#!/bin/bash
# Quick Launch - Streamlined Multi-Agent Coordinator
# Runs all agents with real-time output

SCRIPT_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts"
EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"
REPORT_FILE="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/GO-APPLICATIONS-ASSESSMENT.md"

mkdir -p "$EVIDENCE_DIR"/{web-security,database-security,network-security,api-testing}

echo "=================================="
echo "Multi-Agent Penetration Testing"
echo "=================================="
echo "Target: 10.0.1.99"
echo "Started: $(date)"
echo "=================================="
echo ""

# Make scripts executable
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null

echo "[*] Launching Web Application Security Agent..."
bash "$SCRIPT_DIR/agent-web-security.sh" > "$EVIDENCE_DIR/web-security-output.log" 2>&1 &
WEB_PID=$!

echo "[*] Launching Database Security Agent..."
bash "$SCRIPT_DIR/agent-database-security.sh" > "$EVIDENCE_DIR/database-security-output.log" 2>&1 &
DB_PID=$!

echo "[*] Launching Network Security Agent..."
bash "$SCRIPT_DIR/agent-network-security.sh" > "$EVIDENCE_DIR/network-security-output.log" 2>&1 &
NET_PID=$!

echo "[*] Launching API Testing Agent..."
bash "$SCRIPT_DIR/agent-api-testing.sh" > "$EVIDENCE_DIR/api-testing-output.log" 2>&1 &
API_PID=$!

echo ""
echo "[*] All agents launched!"
echo "    Web Agent PID: $WEB_PID"
echo "    Database Agent PID: $DB_PID"
echo "    Network Agent PID: $NET_PID"
echo "    API Agent PID: $API_PID"
echo ""
echo "[*] Monitoring execution (this will take several minutes)..."
echo ""

# Wait for all agents
wait $WEB_PID
WEB_STATUS=$?
echo "[✓] Web Application Security Agent completed (exit: $WEB_STATUS)"

wait $DB_PID
DB_STATUS=$?
echo "[✓] Database Security Agent completed (exit: $DB_STATUS)"

wait $NET_PID
NET_STATUS=$?
echo "[✓] Network Security Agent completed (exit: $NET_STATUS)"

wait $API_PID
API_STATUS=$?
echo "[✓] API Testing Agent completed (exit: $API_STATUS)"

echo ""
echo "[*] Generating comprehensive report..."
bash "$SCRIPT_DIR/generate-report.sh"

echo ""
echo "=================================="
echo "Assessment Complete!"
echo "=================================="
echo "Report: $REPORT_FILE"
echo "Evidence: $EVIDENCE_DIR"
echo "=================================="
