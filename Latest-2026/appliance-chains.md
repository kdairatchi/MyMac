# Appliance Exploit Chains — 2025/2026

> Dated: **2026-04-15**

Edge appliances (VPN concentrators, firewalls, load balancers, mail gateways) are 2024-2026's favourite ransomware entry point. Not usually in bug bounty scope — but relevant for pentest, research, and program-boundary awareness.

## The usual suspects

| Vendor | Product | 2024-2025 highlights |
|---|---|---|
| Ivanti | Connect Secure, Policy Secure | CVE-2024-21887, CVE-2024-46805, CVE-2025-0282, CVE-2025-22457 — repeat offenders |
| Fortinet | FortiOS, FortiManager | CVE-2024-23113, CVE-2024-47575 (FortiJump, FortiGuard), CVE-2025-24472 |
| Citrix | NetScaler ADC/Gateway | CVE-2023-4966 (Bleed) lingering, CVE-2024-8534, CVE-2025-5777 (CitrixBleed 2) |
| Palo Alto | PAN-OS GlobalProtect | CVE-2024-3400 (Apr 2024), CVE-2024-0012 + 9474 chain (Nov 2024) |
| SonicWall | SMA, SSL VPN | CVE-2024-45318, CVE-2025-23006 |
| Check Point | Quantum Gateway | CVE-2024-24919 |

## Pattern recognition

Appliance RCE chains almost always look like:
1. **Unauth file-read / path-traversal** (configuration, session data)
2. **Session pivot** (stolen token from leak) OR **command injection** in a CGI-era endpoint
3. **Root-equivalent** because appliance runs as root

Treat any new appliance CVE as: "expect file-read + RCE primitive, chain with leaked session."

## Why they matter for bug bounty

- Many large programs host VPN / ADC edge that **is** in scope
- Shodan/Censys recon → appliance version → known CVE match = high-impact report
- Responsible disclosure even if out of scope — vendor program or CERT

## Recon

```bash
# Shodan dorks
ssl.cert.subject.cn:"*.ivanti.com"
http.title:"Pulse Secure"
http.html:"FortiGuard"
http.title:"NetScaler Gateway"

# Nuclei templates
nuclei -u https://target -tags ivanti,fortinet,citrix,paloalto
```

## Reference sources

- watchTowr Labs — https://labs.watchtowr.com (appliance exploit deep-dives)
- Assetnote — https://www.assetnote.io/resources/research
- Horizon3 Attack Blog
- Orca Security / Wiz Research

---

*CVE catalogue accurate as of Apr 2026. Vendors drop new ones monthly — check NVD before filing.*
