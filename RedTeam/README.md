# RedTeam

A bug bounty / authorized pentest workbench. Everything in this directory is notes for defensive understanding and scoped engagements — not a how-to for unauthorised activity. Every page cites primary sources; tool commands are written for researchers reproducing published technique.

Ground rules: authorization in writing, stay in scope, keep evidence, clean up, and when in doubt stop at proof.

## Phases

- [methodology-and-phases.md](methodology-and-phases.md) — engagement phases, rules of engagement, reporting
- [OPSEC.md](OPSEC.md) — researcher identity, scope hygiene, rate limiting, evidence handling

## Tactics

- [initial-access.md](initial-access.md) — phishing infrastructure, payload delivery, HTML smuggling, USB / HID, supply chain, bounty-path web vectors
- [c2-frameworks.md](c2-frameworks.md) — Sliver, Mythic, Havoc, Metasploit comparison, listener setup, OPSEC rules
- [persistence-linux.md](persistence-linux.md) — cron, systemd, LD_PRELOAD, PAM, SSH keys, shell profile, MOTD
- [persistence-windows.md](persistence-windows.md) — registry Run, scheduled tasks, services, WMI event subs, COM hijacking, IFEO, Winlogon
- [priv-esc-linux.md](priv-esc-linux.md) — SUID, sudo, capabilities, polkit, cron, credential harvest, linpeas flow
- [priv-esc-windows.md](priv-esc-windows.md) — SeImpersonate / Potato family, unquoted services, AlwaysInstallElevated, token theft, winpeas flow
- [lateral-movement.md](lateral-movement.md) — SMB / WinRM / WMI / DCOM / RDP, impacket, NTLM relay, pivot / tunnel
- [credential-access.md](credential-access.md) — LSASS safer alternatives, SAM / NTDS / DCSync, kerberoast, AS-REP, Responder, DPAPI
- [ad-attacks.md](ad-attacks.md) — BloodHound, ACL abuse, RBCD, unconstrained delegation, AD CS ESC1–15, SCCM, LAPS/gMSA
- [cloud-attacks.md](cloud-attacks.md) — AWS IAM privesc, Entra ID, GCP IAM chain, IMDS / SSRF, Kubernetes, cross-cloud federation
- [evasion.md](evasion.md) — AMSI / ETW concepts, PPID spoofing, sleep obfuscation, direct/indirect syscalls — defensive research only, cite sources
- [exfil.md](exfil.md) — HTTPS, cloud / SaaS whitelisted, DNS, ICMP, throttling, bounty-specific minimisation

## Companion files (older, kept for reference)

These predate this index and overlap with the topical pages above. Kept for the additional command references they contain.

- `C2_Frameworks.md`, `C2_Interaction.md`
- `Data_Exfiltration.md`
- `File_System_Operations.md`, `General_Commands.md`
- `Lateral_Movement.md`
- `Linux_Persistence.md`, `Linux_PrivEsc.md`
- `Metasploit.md`, `Mimikatz.md`
- `Network_Scanning.md`, `Nmap.md`, `OSINT.md`
- `OS_Credential_Dumping.md`
- `Snort_Rules.md`
- `Web_Exploitation.md`, `Wireless_Attacks.md`
- `Windows_Persistence.md`, `Windows_PrivEsc.md`
- `cheatsheets.md`, `red_team_methodology.md`, `red_team_tools.md`
- `tools_documentation.md`, `Tools_Overview.md`

## External references

- MITRE ATT&CK — https://attack.mitre.org
- The Hacker Recipes — https://www.thehacker.recipes
- HackTricks — https://book.hacktricks.wiki
- PEASS-ng — https://github.com/peass-ng/PEASS-ng
- impacket — https://github.com/fortra/impacket
- Hacking The Cloud — https://hackingthe.cloud
- LOLBAS — https://lolbas-project.github.io
- GTFOBins — https://gtfobins.github.io
- Sigma — https://github.com/SigmaHQ/sigma
- SwiftOnSecurity sysmon-config — https://github.com/SwiftOnSecurity/sysmon-config
- SpecterOps blog — https://posts.specterops.io
- ADSecurity — https://adsecurity.org
