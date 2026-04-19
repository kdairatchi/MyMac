# Fortinet CVEs

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-04-16 · Items: 1_

---

## What

Fortinet's product line — FortiGate (NGFW), FortiWeb (WAF), FortiOS (router/firewall), FortiManager (central mgmt), FortiAnalyzer, FortiMail. Management interfaces historically exposed to internet. CVEs since 2022 average ~2 critical/quarter. Central position in enterprise networks: compromising any of these is a pivot into internal VPN + an authenticated route past the edge firewall.

Why it pays for hunters: large exposed Shodan surface (`http.favicon.hash:-1847138733` for FortiGate), slow patch cycles on enterprise kit, and chainable (SSL-VPN session cookie leaks → auth bypass → RCE has happened multiple times). Red team value is even higher — a compromised FortiGate gives you a management channel + cleartext of all traffic.

Classes worth chasing in 2025/2026: management interface auth bypasses (impersonation, CSRF-to-token), SSL-VPN pre-auth, format string / stack overflows in CLI, API path-traversal on FortiManager.

---

## CVEs

| CVE | Date | Title | CVSS | Status | Src |
|---|---|---|---|---|---|
| CVE-2025-64446 | 2026-04-16 | Fortinet FortiWeb Auth Bypass via Impersonation | critical | poc | [src](https://labs.watchtowr.com/when-the-impersonation-function-gets-used-to-impersonate-users-fortinet-fortiweb-auth-bypass/) |

---

## Probes

```bash
# Shodan — find exposed Fortinet
shodan search "http.favicon.hash:-1847138733"                 # FortiGate
shodan search "http.favicon.hash:944476180"                   # FortiWeb mgmt
shodan search "html:'fgt_lang'"                               # FortiOS login
shodan search "ssl.cert.subject.CN:'FortiGate'"

# Fingerprint via favicon
curl -sSL https://target/favicon.ico | md5sum
# FortiGate: 0f3b7d3a2a5e... / content-length 7634 / Server: xxxxxxxx-xxxxx

# SSL-VPN version probe (pre-auth)
curl -sSI "https://target/remote/login" | grep -i server
curl -sSL "https://target/remote/login" | grep -Ei "fgt_lang|vpn-ssl"

# FortiManager API path
curl -sSI "https://target/p/login/"
curl -sSI "https://target/jsonrpc"                            # API endpoint

# Impersonation endpoint (CVE-2025-64446 trigger path)
curl -sS "https://target/api/v3.0/user/impersonate" -H "Cookie: APSESSION=<sess>"

# nuclei
nuclei -u https://target -tags fortinet,fortigate,fortiweb -severity high,critical
```

Response fingerprints:
- FortiGate login: `Server: xxxxxxxx-xxxxxxxx` (masked), HTML contains `fgt_lang`
- FortiWeb admin: Banner `FortiWeb`, cookie `APSCOOKIE_`
- FortiManager: path `/p/login/` redirects to `/p/frame/index/`

---

## PoCs

_Public PoC links rolled up from items below._

- **CVE-2025-64446** — [source](https://labs.watchtowr.com/when-the-impersonation-function-gets-used-to-impersonate-users-fortinet-fortiweb-auth-bypass/)

---

## Reproduction

Per-CVE steps live in ## Items. General workflow for Fortinet findings:

1. Fingerprint — favicon hash, `Server:` header, TLS cert CN, banner grab
2. Extract version — from HTML (`var fgt_build =`), `/system/status` JSON endpoint when auth is trivial, or from error responses
3. Pick matching CVE from the table above
4. Craft PoC using public write-up (watchTowr / Assetnote typically publishes full repro)
5. Verify impact: admin cookie obtained, `/api/v3.0/system/status` returns sensitive data, or RCE evidence via sleep/OOB
6. Capture evidence: `curl -v` output + screenshot of impersonated session / shell

Negative test — a patched box returns 401/403 on the trigger endpoint or the version header reports post-patch build (e.g. FortiWeb 7.6.5+ for CVE-2025-64446).

---

## Defense

Priority-ordered:

- **Patch promptly** — FortiGuard PSIRT advisories at https://www.fortiguard.com/psirt. Fortinet often publishes after in-wild exploitation.
- **Hide mgmt interfaces** — bind admin to internal interfaces only. If remote mgmt is required, restrict by source IP, require client cert.
- **Disable impersonation features** in FortiWeb admin unless needed (CVE-2025-64446 precondition).
- **Logging** — ship FortiAnalyzer logs to SIEM; alert on `admin_impersonate` events + bursts of 401s on `/api/v3.0/*`.
- **WAF-in-front** — even a Cloudflare/Akamai shield catches some of these (rate limits, obvious path patterns). Don't rely on it alone.
- **Compensating** — if patch can't happen: IP-allowlist, 2FA on VPN, disable SSL-VPN web portal and use FortiClient only.

---

## References

- [labs.watchtowr.com](https://labs.watchtowr.com/when-the-impersonation-function-gets-used-to-impersonate-users-fortinet-fortiweb-auth-bypass/)

---

## Items

## 2026-04-16

### Fortinet FortiWeb Auth Bypass via Impersonation — `CVE-2025-64446`

- **Tags:** `#auth-bypass` `#fortinet` `#appliance`
- **Severity:** critical · **Hunt:** 4/5 · **Score:** 54.0 · **Status:** poc · **Age:** 0d
- **Sources:** [1](https://labs.watchtowr.com/when-the-impersonation-function-gets-used-to-impersonate-users-fortinet-fortiweb-auth-bypass/)

- **What:** A designated administrative "impersonation" function in Fortinet FortiWeb can be leveraged to bypass authentication and take over arbitrary user sessions.
- **Why it matters:** As a central WAF appliance, compromising FortiWeb provides attackers with a privileged position to inspect, modify, or block traffic and potentially pivot to internal networks.
- **Hunt signal:** Scan FortiWeb management interfaces for exposed impersonation endpoints or test for logic flaws that allow switching user contexts without proper validation.
- **Evidence:** [watchtowr_labs] Technical analysis of CVE-2025-64446 revealing the misuse of the impersonation API. · [opinion] Critical vulnerability for perimeter defense appliances; patch immediately if exposed.

---
