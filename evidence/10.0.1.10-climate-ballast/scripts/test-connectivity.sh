#!/bin/bash
# Quick connectivity test
echo "[*] Testing connectivity to 10.0.1.10:6768..."
timeout 3 bash -c 'echo "STATUS" | nc -w 2 10.0.1.10 6768' 2>&1
if [ $? -eq 0 ]; then
    echo "[+] Target is online and responsive"
    exit 0
else
    echo "[!] Target not responding"
    exit 1
fi
