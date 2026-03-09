#!/bin/bash
# LibreChat Security Testing Session
BASE_URL="https://penny.allports.tours"
COOKIES="/home/pentester/cptc/librechat-testing/cookies.txt"
OUTPUT_DIR="/home/pentester/cptc/librechat-testing"

# Test 1: Initial reconnaissance
echo "[+] Testing initial access..."
curl -k -s -c "$COOKIES" "$BASE_URL" > "$OUTPUT_DIR/initial-page.html"

# Test 2: Authentication attempt
echo "[+] Attempting authentication..."
curl -k -s -b "$COOKIES" -c "$COOKIES" \
  -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"pentester","password":")u1h55hm-h(M(7nV"}' \
  > "$OUTPUT_DIR/login-response.json" 2>&1

echo "[+] Login response:"
cat "$OUTPUT_DIR/login-response.json"
