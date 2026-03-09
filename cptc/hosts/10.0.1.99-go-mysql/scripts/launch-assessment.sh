#!/bin/bash
# Launch Script - Coordinated Multi-Agent Penetration Testing
# Executes pre-flight checks and launches master coordinator

SCRIPT_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts"

echo ""
echo "=========================================="
echo "Multi-Agent Penetration Testing Framework"
echo "=========================================="
echo ""
echo "Target: 10.0.1.99 (Go Applications + MySQL)"
echo "Additional: 10.0.1.10:9091"
echo ""
echo "Agents:"
echo "  1. Web Application Security Agent"
echo "  2. Database Security Agent"
echo "  3. Network Security Agent"
echo "  4. API Testing Agent"
echo ""
echo "=========================================="
echo ""

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null

# Run pre-flight checks
echo "Running pre-flight checks..."
echo ""

if bash "$SCRIPT_DIR/preflight-check.sh"; then
    echo ""
    echo "Pre-flight checks passed. Launching agents in 3 seconds..."
    sleep 1
    echo "2..."
    sleep 1
    echo "1..."
    sleep 1
    echo ""
    echo "LAUNCHING AGENTS..."
    echo ""

    # Launch master coordinator
    bash "$SCRIPT_DIR/master-coordinator.sh"

else
    echo ""
    echo "Pre-flight checks failed. Aborting."
    echo ""
    exit 1
fi
