#!/usr/bin/env python3
import requests
import json
import sys
from urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

BASE_URL = "https://penny.allports.tours"

def login():
    """Authenticate and get session token"""
    url = f"{BASE_URL}/api/auth/login"
    data = {
        "email": "pentester",
        "password": ")u1h55hm-h(M(7nV"
    }
    response = requests.post(url, json=data, verify=False)
    if response.status_code == 200:
        resp_data = response.json()
        token = resp_data.get('token')
        print(f"[+] Authentication successful!")
        print(f"[+] Token: {token[:50]}...")
        print(f"[+] User ID: {resp_data['user']['_id']}")
        print(f"[+] Role: {resp_data['user']['role']}")
        return token, response.cookies
    else:
        print(f"[-] Authentication failed: {response.status_code}")
        print(response.text)
        return None, None

def test_endpoints(token, cookies):
    """Test various API endpoints"""
    headers = {"Authorization": f"Bearer {token}"}
    
    endpoints = [
        "/api/endpoints",
        "/api/config",
        "/api/assistants",
        "/api/agents",
        "/api/files",
        "/api/actions",
        "/api/tools",
        "/api/mcp/servers",
        "/api/convos",
        "/api/user/balance",
        "/api/models",
    ]
    
    results = {}
    for endpoint in endpoints:
        url = f"{BASE_URL}{endpoint}"
        try:
            resp = requests.get(url, headers=headers, cookies=cookies, verify=False, timeout=5)
            print(f"\n[*] Testing: {endpoint}")
            print(f"    Status: {resp.status_code}")
            if resp.status_code == 200:
                try:
                    data = resp.json()
                    results[endpoint] = data
                    print(f"    Response: {json.dumps(data, indent=2)[:200]}")
                except:
                    print(f"    Response: {resp.text[:200]}")
            else:
                print(f"    Response: {resp.text[:100]}")
        except Exception as e:
            print(f"    Error: {str(e)}")
    
    return results

if __name__ == "__main__":
    token, cookies = login()
    if token:
        results = test_endpoints(token, cookies)
        with open('/home/pentester/cptc/librechat-testing/api-discovery.json', 'w') as f:
            json.dump(results, f, indent=2)
        print(f"\n[+] Results saved to api-discovery.json")
