#!/bin/bash

# Get fresh token
TOKEN=$(curl -k -s https://penny.allports.tours/api/auth/login -X POST \
  -H 'Content-Type: application/json' \
  -d '{"email":"pentester","password":")u1h55hm-h(M(7nV"}' | \
  python3 -c 'import sys, json; print(json.load(sys.stdin)["token"])')

echo "[+] Token obtained: ${TOKEN:0:50}..."

BASE="https://penny.allports.tours"

# Test MCP endpoints
echo -e "\n[*] Testing /api/mcp/tools"
curl -k -s "$BASE/api/mcp/tools" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | tee /home/pentester/cptc/librechat-testing/mcp-tools.json | python3 -m json.tool 2>&1 | head -100

echo -e "\n[*] Testing /api/mcp/connection/status"
curl -k -s "$BASE/api/mcp/connection/status" \
  -H "Authorization: Bearer $TOKEN" | tee /home/pentester/cptc/librechat-testing/mcp-status.json | python3 -m json.tool 2>&1 | head -50

echo -e "\n[*] Testing /api/keys"
curl -k -s "$BASE/api/keys" \
  -H "Authorization: Bearer $TOKEN" | tee /home/pentester/cptc/librechat-testing/api-keys.json | python3 -m json.tool 2>&1 | head -50

echo -e "\n[*] Testing /api/memories"
curl -k -s "$BASE/api/memories" \
  -H "Authorization: Bearer $TOKEN" | tee /home/pentester/cptc/librechat-testing/memories.json | python3 -m json.tool 2>&1 | head -50

echo -e "\n[*] Testing /api/messages (for existing convo)"
CONVO_ID="69215351-086f-49c5-bdca-242e3e2927e7"
curl -k -s "$BASE/api/messages/$CONVO_ID" \
  -H "Authorization: Bearer $TOKEN" | tee /home/pentester/cptc/librechat-testing/messages.json | python3 -m json.tool 2>&1 | head -100

