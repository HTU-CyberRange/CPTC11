#!/bin/bash
# Web application enumeration for 10.0.1.99 (Go apps + MySQL)

TARGET="10.0.1.99"
OUTPUT_DIR="/home/pentester/cptc/web-apps"

echo "[+] Starting enumeration of $TARGET"
echo ""

# Test HTTP port 80
echo "[TEST 1] Testing HTTP (80)..."
curl -s -i http://$TARGET/ | head -n 20 > "$OUTPUT_DIR/$TARGET-80-root.txt"
cat "$OUTPUT_DIR/$TARGET-80-root.txt"
echo ""

# Test HTTPS port 443
echo "[TEST 2] Testing HTTPS (443)..."
curl -s -k https://$TARGET/ > "$OUTPUT_DIR/$TARGET-443-root.txt"
cat "$OUTPUT_DIR/$TARGET-443-root.txt"
echo ""

# Test HTTPS port 8080
echo "[TEST 3] Testing HTTPS (8080)..."
curl -s -k https://$TARGET:8080/ > "$OUTPUT_DIR/$TARGET-8080-root.txt"
cat "$OUTPUT_DIR/$TARGET-8080-root.txt"
echo ""

# Try common API endpoints
echo "[TEST 4] Testing common endpoints..."
for endpoint in "api" "api/v1" "health" "status" "metrics" "debug" "admin"; do
    echo "  Testing /$endpoint..."
    curl -s -k https://$TARGET/$endpoint -o "$OUTPUT_DIR/$TARGET-endpoint-$endpoint.txt" 2>&1
    if [ -s "$OUTPUT_DIR/$TARGET-endpoint-$endpoint.txt" ]; then
        echo "    Response received ($(wc -c < "$OUTPUT_DIR/$TARGET-endpoint-$endpoint.txt") bytes)"
    fi
done
echo ""

# Test robots.txt
echo "[TEST 5] Testing robots.txt..."
curl -s http://$TARGET/robots.txt > "$OUTPUT_DIR/$TARGET-robots.txt"
if [ -s "$OUTPUT_DIR/$TARGET-robots.txt" ]; then
    cat "$OUTPUT_DIR/$TARGET-robots.txt"
fi
echo ""

echo "[+] Enumeration completed for $TARGET"
