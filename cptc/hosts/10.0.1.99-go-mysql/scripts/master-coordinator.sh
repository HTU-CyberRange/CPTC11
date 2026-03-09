#!/bin/bash
# Master Coordination Script
# Orchestrates parallel execution of all specialized security agents
# Target: 10.0.1.99 Go Applications and MySQL Database

set -e

SCRIPT_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts"
EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"
FINDINGS_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/findings"
REPORT_FILE="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/GO-APPLICATIONS-ASSESSMENT.md"

mkdir -p "$EVIDENCE_DIR"
mkdir -p "$FINDINGS_DIR"

MASTER_LOG="$EVIDENCE_DIR/master-coordinator.log"

echo "========================================" | tee -a "$MASTER_LOG"
echo "Multi-Agent Penetration Test Coordinator" | tee -a "$MASTER_LOG"
echo "Target: 10.0.1.99 (Go Applications + MySQL)" | tee -a "$MASTER_LOG"
echo "Additional: 10.0.1.10:9091" | tee -a "$MASTER_LOG"
echo "Started: $(date)" | tee -a "$MASTER_LOG"
echo "========================================" | tee -a "$MASTER_LOG"
echo "" | tee -a "$MASTER_LOG"

# Make all agent scripts executable
chmod +x "$SCRIPT_DIR"/agent-*.sh 2>/dev/null || true

# Agent tracking
declare -A AGENT_PIDS
declare -A AGENT_STATUS
declare -A AGENT_START_TIME

# Start all agents in parallel
echo "[$(date)] Deploying specialized security agents in parallel..." | tee -a "$MASTER_LOG"
echo "" | tee -a "$MASTER_LOG"

# Agent 1: Web Application Security
echo "[$(date)] Launching Web Application Security Agent..." | tee -a "$MASTER_LOG"
AGENT_START_TIME[web]=$(date +%s)
bash "$SCRIPT_DIR/agent-web-security.sh" &
AGENT_PIDS[web]=$!
AGENT_STATUS[web]="RUNNING"
echo "  - PID: ${AGENT_PIDS[web]}" | tee -a "$MASTER_LOG"

sleep 2

# Agent 2: Database Security
echo "[$(date)] Launching Database Security Agent..." | tee -a "$MASTER_LOG"
AGENT_START_TIME[database]=$(date +%s)
bash "$SCRIPT_DIR/agent-database-security.sh" &
AGENT_PIDS[database]=$!
AGENT_STATUS[database]="RUNNING"
echo "  - PID: ${AGENT_PIDS[database]}" | tee -a "$MASTER_LOG"

sleep 2

# Agent 3: Network Security
echo "[$(date)] Launching Network Security Agent..." | tee -a "$MASTER_LOG"
AGENT_START_TIME[network]=$(date +%s)
bash "$SCRIPT_DIR/agent-network-security.sh" &
AGENT_PIDS[network]=$!
AGENT_STATUS[network]="RUNNING"
echo "  - PID: ${AGENT_PIDS[network]}" | tee -a "$MASTER_LOG"

sleep 2

# Agent 4: API Testing
echo "[$(date)] Launching API Testing Agent..." | tee -a "$MASTER_LOG"
AGENT_START_TIME[api]=$(date +%s)
bash "$SCRIPT_DIR/agent-api-testing.sh" &
AGENT_PIDS[api]=$!
AGENT_STATUS[api]="RUNNING"
echo "  - PID: ${AGENT_PIDS[api]}" | tee -a "$MASTER_LOG"

echo "" | tee -a "$MASTER_LOG"
echo "[$(date)] All agents deployed successfully!" | tee -a "$MASTER_LOG"
echo "[$(date)] Active agents: ${#AGENT_PIDS[@]}" | tee -a "$MASTER_LOG"
echo "" | tee -a "$MASTER_LOG"

# Monitor agent execution
echo "[$(date)] Monitoring agent execution..." | tee -a "$MASTER_LOG"
echo "  (This may take several minutes)" | tee -a "$MASTER_LOG"
echo "" | tee -a "$MASTER_LOG"

# Progress monitoring loop
while true; do
    all_complete=true
    status_line="[$(date)] Agent Status: "

    for agent in "${!AGENT_PIDS[@]}"; do
        pid=${AGENT_PIDS[$agent]}

        if kill -0 "$pid" 2>/dev/null; then
            # Process still running
            all_complete=false
            AGENT_STATUS[$agent]="RUNNING"
            status_line+="$agent=RUNNING "
        else
            # Process completed
            wait "$pid" 2>/dev/null
            exit_code=$?

            if [ "$exit_code" == "0" ]; then
                AGENT_STATUS[$agent]="COMPLETED"
                status_line+="$agent=COMPLETED "

                # Calculate duration
                end_time=$(date +%s)
                duration=$((end_time - AGENT_START_TIME[$agent]))
                echo "[$(date)] Agent '$agent' completed successfully (${duration}s)" | tee -a "$MASTER_LOG"
            else
                AGENT_STATUS[$agent]="FAILED"
                status_line+="$agent=FAILED "
                echo "[$(date)] Agent '$agent' failed with exit code $exit_code" | tee -a "$MASTER_LOG"
            fi

            # Remove from active tracking
            unset AGENT_PIDS[$agent]
        fi
    done

    # Display status every 30 seconds
    echo "$status_line" | tee -a "$MASTER_LOG"

    if $all_complete; then
        break
    fi

    sleep 30
done

echo "" | tee -a "$MASTER_LOG"
echo "[$(date)] All agents have completed execution" | tee -a "$MASTER_LOG"
echo "" | tee -a "$MASTER_LOG"

# Display final status
echo "========================================" | tee -a "$MASTER_LOG"
echo "Agent Execution Summary" | tee -a "$MASTER_LOG"
echo "========================================" | tee -a "$MASTER_LOG"

for agent in web database network api; do
    status=${AGENT_STATUS[$agent]}
    echo "  $agent: $status" | tee -a "$MASTER_LOG"
done

echo "" | tee -a "$MASTER_LOG"

# Analyze results and generate findings
echo "[$(date)] Analyzing results and generating report..." | tee -a "$MASTER_LOG"
bash "$SCRIPT_DIR/generate-report.sh"

echo "" | tee -a "$MASTER_LOG"
echo "[$(date)] Coordination complete!" | tee -a "$MASTER_LOG"
echo "[$(date)] Report generated: $REPORT_FILE" | tee -a "$MASTER_LOG"
echo "" | tee -a "$MASTER_LOG"
echo "========================================" | tee -a "$MASTER_LOG"
echo "Evidence Location: $EVIDENCE_DIR" | tee -a "$MASTER_LOG"
echo "Findings Location: $FINDINGS_DIR" | tee -a "$MASTER_LOG"
echo "Final Report: $REPORT_FILE" | tee -a "$MASTER_LOG"
echo "========================================" | tee -a "$MASTER_LOG"
