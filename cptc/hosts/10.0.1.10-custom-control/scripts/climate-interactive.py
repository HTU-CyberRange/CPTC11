#!/usr/bin/env python3
"""Interactive Climate Control Testing with Proper Protocol"""
import socket
import time

HOST = "10.0.1.10"
PORT = 6768

def send_command(sock, command):
    """Send command and get response"""
    # Read any pending data
    try:
        sock.settimeout(1)
        while True:
            data = sock.recv(4096)
            if not data or b':' in data:
                break
    except socket.timeout:
        pass

    # Send command
    sock.settimeout(5)
    sock.sendall(command.encode() + b'\n')
    time.sleep(0.5)

    # Read response
    response = b''
    try:
        while True:
            chunk = sock.recv(4096)
            if not chunk:
                break
            response += chunk
            if b':' in chunk or b'Goodbye' in chunk:
                break
    except socket.timeout:
        pass

    return response.decode('utf-8', errors='ignore')

def test_climate():
    """Test climate control with various commands"""
    print("[*] Connecting to Climate Control System...")

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((HOST, PORT))

    # Read initial banner
    print("[*] Waiting for banner...")
    time.sleep(1)
    banner = sock.recv(4096).decode('utf-8', errors='ignore')
    print(f"[+] Banner received:\n{banner}\n")

    # Test STATUS
    print("[*] Sending STATUS command...")
    response = send_command(sock, "STATUS")
    print(f"[+] STATUS Response:\n{response}\n")

    # Test legitimate SET
    print("[*] Sending SET 72 command...")
    response = send_command(sock, "SET 72")
    print(f"[+] SET 72 Response:\n{response}\n")

    # Check status again
    print("[*] Checking STATUS after SET 72...")
    response = send_command(sock, "STATUS")
    print(f"[+] STATUS Response:\n{response}\n")

    # Test large number
    print("[*] Sending SET 999999999999 command...")
    response = send_command(sock, "SET 999999999999")
    print(f"[+] SET 999999999999 Response:\n{response}\n")

    # Check status after overflow attempt
    print("[*] Checking STATUS after overflow attempt...")
    response = send_command(sock, "STATUS")
    print(f"[+] STATUS Response:\n{response}\n")

    # Exit cleanly
    print("[*] Sending EXIT command...")
    sock.sendall(b'EXIT\n')
    time.sleep(0.5)

    sock.close()
    print("[+] Test complete!")

if __name__ == "__main__":
    test_climate()
