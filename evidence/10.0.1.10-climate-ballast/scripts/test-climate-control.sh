#!/bin/bash
# Safe testing script for Lido Deck Climate Control System
# Target: 10.0.1.10:6768

TARGET="10.0.1.10"
PORT="6768"
OUTPUT_DIR="/home/pentester/cptc/custom-protocols"

echo "[+] Testing Lido Deck Climate Control System"
echo "[+] Target: $TARGET:$PORT"
echo ""

# Test 1: Basic connection and menu
echo "[TEST 1] Connecting and retrieving menu..."
echo "EXIT" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/climate-control-menu.txt" 2>&1
cat "$OUTPUT_DIR/climate-control-menu.txt"
echo ""

# Test 2: STATUS command
echo "[TEST 2] Testing STATUS command..."
echo -e "STATUS\nEXIT" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/climate-control-status.txt" 2>&1
tail -n 20 "$OUTPUT_DIR/climate-control-status.txt"
echo ""

# Test 3: SET command (safe temperature values)
echo "[TEST 3] Testing SET command with safe values..."
echo -e "SET 72\nEXIT" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/climate-control-set-72.txt" 2>&1
tail -n 10 "$OUTPUT_DIR/climate-control-set-72.txt"
echo ""

# Test 4: Explore SET command syntax
echo "[TEST 4] Testing SET command without parameters..."
echo -e "SET\nEXIT" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/climate-control-set-empty.txt" 2>&1
tail -n 10 "$OUTPUT_DIR/climate-control-set-empty.txt"
echo ""

# Test 5: Test invalid commands
echo "[TEST 5] Testing invalid/fuzzing inputs..."
echo -e "HELP\nEXIT" | nc -w 3 $TARGET $PORT > "$OUTPUT_DIR/climate-control-help.txt" 2>&1
tail -n 10 "$OUTPUT_DIR/climate-control-help.txt"
echo ""

echo "[+] Climate Control testing completed. Results in $OUTPUT_DIR"
