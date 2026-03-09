#!/bin/bash
# Real-time Progress Monitor
# Displays live status of all running agents

EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"

echo "=================================="
echo "Multi-Agent Testing Progress Monitor"
echo "=================================="
echo ""

# Check each agent's log file
check_agent() {
    local agent_name=$1
    local log_file="$EVIDENCE_DIR/${agent_name}/agent-${agent_name}.log"

    if [ -f "$log_file" ]; then
        echo "[$agent_name Agent]"
        echo "  Status: RUNNING"
        echo "  Last Activity: $(tail -1 "$log_file" 2>/dev/null || echo 'Starting...')"

        # Count evidence files
        evidence_count=$(find "$EVIDENCE_DIR/${agent_name}/" -type f 2>/dev/null | wc -l)
        echo "  Evidence Files: $evidence_count"
        echo ""
    else
        echo "[$agent_name Agent]"
        echo "  Status: NOT STARTED"
        echo ""
    fi
}

# Monitor loop
while true; do
    clear
    echo "=================================="
    echo "Multi-Agent Testing Progress Monitor"
    echo "Updated: $(date)"
    echo "=================================="
    echo ""

    check_agent "web-security"
    check_agent "database-security"
    check_agent "network-security"
    check_agent "api-testing"

    echo "Press Ctrl+C to exit monitoring"
    echo ""

    # Check if all agents are complete
    if [ -f "$EVIDENCE_DIR/master-coordinator.log" ]; then
        if grep -q "All agents have completed" "$EVIDENCE_DIR/master-coordinator.log" 2>/dev/null; then
            echo "=================================="
            echo "ALL AGENTS COMPLETED!"
            echo "=================================="
            break
        fi
    fi

    sleep 10
done
