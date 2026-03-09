#!/bin/bash
# Safe SMB enumeration for Windows workstations
# Targets: 10.0.1.20, 10.0.1.21 (SMB signing NOT required)

OUTPUT_DIR="/home/pentester/cptc/windows-enum"

echo "[+] Starting Windows SMB Enumeration"
echo "[+] Note: SMB signing NOT required on these hosts"
echo ""

for TARGET in "10.0.1.20" "10.0.1.21"; do
    echo "=== TARGET: $TARGET ==="
    echo ""

    # Test 1: Null session enumeration with enum4linux-ng
    echo "[TEST 1] Running enum4linux-ng (null session)..."
    enum4linux-ng -A $TARGET -oY "$OUTPUT_DIR/$TARGET-enum4linux.yaml" > "$OUTPUT_DIR/$TARGET-enum4linux.txt" 2>&1
    echo "  Results saved to $OUTPUT_DIR/$TARGET-enum4linux.txt"
    echo ""

    # Test 2: SMB share enumeration with smbclient
    echo "[TEST 2] SMB share enumeration (null session)..."
    smbclient -L //$TARGET -N > "$OUTPUT_DIR/$TARGET-shares-null.txt" 2>&1
    cat "$OUTPUT_DIR/$TARGET-shares-null.txt"
    echo ""

    # Test 3: RPC user enumeration
    echo "[TEST 3] RPC user enumeration..."
    rpcclient -U "" -N $TARGET -c "enumdomusers" > "$OUTPUT_DIR/$TARGET-users-rpc.txt" 2>&1
    head -n 20 "$OUTPUT_DIR/$TARGET-users-rpc.txt"
    echo ""

    # Test 4: RPC domain info
    echo "[TEST 4] RPC domain info..."
    rpcclient -U "" -N $TARGET -c "querydominfo" > "$OUTPUT_DIR/$TARGET-dominfo-rpc.txt" 2>&1
    cat "$OUTPUT_DIR/$TARGET-dominfo-rpc.txt"
    echo ""

    # Test 5: NetBIOS information
    echo "[TEST 5] NetBIOS information..."
    nbtscan -v $TARGET > "$OUTPUT_DIR/$TARGET-netbios.txt" 2>&1
    cat "$OUTPUT_DIR/$TARGET-netbios.txt"
    echo ""

    echo "[+] Completed enumeration for $TARGET"
    echo "================================================"
    echo ""
done

echo "[+] All Windows enumeration completed"
