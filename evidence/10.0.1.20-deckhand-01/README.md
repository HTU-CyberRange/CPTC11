# 10.0.1.20 - Deckhand-01 (Windows Server 2022)

Windows Server 2022 workstation joined to `allports.local`. One of two Deckhand hosts.

## Services

SMB (445), RDP (3389), and WinRM (5985 and 5986) were open. Full port and service detail
is in `../recon/nmap-all-hosts.txt`.

## What was found

- SMB signing disabled (High). SMB signing is off, which allows NTLM relay and machine in
  the middle attacks. Evidence spans both Deckhand hosts and is in `../recon/`
  (`smb-signing-nxc.txt`, `smb-signing-cme.txt`, `smb-relay-targets.txt`).
- Unprotected LSASS allows credential theft (Critical). Detail is in the report.
- CIS Google Chrome benchmark scans for this host are in `evidence/`.

## Layout

- `enumeration/` SMB shares, RPC, NetBIOS, and enum4linux output for 10.0.1.20.
- `evidence/` CIS Chrome Group Policy benchmark reports.
