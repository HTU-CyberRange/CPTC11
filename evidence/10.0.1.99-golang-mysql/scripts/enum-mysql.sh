#!/bin/bash
# Safe MySQL enumeration for 10.0.1.99

TARGET="10.0.1.99"
PORT="3306"
OUTPUT_DIR="/home/pentester/cptc/database-testing"

echo "[+] Starting MySQL enumeration on $TARGET:$PORT"
echo ""

# Test 1: Version detection (already done via nmap)
echo "[TEST 1] MySQL version: 8.0.43 (from nmap)"
echo ""

# Test 2: Anonymous access
echo "[TEST 2] Testing anonymous access..."
mysql -h $TARGET -u root --skip-ssl 2>&1 | tee "$OUTPUT_DIR/$TARGET-mysql-anon-root.txt"
echo ""

# Test 3: Common default credentials
echo "[TEST 3] Testing common default credentials..."
for user in "root" "admin" "mysql" "test"; do
    for pass in "" "root" "admin" "password" "mysql" "test" "toor"; do
        echo "  Trying: $user / $pass"
        timeout 5 mysql -h $TARGET -u "$user" -p"$pass" --skip-ssl -e "SELECT VERSION();" 2>&1 | grep -v "Warning" | head -n 5
    done
done > "$OUTPUT_DIR/$TARGET-mysql-creds-test.txt" 2>&1
cat "$OUTPUT_DIR/$TARGET-mysql-creds-test.txt"
echo ""

# Test 4: MySQL info via nmap scripts
echo "[TEST 4] Running safe nmap MySQL scripts..."
nmap -p 3306 --script mysql-info,mysql-databases,mysql-variables $TARGET -oN "$OUTPUT_DIR/$TARGET-mysql-nmap.txt" 2>&1
cat "$OUTPUT_DIR/$TARGET-mysql-nmap.txt"
echo ""

echo "[+] MySQL enumeration completed"
