# 10.0.1.21 - Deckhand-02 (Windows Server 2022)

Windows Server 2022 workstation joined to `allports.local`. The second Deckhand host,
configured like 10.0.1.20.

## Services

SMB (445), RDP (3389), and WinRM (5985 and 5986) were open. Full port and service detail
is in `../recon/nmap-all-hosts.txt`.

## What was found

- SMB signing disabled (High). Same issue as 10.0.1.20. Shared SMB relay evidence is in
  `../recon/` (`smb-signing-nxc.txt`, `smb-signing-cme.txt`, `smb-relay-targets.txt`).

## Layout

- `enumeration/` SMB shares, RPC, NetBIOS, and enum4linux output for 10.0.1.21.
