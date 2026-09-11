#!/usr/bin/env python3
"""
Climate Control Advanced Fuzzer
Automated fuzzing with intelligent payload generation

Focuses on:
- Numeric boundary fuzzing (all integer types)
- String length fuzzing (1 byte to 1MB)
- Format string fuzzing
- Control character fuzzing
- Unicode and encoding fuzzing
"""

import socket
import time
import sys
import random
import struct
from pathlib import Path

TARGET_HOST = "10.0.1.10"
TARGET_PORT = 6768
TIMEOUT = 3
EVIDENCE_DIR = "/home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/fuzzing"
DELAY = 0.5

class AdvancedFuzzer:
    def __init__(self):
        self.evidence_dir = Path(EVIDENCE_DIR)
        self.evidence_dir.mkdir(parents=True, exist_ok=True)
        self.crashes = []
        self.interesting_responses = []

    def connect(self):
        """Establish connection"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(TIMEOUT)
            sock.connect((TARGET_HOST, TARGET_PORT))
            banner = sock.recv(4096)
            return sock, banner
        except Exception as e:
            return None, str(e).encode()

    def send_payload(self, payload):
        """Send payload and capture response"""
        sock, banner = self.connect()
        if not sock:
            return None, True

        try:
            # Send SET command with payload
            if isinstance(payload, bytes):
                sock.sendall(b"SET " + payload + b"\n")
            else:
                sock.sendall(f"SET {payload}\n".encode('utf-8', errors='ignore'))

            time.sleep(0.3)

            # Receive response
            response = banner
            try:
                while True:
                    chunk = sock.recv(4096)
                    if not chunk:
                        break
                    response += chunk
            except socket.timeout:
                pass

            sock.close()
            return response, False

        except Exception as e:
            if sock:
                sock.close()
            return str(e).encode(), True

    def fuzz_integer_boundaries(self):
        """Comprehensive integer boundary fuzzing"""
        print("[*] Fuzzing integer boundaries...")

        # Generate boundary values for all common integer types
        boundaries = []

        # 8-bit
        for i in range(-130, 260):
            boundaries.append(i)

        # 16-bit boundaries
        for offset in range(-5, 6):
            boundaries.extend([
                32767 + offset,    # INT16_MAX
                -32768 + offset,   # INT16_MIN
                65535 + offset,    # UINT16_MAX
            ])

        # 32-bit boundaries
        for offset in range(-10, 11):
            boundaries.extend([
                2147483647 + offset,   # INT32_MAX
                -2147483648 + offset,  # INT32_MIN
                4294967295 + offset,   # UINT32_MAX
            ])

        # 64-bit boundaries
        for offset in range(-5, 6):
            boundaries.extend([
                9223372036854775807 + offset,   # INT64_MAX
                -9223372036854775808 + offset,  # INT64_MIN
            ])

        # Powers of 2 and nearby values
        for power in range(8, 65):
            base = 2 ** power
            for offset in [-1, 0, 1]:
                boundaries.append(base + offset)
                boundaries.append(-(base + offset))

        print(f"[*] Testing {len(boundaries)} boundary values...")

        crash_count = 0
        for i, value in enumerate(boundaries):
            if i % 100 == 0:
                print(f"[*] Progress: {i}/{len(boundaries)} ({100*i//len(boundaries)}%)")

            response, crashed = self.send_payload(str(value))

            if crashed:
                crash_count += 1
                self.crashes.append(('integer_boundary', value, response))
                self.save_crash('integer_boundary', value, response)

            time.sleep(DELAY)

        print(f"[+] Integer boundary fuzzing complete: {crash_count} crashes")

    def fuzz_string_length(self):
        """Fuzz with incrementing string lengths"""
        print("[*] Fuzzing string lengths...")

        # Test sizes from 1 byte to 100KB
        sizes = list(range(1, 256)) + [512, 1000, 1024, 2048, 4096, 8192, 10000, 16384, 32768, 65536, 100000]

        patterns = [
            lambda n: 'A' * n,
            lambda n: 'B' * n,
            lambda n: '9' * n,
            lambda n: '-' * n,
            lambda n: '\\' * n,
            lambda n: '\x00' * n,
        ]

        crash_count = 0
        for size in sizes:
            for pattern_fn in patterns:
                payload = pattern_fn(size)
                pattern_name = pattern_fn(1)

                response, crashed = self.send_payload(payload)

                if crashed:
                    crash_count += 1
                    self.crashes.append(('buffer_length', f"{size}_{pattern_name}", response))
                    self.save_crash('buffer_length', f"{size}_{pattern_name}", response)
                    print(f"[!] CRASH at size {size} with pattern '{pattern_name}'")

                time.sleep(DELAY)

        print(f"[+] String length fuzzing complete: {crash_count} crashes")

    def fuzz_format_strings(self):
        """Extensive format string fuzzing"""
        print("[*] Fuzzing format strings...")

        format_strings = []

        # Basic format specifiers
        specifiers = ['%d', '%s', '%x', '%p', '%n', '%c', '%f', '%u', '%ld', '%lx']

        # Repeat patterns
        for spec in specifiers:
            for count in [1, 5, 10, 50, 100, 200]:
                format_strings.append(spec * count)

        # Dollar notation (direct parameter access)
        for i in range(1, 50):
            format_strings.extend([
                f"%{i}$x",
                f"%{i}$s",
                f"%{i}$p",
                f"%{i}$n",
            ])

        # Width and precision fuzzing
        for width in [1, 10, 100, 1000, 10000, 100000]:
            format_strings.extend([
                f"%{width}x",
                f"%{width}s",
                f"%.{width}x",
                f"%.{width}s",
            ])

        # Padding with data
        for prefix in ['AAAA', 'BBBB', '\x41\x41\x41\x41']:
            for spec in ['%x', '%s', '%p', '%n']:
                format_strings.append(prefix + spec * 10)

        print(f"[*] Testing {len(format_strings)} format string payloads...")

        crash_count = 0
        interesting = 0

        for i, payload in enumerate(format_strings):
            if i % 50 == 0:
                print(f"[*] Progress: {i}/{len(format_strings)}")

            response, crashed = self.send_payload(payload)

            if crashed:
                crash_count += 1
                self.crashes.append(('format_string', payload, response))
                self.save_crash('format_string', payload, response)
                print(f"[!] CRASH with payload: {payload[:50]}")

            # Check for information disclosure
            if response and (b'0x' in response or b'stack' in response.lower()):
                interesting += 1
                self.interesting_responses.append(('format_string_leak', payload, response))
                print(f"[!] Possible info leak with: {payload[:50]}")

            time.sleep(DELAY)

        print(f"[+] Format string fuzzing complete: {crash_count} crashes, {interesting} info leaks")

    def fuzz_special_characters(self):
        """Fuzz with special characters and control codes"""
        print("[*] Fuzzing special characters...")

        special_payloads = []

        # All ASCII control characters
        for i in range(0, 32):
            special_payloads.append(chr(i) * 100)

        # All extended ASCII
        for i in range(128, 256):
            special_payloads.append(chr(i) * 50)

        # Combinations
        special_combos = [
            '\x00' * 100,  # Null bytes
            '\n' * 100,    # Newlines
            '\r' * 100,    # Carriage returns
            '\t' * 100,    # Tabs
            '\x1b' * 100,  # Escape sequences
            '\\' * 100,    # Backslashes
            '\'' * 100,    # Single quotes
            '\"' * 100,    # Double quotes
            '`' * 100,     # Backticks
            '$' * 100,     # Dollar signs
            ';' * 100,     # Semicolons
            '|' * 100,     # Pipes
            '&' * 100,     # Ampersands
        ]

        special_payloads.extend(special_combos)

        # Unicode payloads
        unicode_payloads = [
            '\u0000' * 100,  # Null
            '\u0041' * 100,  # 'A'
            '\uffff' * 100,  # Max BMP
            '\\u0041' * 100, # Escaped unicode
        ]

        special_payloads.extend(unicode_payloads)

        crash_count = 0
        for payload in special_payloads:
            response, crashed = self.send_payload(payload)

            if crashed:
                crash_count += 1
                self.crashes.append(('special_char', repr(payload[:20]), response))
                self.save_crash('special_char', repr(payload[:20]), response)

            time.sleep(DELAY)

        print(f"[+] Special character fuzzing complete: {crash_count} crashes")

    def fuzz_random_bytes(self, count=1000):
        """Pure random byte fuzzing"""
        print(f"[*] Fuzzing with {count} random payloads...")

        crash_count = 0
        for i in range(count):
            if i % 100 == 0:
                print(f"[*] Progress: {i}/{count}")

            # Random length
            length = random.randint(1, 10000)

            # Random bytes
            payload = bytes([random.randint(0, 255) for _ in range(length)])

            response, crashed = self.send_payload(payload)

            if crashed:
                crash_count += 1
                self.crashes.append(('random', f"random_{i}", response))
                self.save_crash('random', f"random_{i}_len_{length}", payload + b"\n---\n" + response)

            time.sleep(DELAY)

        print(f"[+] Random fuzzing complete: {crash_count} crashes")

    def save_crash(self, category, payload_desc, response):
        """Save crash evidence"""
        crash_dir = self.evidence_dir / 'crashes' / category
        crash_dir.mkdir(parents=True, exist_ok=True)

        filename = f"crash_{len(self.crashes)}_{payload_desc}.txt"
        # Sanitize filename
        filename = "".join(c if c.isalnum() or c in '-_.' else '_' for c in filename)

        filepath = crash_dir / filename

        with open(filepath, 'wb') as f:
            f.write(f"Crash #{len(self.crashes)}\n".encode())
            f.write(f"Category: {category}\n".encode())
            f.write(f"Payload: {payload_desc}\n".encode())
            f.write(b"Response:\n")
            if isinstance(response, bytes):
                f.write(response)
            else:
                f.write(str(response).encode())

    def generate_report(self):
        """Generate fuzzing report"""
        report_path = self.evidence_dir / "FUZZING-REPORT.md"

        report = f"""# Advanced Fuzzing Report - Climate Control System

## Summary

**Target:** {TARGET_HOST}:{TARGET_PORT}
**Total Crashes:** {len(self.crashes)}
**Information Leaks:** {len(self.interesting_responses)}

## Crash Breakdown

"""

        # Count crashes by category
        crash_categories = {}
        for category, payload, response in self.crashes:
            crash_categories[category] = crash_categories.get(category, 0) + 1

        for category, count in crash_categories.items():
            report += f"- **{category}:** {count} crashes\n"

        report += "\n## Crash Details\n\n"

        for i, (category, payload, response) in enumerate(self.crashes[:20], 1):  # First 20
            report += f"### Crash {i}\n"
            report += f"- **Category:** {category}\n"
            report += f"- **Payload:** {payload}\n"
            report += f"- **Response:** {str(response)[:200]}...\n\n"

        if len(self.crashes) > 20:
            report += f"\n*({len(self.crashes) - 20} additional crashes not shown)*\n"

        report += "\n## Recommendations\n\n"
        report += "Based on fuzzing results:\n"
        report += "- Implement strict input validation\n"
        report += "- Add bounds checking for all numeric inputs\n"
        report += "- Sanitize special characters\n"
        report += "- Use safe string handling functions\n"

        with open(report_path, 'w') as f:
            f.write(report)

        print(f"[+] Report saved to: {report_path}")

    def run_all(self):
        """Execute all fuzzing operations"""
        print("="*80)
        print("ADVANCED CLIMATE CONTROL FUZZER")
        print("="*80)
        print(f"Target: {TARGET_HOST}:{TARGET_PORT}")
        print(f"Evidence: {EVIDENCE_DIR}")
        print("="*80)

        try:
            self.fuzz_integer_boundaries()
            self.fuzz_string_length()
            self.fuzz_format_strings()
            self.fuzz_special_characters()
            self.fuzz_random_bytes(500)  # 500 random tests
        except KeyboardInterrupt:
            print("\n[!] Fuzzing interrupted by user")
        except Exception as e:
            print(f"\n[!] Error: {e}")

        self.generate_report()

        print("\n" + "="*80)
        print("FUZZING COMPLETE")
        print("="*80)
        print(f"Total crashes: {len(self.crashes)}")
        print(f"Information leaks: {len(self.interesting_responses)}")
        print("="*80)

if __name__ == "__main__":
    fuzzer = AdvancedFuzzer()
    fuzzer.run_all()
