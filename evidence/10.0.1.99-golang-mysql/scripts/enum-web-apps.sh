#!/bin/bash
# Web application enumeration script
# Safe, non-aggressive testing

OUTPUT_DIR="/home/pentester/cptc/web-apps"

echo "[+] Starting Web Application Enumeration"
echo "[+] Timestamp: $(date)"
echo ""

# Target: 10.0.1.11 - LibreChat
echo "=== TARGET: 10.0.1.11 - LibreChat ==="
echo ""

# Test robots.txt
echo "[TEST 1] Checking robots.txt..."
curl -s http://10.0.1.11/robots.txt > "$OUTPUT_DIR/10.0.1.11-robots.txt"
cat "$OUTPUT_DIR/10.0.1.11-robots.txt"
echo ""

# Test /api/ endpoint
echo "[TEST 2] Testing /api/ endpoint..."
curl -s -i http://10.0.1.11/api/ > "$OUTPUT_DIR/10.0.1.11-api-root.txt" 2>&1
head -n 30 "$OUTPUT_DIR/10.0.1.11-api-root.txt"
echo ""

# Test API endpoints
echo "[TEST 3] Testing common API endpoints..."
for endpoint in "config" "version" "health" "status" "auth" "user" "users"; do
    echo "  Testing /api/$endpoint..."
    curl -s -i "http://10.0.1.11/api/$endpoint" -o "$OUTPUT_DIR/10.0.1.11-api-$endpoint.txt" 2>&1
    head -n 5 "$OUTPUT_DIR/10.0.1.11-api-$endpoint.txt"
done
echo ""

# Test Meilisearch (port 7700)
echo "[TEST 4] Testing Meilisearch (7700)..."
curl -s http://10.0.1.11:7700/ > "$OUTPUT_DIR/10.0.1.11-meilisearch-root.txt"
cat "$OUTPUT_DIR/10.0.1.11-meilisearch-root.txt"
echo ""

# Test Meilisearch version endpoint
echo "[TEST 5] Testing Meilisearch /version..."
curl -s http://10.0.1.11:7700/version > "$OUTPUT_DIR/10.0.1.11-meilisearch-version.txt"
cat "$OUTPUT_DIR/10.0.1.11-meilisearch-version.txt"
echo ""

# Test Meilisearch stats
echo "[TEST 6] Testing Meilisearch /stats..."
curl -s http://10.0.1.11:7700/stats > "$OUTPUT_DIR/10.0.1.11-meilisearch-stats.txt"
cat "$OUTPUT_DIR/10.0.1.11-meilisearch-stats.txt"
echo ""

# Test Meilisearch indexes
echo "[TEST 7] Testing Meilisearch /indexes..."
curl -s http://10.0.1.11:7700/indexes > "$OUTPUT_DIR/10.0.1.11-meilisearch-indexes.txt"
cat "$OUTPUT_DIR/10.0.1.11-meilisearch-indexes.txt"
echo ""

# Test port 8081 (Basic Auth)
echo "[TEST 8] Testing port 8081 (Node.js Express with Basic Auth)..."
curl -s -i http://10.0.1.11:8081/ > "$OUTPUT_DIR/10.0.1.11-8081-root.txt"
head -n 20 "$OUTPUT_DIR/10.0.1.11-8081-root.txt"
echo ""

# Test port 8045 (HTTPS)
echo "[TEST 9] Testing port 8045 (HTTPS)..."
curl -s -k https://10.0.1.11:8045/ > "$OUTPUT_DIR/10.0.1.11-8045-root.txt"
cat "$OUTPUT_DIR/10.0.1.11-8045-root.txt"
echo ""

# Test port 3000 (LibreChat direct)
echo "[TEST 10] Testing port 3000 (LibreChat direct)..."
curl -s -i http://10.0.1.11:3000/ | head -n 30 > "$OUTPUT_DIR/10.0.1.11-3000-root.txt"
cat "$OUTPUT_DIR/10.0.1.11-3000-root.txt"
echo ""

echo "[+] Web application enumeration completed for 10.0.1.11"
