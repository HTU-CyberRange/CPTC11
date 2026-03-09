#!/bin/bash

TOKEN=$(curl -k -s https://penny.allports.tours/api/auth/login -X POST \
  -H 'Content-Type: application/json' \
  -d '{"email":"pentester","password":")u1h55hm-h(M(7nV"}' | \
  python3 -c 'import sys, json; print(json.load(sys.stdin)["token"])')

echo "[+] Testing Admin/Privileged Endpoints"
BASE="https://penny.allports.tours"

# Test admin endpoints
echo -e "\n[*] /api/admin/users"
curl -k -s "$BASE/api/admin/users" -H "Authorization: Bearer $TOKEN" | head -100

echo -e "\n[*] /api/admin/config"
curl -k -s "$BASE/api/admin/config" -H "Authorization: Bearer $TOKEN" | head -100

echo -e "\n[*] /api/balance"
curl -k -s "$BASE/api/balance" -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>&1

echo -e "\n[*] /api/keys/all"
curl -k -s "$BASE/api/keys/all" -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>&1

echo -e "\n[*] /api/user (GET)"
curl -k -s "$BASE/api/user" -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>&1

echo -e "\n[*] /api/agents (list)"
curl -k -s "$BASE/api/agents" -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>&1 | head -100

echo -e "\n[*] /api/assistants (list)"
curl -k -s "$BASE/api/assistants" -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>&1 | head -100

echo -e "\n[*] /api/search (users)"
curl -k -s "$BASE/api/search?q=admin" -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>&1

echo -e "\n[*] /api/bookmarks"
curl -k -s "$BASE/api/bookmarks" -H "Authorization: Bearer $TOKEN" | python3 -m json.tool 2>&1 | head -50

