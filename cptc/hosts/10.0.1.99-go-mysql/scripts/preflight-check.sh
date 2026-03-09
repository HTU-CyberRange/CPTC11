#!/bin/bash
# Pre-flight Check Script
# Validates environment and dependencies before launching agents

echo "=================================="
echo "Pre-flight Environment Check"
echo "=================================="
echo ""

READY=true

# Check target connectivity
echo "[1/8] Checking target connectivity..."
if ping -c 1 -W 2 10.0.1.99 &>/dev/null; then
    echo "  ✓ Target 10.0.1.99 is reachable"
else
    echo "  ✗ Target 10.0.1.99 is NOT reachable"
    READY=false
fi

if ping -c 1 -W 2 10.0.1.10 &>/dev/null; then
    echo "  ✓ Target 10.0.1.10 is reachable"
else
    echo "  ✗ Target 10.0.1.10 is NOT reachable (non-critical)"
fi
echo ""

# Check required tools
echo "[2/8] Checking required tools..."
TOOLS=("curl" "nmap" "mysql" "openssl" "nc")

for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo "  ✓ $tool installed"
    else
        echo "  ✗ $tool NOT installed"
        READY=false
    fi
done
echo ""

# Check optional tools
echo "[3/8] Checking optional tools..."
OPT_TOOLS=("gobuster" "hydra" "testssl.sh")

for tool in "${OPT_TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo "  ✓ $tool installed"
    else
        echo "  ⚠ $tool not installed (optional, some tests will be skipped)"
    fi
done
echo ""

# Check directory structure
echo "[4/8] Checking directory structure..."
DIRS=(
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql"
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts"
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql/findings"
)

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir exists"
    else
        echo "  ⚠ Creating $dir"
        mkdir -p "$dir"
    fi
done
echo ""

# Check agent scripts
echo "[5/8] Checking agent scripts..."
SCRIPTS=(
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts/agent-web-security.sh"
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts/agent-database-security.sh"
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts/agent-network-security.sh"
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts/agent-api-testing.sh"
    "/home/pentester/cptc/hosts/10.0.1.99-go-mysql/scripts/generate-report.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        echo "  ✓ $(basename "$script") present"
        chmod +x "$script" 2>/dev/null
    else
        echo "  ✗ $(basename "$script") NOT FOUND"
        READY=false
    fi
done
echo ""

# Check network ports
echo "[6/8] Checking target ports..."
PORTS=("22" "80" "443" "3306" "8080")

for port in "${PORTS[@]}"; do
    if timeout 2 nc -z 10.0.1.99 "$port" &>/dev/null; then
        echo "  ✓ Port $port is open on 10.0.1.99"
    else
        echo "  ⚠ Port $port appears closed/filtered"
    fi
done
echo ""

# Check disk space
echo "[7/8] Checking disk space..."
AVAILABLE=$(df -h /home/pentester | awk 'NR==2 {print $4}')
echo "  Available space: $AVAILABLE"
echo ""

# Check permissions
echo "[8/8] Checking permissions..."
if [ -w "/home/pentester/cptc/hosts/10.0.1.99-go-mysql" ]; then
    echo "  ✓ Write permissions OK"
else
    echo "  ✗ No write permissions"
    READY=false
fi
echo ""

# Final status
echo "=================================="
if [ "$READY" = true ]; then
    echo "✓ PRE-FLIGHT CHECK PASSED"
    echo "=================================="
    echo ""
    echo "System ready for multi-agent testing."
    echo ""
    exit 0
else
    echo "✗ PRE-FLIGHT CHECK FAILED"
    echo "=================================="
    echo ""
    echo "Please resolve the issues above before proceeding."
    echo ""
    exit 1
fi
