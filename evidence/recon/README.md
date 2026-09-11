# Cross Host Reconnaissance

Evidence that spans multiple hosts rather than a single target.

- `nmap-all-hosts.txt` Full nmap service scan of the in scope network, including the
  router (10.0.1.1) and the domain controller APT-DC-01 (10.0.1.6).
- `smb-signing-nxc.txt` and `smb-signing-cme.txt` SMB signing checks across the Windows
  hosts, showing signing disabled on 10.0.1.20 and 10.0.1.21.
- `smb-relay-targets.txt` The relay target list derived from the SMB signing results.
- `authorized-credentials.txt` The client authorized test account and testing scope for
  Penny AI (10.0.1.11).
