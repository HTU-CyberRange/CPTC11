#!/bin/bash
# Jellyfin enumeration for 10.0.1.30

TARGET="10.0.1.30"
PORT="8096"
OUTPUT_DIR="/home/pentester/cptc/web-apps"

echo "[+] Starting Jellyfin enumeration on $TARGET:$PORT"
echo ""

# Test main page
echo "[TEST 1] Testing main page..."
curl -s -i http://$TARGET:$PORT/ | head -n 30 > "$OUTPUT_DIR/$TARGET-jellyfin-root.txt"
cat "$OUTPUT_DIR/$TARGET-jellyfin-root.txt"
echo ""

# Test robots.txt
echo "[TEST 2] Testing robots.txt..."
curl -s http://$TARGET:$PORT/robots.txt > "$OUTPUT_DIR/$TARGET-jellyfin-robots.txt"
cat "$OUTPUT_DIR/$TARGET-jellyfin-robots.txt"
echo ""

# Test common Jellyfin API endpoints
echo "[TEST 3] Testing Jellyfin API endpoints..."
for endpoint in "System/Info/Public" "Branding/Configuration" "Users/Public" "web/ConfigurationPages"; do
    echo "  Testing /$endpoint..."
    curl -s http://$TARGET:$PORT/$endpoint -o "$OUTPUT_DIR/$TARGET-jellyfin-$endpoint.txt" 2>&1
    if [ -s "$OUTPUT_DIR/$TARGET-jellyfin-$endpoint.txt" ]; then
        echo "    Response: $(head -c 200 "$OUTPUT_DIR/$TARGET-jellyfin-$endpoint.txt")"
    fi
    echo ""
done

echo "[+] Jellyfin enumeration completed"
